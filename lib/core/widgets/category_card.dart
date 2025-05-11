import 'package:flutter/material.dart';
import 'package:movie_test_app/core/utils/responsive_size_util.dart';

class CategoryCard extends StatelessWidget {
  final String category;
  final String? imageUrl;
  final VoidCallback? onTap;

  const CategoryCard({
    super.key,
    required this.category,
    this.imageUrl,
    this.onTap,
  });

  Color _getCategoryColor(String category) {
    final List<Color> predefinedColors = [
      const Color(0xFF4D8FAC),
      const Color(0xFF2F2F2F),
      const Color(0xFF4A7B92),
      const Color(0xFF333333),
      const Color(0xFF8B5A3D),
      const Color(0xFF5F7A8A),
      const Color(0xFF5D6D7E),
      const Color(0xFF1E1E1E),
      const Color(0xFF7D6E5D),
      const Color(0xFF566573),
    ];
    return predefinedColors[category.hashCode % predefinedColors.length];
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: ResponsiveSizeUtil.adaptiveBorderRadius(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (imageUrl != null)
              Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(color: _getCategoryColor(category));
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: _getCategoryColor(category),
                    child: Center(
                      child: SizedBox(
                        width: ResponsiveSizeUtil.adaptiveWidth(24),
                        height: ResponsiveSizeUtil.adaptiveHeight(24),
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                },
              )
            else
              Container(color: _getCategoryColor(category)),

            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.center,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.9)],
                  stops: const [0.0, 0.8],
                ),
              ),
            ),

            Positioned(
              left: ResponsiveSizeUtil.adaptiveWidth(16),
              bottom: ResponsiveSizeUtil.adaptiveHeight(16),
              child: Text(
                category,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: ResponsiveSizeUtil.adaptiveFontSize(16),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
