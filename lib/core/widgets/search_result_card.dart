import 'package:flutter/material.dart';
import 'package:movie_test_app/core/constants/api_constants.dart';
import 'package:movie_test_app/core/constants/app_assets.dart';
import 'package:movie_test_app/core/constants/app_colors.dart';
import 'package:movie_test_app/core/utils/responsive_size_util.dart';
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
        margin: EdgeInsets.only(bottom: ResponsiveSizeUtil.adaptiveHeight(20)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: ResponsiveSizeUtil.adaptiveBorderRadius(10),
              child:
                  movie.posterPath != null
                      ? Image.network(
                        '${ApiConstants.baseImageUrl}${movie.posterPath}',
                        width: ResponsiveSizeUtil.adaptiveWidth(130),
                        height: ResponsiveSizeUtil.adaptiveHeight(100),
                        fit: BoxFit.fitWidth,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: ResponsiveSizeUtil.adaptiveWidth(70),
                            height: ResponsiveSizeUtil.adaptiveHeight(100),
                            color: Colors.grey[300],
                            child: Icon(
                              Icons.movie,
                              size: ResponsiveSizeUtil.adaptiveWidth(24),
                            ),
                          );
                        },
                      )
                      : Container(
                        width: ResponsiveSizeUtil.adaptiveWidth(70),
                        height: ResponsiveSizeUtil.adaptiveHeight(100),
                        color: Colors.grey[300],
                        child: Icon(
                          Icons.movie,
                          size: ResponsiveSizeUtil.adaptiveWidth(24),
                        ),
                      ),
            ),
            SizedBox(width: ResponsiveSizeUtil.adaptiveWidth(16)),

            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: ResponsiveSizeUtil.adaptiveHeight(14)),
                        Text(
                          movie.title,
                          style: TextStyle(
                            fontSize: ResponsiveSizeUtil.adaptiveFontSize(16),
                            fontWeight: FontWeight.w500,
                            color: AppColors.black,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: ResponsiveSizeUtil.adaptiveHeight(4)),
                        Text(
                          category,
                          style: TextStyle(
                            fontSize: ResponsiveSizeUtil.adaptiveFontSize(12),
                            color: AppColors.dividerGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: ResponsiveSizeUtil.adaptiveWidth(8)),
                  Image.asset(
                    AppAssets.threeDots,
                    width: ResponsiveSizeUtil.adaptiveWidth(20),
                    height: ResponsiveSizeUtil.adaptiveHeight(20),
                    color: AppColors.accentBlue,
                  ),
                ],
              ),
            ),

            if (onMoreTap != null)
              IconButton(
                icon: Icon(
                  Icons.more_horiz,
                  color: Colors.blue[300],
                  size: ResponsiveSizeUtil.adaptiveWidth(24),
                ),
                onPressed: onMoreTap,
              ),
          ],
        ),
      ),
    );
  }
}
