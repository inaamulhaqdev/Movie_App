class MovieModel {
  final int id;
  final String title;
  final String? posterPath;
  final String? backdropPath;
  final String overview;
  final List<int> genreIds;
  final String releaseDate;
  final String mediaType;

  MovieModel({
    required this.id,
    required this.title,
    this.posterPath,
    this.backdropPath,
    required this.overview,
    required this.genreIds,
    required this.releaseDate,
    required this.mediaType,
  });

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    return MovieModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? json['name'] ?? '',
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
      overview: json['overview'] ?? '',
      genreIds: List<int>.from(json['genre_ids'] ?? []),
      releaseDate: json['release_date'] ?? json['first_air_date'] ?? '',
      mediaType: json['media_type'] ?? 'movie',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'poster_path': posterPath,
      'backdrop_path': backdropPath,
      'overview': overview,
      'genre_ids': genreIds,
      'release_date': releaseDate,
      'media_type': mediaType,
    };
  }

  String get formattedReleaseDate {
    if (releaseDate.isEmpty) return 'Release date unknown';
    return 'Released ${releaseDate.split('-')[0]}';
  }
}
