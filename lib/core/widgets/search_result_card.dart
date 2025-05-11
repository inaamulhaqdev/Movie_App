import 'package:flutter/material.dart';
import 'package:movie_test_app/core/constants/api_constants.dart';
import 'package:movie_test_app/core/constants/app_assets.dart';
import 'package:movie_test_app/core/constants/app_colors.dart';
import 'package:movie_test_app/features/movies/domain/models/movie_model.dart';

class SearchResultCard extends StatelessWidget {
  final MovieModel movie;
  final String category;
  final VoidCallback? onTap;
  final VoidCallback? onMoreTap;

  const SearchResultCard({
    super.key,
    required this.movie,
    required this.category,
    this.onTap,
    this.onMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child:
                  movie.posterPath != null
                      ? Image.network(
                        '${ApiConstants.baseImageUrl}${movie.posterPath}',
                        width: 130,
                        height: 100,
                        fit: BoxFit.fitWidth,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 70,
                            height: 100,
                            color: Colors.grey[300],
                            child: const Icon(Icons.movie),
                          );
                        },
                      )
                      : Container(
                        width: 70,
                        height: 100,
                        color: Colors.grey[300],
                        child: const Icon(Icons.movie),
                      ),
            ),
            const SizedBox(width: 16),

            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 14),
                        Text(
                          movie.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.black,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          category,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.dividerGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Image.asset(
                    AppAssets.threeDots,
                    width: 20,
                    height: 20,
                    color: AppColors.accentBlue,
                  ),
                ],
              ),
            ),

            if (onMoreTap != null)
              IconButton(
                icon: Icon(Icons.more_horiz, color: Colors.blue[300]),
                onPressed: onMoreTap,
              ),
          ],
        ),
      ),
    );
  }
}
