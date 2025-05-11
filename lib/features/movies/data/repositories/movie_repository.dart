import 'package:flutter/foundation.dart';
import 'package:movie_test_app/core/constants/api_constants.dart';
import 'package:movie_test_app/core/utils/cache_service.dart';
import 'package:movie_test_app/core/utils/compute_util.dart';
import 'package:movie_test_app/core/utils/service_locator.dart';
import 'package:movie_test_app/features/movies/domain/models/movie_model.dart';
import 'package:tmdb_api/tmdb_api.dart';

class MoviePaginatedResponse {
  final List<MovieModel> movies;
  final int page;
  final int totalPages;

  MoviePaginatedResponse({
    required this.movies,
    required this.page,
    required this.totalPages,
  });

  // Add toJson for caching
  Map<String, dynamic> toJson() => {
    'movies': movies.map((movie) => movie.toJson()).toList(),
    'page': page,
    'totalPages': totalPages,
  };

  // Add fromJson for restoring from cache
  factory MoviePaginatedResponse.fromJson(Map<String, dynamic> json) {
    return MoviePaginatedResponse(
      movies:
          (json['movies'] as List)
              .map((item) => MovieModel.fromJson(item))
              .toList(),
      page: json['page'] as int,
      totalPages: json['totalPages'] as int,
    );
  }
}

class MovieRepository {
  late final TMDB _tmdb;
  final CacheService _cacheService = locator<CacheService>();

  // Cache keys
  static const String _upcomingMoviesKey = 'upcoming_movies';
  static const String _searchMoviesKey = 'search_movies';
  static const String _genresKey = 'genres';
  static const String _categoryImagesKey = 'category_images';
  static const String _movieTrailerKey = 'movie_trailer';

  // Cache durations
  static const Duration _upcomingMoviesCacheDuration = Duration(hours: 6);
  static const Duration _genresCacheDuration = Duration(
    days: 7,
  ); // Genres don't change often
  static const Duration _categoryImagesCacheDuration = Duration(days: 3);
  static const Duration _searchCacheDuration = Duration(hours: 12);
  static const Duration _trailerCacheDuration = Duration(days: 1);

  MovieRepository() {
    _tmdb = TMDB(
      ApiKeys(ApiConstants.apiKey, ApiConstants.readAccessToken),
      logConfig: const ConfigLogger(showLogs: true, showErrorLogs: true),
    );
  }

  Future<MoviePaginatedResponse> getUpcomingMovies({int page = 1}) async {
    try {
      final cacheKey = '${_upcomingMoviesKey}_$page';

      // Try to get from cache first
      final cachedData = await _cacheService.getData<Map<String, dynamic>>(
        cacheKey,
      );
      if (cachedData != null) {
        debugPrint('Using cached upcoming movies data for page $page');
        return MoviePaginatedResponse.fromJson(cachedData);
      }

      // Fetch from API if not in cache
      final Map result = await _tmdb.v3.movies.getUpcoming(page: page);
      final moviesList = List<Map<String, dynamic>>.from(result['results']);

      // Process movies in background using compute
      final movies = await ComputeUtil.processListInBackground(
        moviesList,
        (movie) => MovieModel.fromJson(movie),
      );

      final response = MoviePaginatedResponse(
        movies: movies,
        page: result['page'] ?? page,
        totalPages: result['total_pages'] ?? 1,
      );

      // Save to cache
      await _cacheService.saveData(
        key: cacheKey,
        data: response.toJson(),
        cacheDuration: _upcomingMoviesCacheDuration,
      );

      return response;
    } catch (e) {
      throw MovieRepositoryException('Failed to fetch upcoming movies: $e');
    }
  }

  Future<List<MovieModel>> searchMovies(String query, {int page = 1}) async {
    try {
      final cacheKey = '${_searchMoviesKey}_${query.toLowerCase()}_$page';

      // Try cache first for searches to reduce API calls
      final cachedResults = await _cacheService.getData<List<dynamic>>(
        cacheKey,
      );
      if (cachedResults != null) {
        debugPrint('Using cached search results for "$query" page $page');
        // Process cached results in background
        return ComputeUtil.processListInBackground(
          cachedResults,
          (item) => MovieModel.fromJson(item),
        );
      }

      // Fetch from API
      final Map result = await _tmdb.v3.search.queryMulti(query, page: page);
      final movies =
          List<Map<String, dynamic>>.from(result['results'])
              .where(
                (item) =>
                    item['media_type'] == 'movie' || item['media_type'] == 'tv',
              )
              .toList();

      // Cache search results
      await _cacheService.saveData(
        key: cacheKey,
        data: movies,
        cacheDuration: _searchCacheDuration,
      );

      // Process movies in background
      return ComputeUtil.processListInBackground(
        movies,
        (movie) => MovieModel.fromJson(movie),
      );
    } catch (e) {
      throw MovieRepositoryException('Failed to search movies: $e');
    }
  }

