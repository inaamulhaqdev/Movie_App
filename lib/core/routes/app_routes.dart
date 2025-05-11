import 'package:flutter/material.dart';
import 'package:movie_test_app/features/movies/domain/models/movie_model.dart';
import 'package:movie_test_app/screens/homepage.dart';
import 'package:movie_test_app/screens/movie_details_screen.dart';
import 'package:movie_test_app/screens/movie_ticket_screen.dart';
import 'package:movie_test_app/screens/search_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String search = '/search';
  static const String movieDetails = '/movie-details';
  static const String movieTicket = '/movie-ticket';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case search:
        return MaterialPageRoute(builder: (_) => const SearchScreen());
      case movieTicket:
        final args = settings.arguments as MovieTicketArguments;
        return MaterialPageRoute(
          builder:
              (_) =>
                  MovieTicketScreen(title: args.title, movieId: args.movieId),
        );
      case movieDetails:
        final args = settings.arguments as MovieDetailsArguments;
        return MaterialPageRoute(
          builder:
              (_) => MovieDetailsScreen(
                title: args.title,
                releaseDate: args.releaseDate,
                overview: args.overview,
                imageUrl: args.imageUrl,
                genres: args.genres,
                movieId: args.movieId,
              ),
        );
      default:
        return MaterialPageRoute(
          builder:
              (_) => Scaffold(
                body: Center(
                  child: Text('No route defined for ${settings.name}'),
                ),
              ),
        );
    }
  }
}

class MovieDetailsArguments {
  final String title;
  final String releaseDate;
  final String overview;
  final String imageUrl;
  final List<String> genres;
  final int movieId;

  MovieDetailsArguments({
    required this.title,
    required this.releaseDate,
    required this.overview,
    required this.imageUrl,
    required this.genres,
    required this.movieId,
  });

  factory MovieDetailsArguments.fromMovie(
    MovieModel movie,
    List<String> genres,
  ) {
    return MovieDetailsArguments(
      title: movie.title,
      releaseDate: movie.formattedReleaseDate,
      overview: movie.overview,
      imageUrl:
          movie.backdropPath != null
              ? 'https://image.tmdb.org/t/p/w500${movie.backdropPath}'
              : '',
      genres: genres,
      movieId: movie.id,
    );
  }
}

class MovieTicketArguments {
  final String title;
  final int movieId;

  MovieTicketArguments({required this.title, required this.movieId});

  factory MovieTicketArguments.fromMovie(MovieModel movie) {
    return MovieTicketArguments(title: movie.title, movieId: movie.id);
  }
}
