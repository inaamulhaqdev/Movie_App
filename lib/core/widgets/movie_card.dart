import 'package:flutter/material.dart';
import 'package:movie_test_app/core/constants/api_constants.dart';
import 'package:movie_test_app/core/utils/responsive_size_util.dart';
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
        margin: EdgeInsets.only(bottom: ResponsiveSizeUtil.adaptiveHeight(16)),
        height: ResponsiveSizeUtil.adaptiveHeight(200),
        decoration: BoxDecoration(
          borderRadius: ResponsiveSizeUtil.adaptiveBorderRadius(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: ResponsiveSizeUtil.adaptiveWidth(8),
              offset: Offset(0, ResponsiveSizeUtil.adaptiveHeight(4)),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: ResponsiveSizeUtil.adaptiveBorderRadius(16),
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
                  child: Icon(
                    Icons.movie,
                    size: ResponsiveSizeUtil.adaptiveWidth(40),
                  ),
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
                left: ResponsiveSizeUtil.adaptiveWidth(20),
                bottom: ResponsiveSizeUtil.adaptiveHeight(24),
                child: SizedBox(
                  width: ResponsiveSizeUtil.wp(70), // Use 70% of screen width
                  child: Text(
                    movie.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: ResponsiveSizeUtil.adaptiveFontSize(18),
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