  Future<Map<int, String>> getGenres() async {
    try {
      // Try cache first for genres (they rarely change)
      final cachedGenres = await _cacheService.getData<Map<String, dynamic>>(
        _genresKey,
      );
      if (cachedGenres != null) {
        debugPrint('Using cached genres');
        return cachedGenres.map(
          (key, value) => MapEntry(int.parse(key), value.toString()),
        );
      }

      final Map movieGenres = await _tmdb.v3.genres.getMovieList();
      final Map tvGenres = await _tmdb.v3.genres.getTvlist();

      final Map<int, String> genreMap = {};

      void addGenresToMap(List<Map<String, dynamic>> genres) {
        for (var genre in genres) {
          genreMap[genre['id']] = genre['name'];
        }
      }

      addGenresToMap(List<Map<String, dynamic>>.from(movieGenres['genres']));
      addGenresToMap(List<Map<String, dynamic>>.from(tvGenres['genres']));

      // Cache genres with a long duration
      final stringKeyMap = genreMap.map(
        (key, value) => MapEntry(key.toString(), value),
      );
      await _cacheService.saveData(
        key: _genresKey,
        data: stringKeyMap,
        cacheDuration: _genresCacheDuration,
      );

      return genreMap;
    } catch (e) {
      throw MovieRepositoryException('Failed to fetch genres: $e');
    }
  }

  Future<Map<int, String>> getCategoryImages() async {
    try {
      // Check cache first
      final cachedImages = await _cacheService.getData<Map<String, dynamic>>(
        _categoryImagesKey,
      );
      if (cachedImages != null) {
        debugPrint('Using cached category images');
        return cachedImages.map(
          (key, value) => MapEntry(int.parse(key), value.toString()),
        );
      }

      final Map genresResult = await _tmdb.v3.genres.getMovieList();
      final Map<int, String> imageMap = {};

      for (var genre in List<Map<String, dynamic>>.from(
        genresResult['genres'],
      )) {
        try {
          final Map movieResult = await _tmdb.v3.discover.getMovies(
            withGenres: genre['id'].toString(),
            includeAdult: false,
            sortBy: SortMoviesBy.popularityDesc,
          );

          if (movieResult['results'] != null &&
              (movieResult['results'] as List).isNotEmpty &&
              movieResult['results'][0]['backdrop_path'] != null) {
            imageMap[genre['id']] = movieResult['results'][0]['backdrop_path'];
          }
        } catch (e) {
          // Skip this genre if we can't find an image
          continue;
        }
      }

      // Cache category images
      final stringKeyMap = imageMap.map(
        (key, value) => MapEntry(key.toString(), value),
      );
      await _cacheService.saveData(
        key: _categoryImagesKey,
        data: stringKeyMap,
        cacheDuration: _categoryImagesCacheDuration,
      );

      return imageMap;
    } catch (e) {
      throw MovieRepositoryException('Failed to fetch category images: $e');
    }
  }

  Future<String?> getMovieTrailer(int movieId) async {
    try {
      final cacheKey = '${_movieTrailerKey}_$movieId';

      // Try cache first
      final cachedTrailer = await _cacheService.getData<String?>(cacheKey);
      if (cachedTrailer != null) {
        debugPrint('Using cached trailer for movie $movieId');
        return cachedTrailer;
      }

      final Map result = await _tmdb.v3.movies.getVideos(movieId);
      final videos = List<Map<String, dynamic>>.from(result['results']);

      // First try to find an official trailer
      final trailer = videos.firstWhere(
        (video) =>
            video['type']?.toLowerCase() == 'trailer' &&
            video['site']?.toLowerCase() == 'youtube' &&
            video['official'] == true,
        orElse:
            () => videos.firstWhere(
              (video) =>
                  video['type']?.toLowerCase() == 'trailer' &&
                  video['site']?.toLowerCase() == 'youtube',
              orElse: () => {},
            ),
      );

      if (trailer.isEmpty) return null;
      final trailerUrl = 'https://www.youtube.com/watch?v=${trailer['key']}';

      // Cache trailer URL
      await _cacheService.saveData(
        key: cacheKey,
        data: trailerUrl,
        cacheDuration: _trailerCacheDuration,
      );

      return trailerUrl;
    } catch (e) {
      throw MovieRepositoryException('Failed to fetch movie trailer: $e');
    }
  }

  /// Clear all cached data
  Future<void> clearCache() async {
    await _cacheService.clearAllCache();
  }

  /// Clear specific cache entries
  Future<void> clearUpcomingMoviesCache() async {
    final prefs = locator<CacheService>();
    await prefs.invalidateCache(_upcomingMoviesKey);
  }
}

class MovieRepositoryException implements Exception {
  final String message;

  MovieRepositoryException(this.message);

  @override
  String toString() => message;
}
