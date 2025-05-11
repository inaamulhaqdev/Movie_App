import 'package:flutter/material.dart';
import 'package:movie_test_app/core/constants/api_constants.dart';
import 'package:movie_test_app/core/widgets/optimized_cached_image.dart';
import 'package:movie_test_app/core/widgets/optimized_container.dart';
import 'package:movie_test_app/features/movies/domain/models/movie_model.dart';

class MovieCard extends StatelessWidget {
  final MovieModel movie;
  final VoidCallback? onTap;

  const MovieCard({super.key, required this.movie, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: OptimizedContainer(
        margin: const EdgeInsets.only(bottom: 24),
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (movie.backdropPath != null)
                OptimizedCachedImage(
                  imageUrl: '${ApiConstants.baseImageUrl}${movie.backdropPath}',
                  fit: BoxFit.cover,
                  memCacheWidth: 600,
                  memCacheHeight: 300,
                  heroTag: 'movie-${movie.id}',
                  fadeInDuration: const Duration(milliseconds: 200),
                )
              else
                Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.movie),
                ),

              OptimizedContainer(
                useRepaintBoundary: false,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.center,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.9)],
                    stops: const [0.1, 0.8],
                  ),
                ),
                child: const SizedBox.expand(),
              ),

              Positioned(
                left: 20,
                bottom: 24,
                child: Text(
                  movie.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
