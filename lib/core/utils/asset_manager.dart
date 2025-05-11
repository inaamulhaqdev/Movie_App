import 'package:flutter/material.dart';

class AssetManager {
  static String getOptimizedAssetPath(BuildContext context, String basePath) {
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;

    final lastDot = basePath.lastIndexOf('.');
    if (lastDot == -1) return basePath;

    final fileName = basePath.substring(0, lastDot);
    final extension = basePath.substring(lastDot);

    String resolution;
    if (pixelRatio <= 1.0) {
      resolution = '';
    } else if (pixelRatio <= 2.0) {
      resolution = '@2x';
    } else {
      resolution = '@3x';
    }

    final optimizedPath = '$fileName$resolution$extension';

    return optimizedPath;
  }

  static int getOptimalCacheWidth(BuildContext context, int baseWidth) {
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    return (baseWidth * pixelRatio).round();
  }

  static int getOptimalCacheHeight(BuildContext context, int baseHeight) {
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    return (baseHeight * pixelRatio).round();
  }
}
