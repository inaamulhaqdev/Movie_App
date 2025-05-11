import 'package:flutter/material.dart';
import 'package:movie_test_app/core/constants/app_colors.dart';
import 'package:movie_test_app/core/utils/responsive_size_util.dart';

class GenreChip extends StatelessWidget {
  final String genre;

  const GenreChip({super.key, required this.genre});

  Color _getGenreColor(String genre) {
    switch (genre.toLowerCase()) {
      case 'action':
        return AppColors.teal;
      case 'adventure':
        return Colors.orange;
      case 'animation':
        return Colors.yellow[700]!;
      case 'comedy':
        return Colors.green;
      case 'crime':
        return Colors.brown;
      case 'documentary':
        return Colors.blue;
      case 'drama':
        return Colors.purple;
      case 'family':
        return Colors.teal;
      case 'fantasy':
        return Colors.indigo;
      case 'history':
        return Colors.amber;
      case 'horror':
        return Colors.red[900]!;
      case 'music':
        return Colors.pink;
      case 'mystery':
        return Colors.deepPurple;
      case 'romance':
        return Colors.red[300]!;
      case 'fiction':
        return AppColors.gold;
      case 'sci-fi':
        return AppColors.purple;
      case 'thriller':
        return AppColors.pink;
      case 'tv movie':
        return Colors.cyan;
      case 'war':
        return Colors.brown[700]!;
      case 'western':
        return Colors.orange[900]!;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Chip(
      padding: ResponsiveSizeUtil.adaptivePadding(horizontal: 8, vertical: 0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          ResponsiveSizeUtil.adaptiveWidth(50),
        ),
      ),
      side: const BorderSide(color: Colors.white, width: 0),
      label: Text(
        genre,
        style: TextStyle(
          fontSize: ResponsiveSizeUtil.adaptiveFontSize(12),
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: _getGenreColor(genre),
    );
  }
}
