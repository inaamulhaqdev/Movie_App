import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:movie_test_app/core/utils/connectivity_service.dart';
import 'package:movie_test_app/core/utils/service_locator.dart';
import 'package:movie_test_app/core/utils/ui_state.dart';
import 'package:movie_test_app/features/movies/data/repositories/movie_repository.dart';
import 'package:movie_test_app/features/movies/domain/models/movie_model.dart';

class MovieProvider extends ChangeNotifier {
  final MovieRepository _repository = locator<MovieRepository>();
  final ConnectivityService _connectivity = locator<ConnectivityService>();
  StreamSubscription? _connectivitySubscription;

  bool _hasConnection = true;

  bool get hasConnection => _hasConnection;

  UIState<List<MovieModel>> upcomingMoviesState = const InitialState();
  UIState<List<MovieModel>> searchResultsState = const InitialState();
  UIState<Map<int, String>> genresState = const InitialState();
  UIState<String?> trailerState = const InitialState();
  Map<int, String> categoryImages = {};

  int currentUpcomingPage = 1;
  int totalUpcomingPages = 1;
  bool isLoadingMoreUpcoming = false;

  int currentSearchPage = 1;
  int totalSearchPages = 1;
  bool isLoadingMore = false;
  String currentSearchQuery = '';

  MovieProvider() {
    _initConnectivity();
  }

  void _initConnectivity() {
    _connectivitySubscription = _connectivity.onConnectivityChanged((
      isConnected,
    ) {
      if (_hasConnection != isConnected) {
        _hasConnection = isConnected;
        notifyListeners();
      }

      if (isConnected) {
        if (upcomingMoviesState is ErrorState) {
          loadUpcomingMovies();
        }
        if (genresState is ErrorState) {
          loadGenres();
        }
        if (searchResultsState is ErrorState && currentSearchQuery.isNotEmpty) {
          searchMovies(currentSearchQuery);
        }
      }
    });
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  Future<void> loadUpcomingMovies() async {
    if (upcomingMoviesState is LoadingState) {
      return;
    }

    if (!_hasConnection && !await _connectivity.hasInternetConnection()) {
      upcomingMoviesState = const ErrorState(message: 'No internet connection');
      notifyListeners();
      return;
    }

    try {
      currentUpcomingPage = 1;

      upcomingMoviesState = const LoadingState();
      notifyListeners();

      final result = await _connectivity.retryWithBackoff(
        function: () => _repository.getUpcomingMovies(page: 1),
        maxAttempts: 3,
      );

      totalUpcomingPages = result.totalPages;

      if (upcomingMoviesState is LoadingState) {
        upcomingMoviesState = SuccessState(result.movies);
        notifyListeners();
      }
    } catch (e) {
      if (upcomingMoviesState is LoadingState) {
        upcomingMoviesState = ErrorState(message: e.toString());
        notifyListeners();
      }
    }
  }

  Future<void> loadMoreUpcomingMovies() async {
    if (isLoadingMoreUpcoming ||
        currentUpcomingPage >= totalUpcomingPages ||
        upcomingMoviesState is! SuccessState) {
      return;
    }

    if (!_hasConnection && !await _connectivity.hasInternetConnection()) {
      debugPrint('Cannot load more: No internet connection');
      return;
    }

    try {
      isLoadingMoreUpcoming = true;
      notifyListeners();

      final nextPage = currentUpcomingPage + 1;
      final result = await _connectivity.retryWithBackoff(
        function: () => _repository.getUpcomingMovies(page: nextPage),
        maxAttempts: 2,
      );

      if (upcomingMoviesState is SuccessState<List<MovieModel>>) {
        final currentMovies =
            (upcomingMoviesState as SuccessState<List<MovieModel>>).data;
        final updatedMovies = [...currentMovies, ...result.movies];

        upcomingMoviesState = SuccessState(updatedMovies);
        currentUpcomingPage = nextPage;
      }
    } catch (e) {
      debugPrint('Error loading more upcoming movies: $e');
    } finally {
      isLoadingMoreUpcoming = false;
      notifyListeners();
    }
  }

  void clearSearchResults() {
    searchResultsState = const SuccessState([]);
    currentSearchQuery = '';
    currentSearchPage = 1;
    totalSearchPages = 1;
    isLoadingMore = false;
    notifyListeners();
  }

  Future<void> searchMovies(String query) async {
    if (query.length < 2) {
      searchResultsState = const SuccessState([]);
      currentSearchQuery = '';
      notifyListeners();
      return;
    }

    if (!await _connectivity.hasInternetConnection()) {
      searchResultsState = const ErrorState(message: 'No internet connection');
      notifyListeners();
      return;
    }

    try {
      currentSearchQuery = query;
      currentSearchPage = 1;
      searchResultsState = const LoadingState();
      notifyListeners();

      final results = await _connectivity.retryWithBackoff(
        function: () => _repository.searchMovies(query),
        maxAttempts: 2,
      );

      searchResultsState = SuccessState(results);
      notifyListeners();
    } catch (e) {
      searchResultsState = ErrorState(message: e.toString());
      notifyListeners();
    }
  }

  Future<void> loadMoreSearchResults() async {
    if (isLoadingMore ||
        currentSearchPage >= totalSearchPages ||
        currentSearchQuery.isEmpty ||
        searchResultsState is! SuccessState) {
      return;
    }

    try {
      isLoadingMore = true;
      notifyListeners();

      final newResults = await _repository.searchMovies(
        currentSearchQuery,
        page: currentSearchPage + 1,
      );

      if (searchResultsState is SuccessState<List<MovieModel>>) {
        final currentResults =
            (searchResultsState as SuccessState<List<MovieModel>>).data;
        searchResultsState = SuccessState([...currentResults, ...newResults]);
        currentSearchPage++;
      }
    } catch (e) {
      debugPrint('Error loading more results: $e');
    } finally {
      isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> loadGenres() async {
    if (genresState is LoadingState) return;

    try {
      genresState = const LoadingState();
      notifyListeners();

      final genres = await _repository.getGenres();

      if (genresState is LoadingState) {
        genresState = SuccessState(genres);
        notifyListeners();
        await _loadCategoryImages();
      }
    } catch (e) {
      if (genresState is LoadingState) {
        genresState = ErrorState(message: e.toString());
        notifyListeners();
      }
    }
  }

  Future<void> _loadCategoryImages() async {
    try {
      if (genresState is! SuccessState<Map<int, String>>) return;

      final images = await _repository.getCategoryImages();
      categoryImages = images;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading category images: $e');
    }
  }

  Future<void> loadMovieTrailer(int movieId) async {
    try {
      trailerState = const LoadingState();
      notifyListeners();

      final trailerUrl = await _repository.getMovieTrailer(movieId);

      if (trailerState is LoadingState) {
        trailerState = SuccessState(trailerUrl);
        notifyListeners();
      }
    } catch (e) {
      if (trailerState is LoadingState) {
        trailerState = ErrorState(message: e.toString());
        notifyListeners();
      }
    }
  }
}
