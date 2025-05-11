import 'package:movie_test_app/core/utils/exceptions.dart';

class Helpers {
  static String getErrorMessage(dynamic error) {
    if (error is NetworkException) {
      return 'Network error. Please check your internet connection.';
    } else if (error is ApiException) {
      return 'API error: ${error.message}';
    } else if (error is CacheException) {
      return 'Cache error: ${error.message}';
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  static String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) {
      return 'Release date unknown';
    }

    try {
      final date = DateTime.parse(dateStr);
      return 'Released ${date.year}';
    } catch (e) {
      return 'Release date unknown';
    }
  }

  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    }
    return '${text.substring(0, maxLength)}...';
  }
}
