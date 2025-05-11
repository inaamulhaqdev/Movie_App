import 'dart:math';
import 'package:flutter/material.dart';

class ResponsiveSizeUtil {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late double blockSizeHorizontal;
  static late double blockSizeVertical;
  static late double safeAreaHorizontal;
  static late double safeAreaVertical;
  static late double safeBlockHorizontal;
  static late double safeBlockVertical;
  static late double fontScale;
  static late double textScaleFactor;

  // Reference size based on iPhone 12 Pro - 390 x 844
  static const double _designWidth = 390.0;
  static const double _designHeight = 844.0;

  static void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    textScaleFactor = _mediaQueryData.textScaleFactor;
    fontScale = min(screenWidth / _designWidth, screenHeight / _designHeight);

    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;

    safeAreaHorizontal =
        _mediaQueryData.padding.left + _mediaQueryData.padding.right;
    safeAreaVertical =
        _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;

    safeBlockHorizontal = (screenWidth - safeAreaHorizontal) / 100;
    safeBlockVertical = (screenHeight - safeAreaVertical) / 100;
  }

  static double hp(double percentage) {
    // Get percentage of screen height
    return blockSizeVertical * percentage;
  }

  static double wp(double percentage) {
    // Get percentage of screen width
    return blockSizeHorizontal * percentage;
  }

  static double adaptiveHeight(double height) {
    // Adapt height based on screen size
    return (height / _designHeight) * screenHeight;
  }

  static double adaptiveWidth(double width) {
    // Adapt width based on screen size
    return (width / _designWidth) * screenWidth;
  }

  static double adaptiveFontSize(double size) {
    // Adapt font size based on screen size with a minimum size
    return max(size * fontScale, size * 0.85);
  }

  static EdgeInsets adaptivePadding({
    double horizontal = 0,
    double vertical = 0,
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
    double all = 0,
  }) {
    // If 'all' parameter is provided, it takes precedence
    if (all > 0) {
      return EdgeInsets.all(adaptiveWidth(all));
    }

    // Convert specific edges if provided
    if (left > 0 || top > 0 || right > 0 || bottom > 0) {
      return EdgeInsets.only(
        left: left > 0 ? adaptiveWidth(left) : 0,
        top: top > 0 ? adaptiveHeight(top) : 0,
        right: right > 0 ? adaptiveWidth(right) : 0,
        bottom: bottom > 0 ? adaptiveHeight(bottom) : 0,
      );
    }

    // Convert horizontal and vertical paddings
    return EdgeInsets.symmetric(
      horizontal: horizontal > 0 ? adaptiveWidth(horizontal) : 0,
      vertical: vertical > 0 ? adaptiveHeight(vertical) : 0,
    );
  }

  static BorderRadius adaptiveBorderRadius(double radius) {
    return BorderRadius.circular(adaptiveWidth(radius));
  }

  // Shorthand for media query viewPadding and padding
  static EdgeInsets get screenPadding => _mediaQueryData.padding;
  static EdgeInsets get viewPadding => _mediaQueryData.viewPadding;
  static EdgeInsets get viewInsets => _mediaQueryData.viewInsets;
}
