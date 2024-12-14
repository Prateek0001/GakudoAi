import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ResponsiveHelper {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600.w;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600.w &&
      MediaQuery.of(context).size.width < 1200.w;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1200.w;

  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double screenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  // Get dynamic padding based on screen size
  static EdgeInsets screenPadding(BuildContext context) {
    if (isMobile(context)) {
      return EdgeInsets.all(16.w);
    } else if (isTablet(context)) {
      return EdgeInsets.all(24.w);
    } else {
      return EdgeInsets.all(32.w);
    }
  }

  // Get dynamic width for cards and containers
  static double getContentWidth(BuildContext context) {
    final width = screenWidth(context);
    if (isDesktop(context)) {
      return width * 0.5;
    } else if (isTablet(context)) {
      return width * 0.7;
    } else {
      return width * 0.9;
    }
  }

  // Get dynamic font size
  static double getFontSize(BuildContext context, double baseFontSize) {
    return baseFontSize.sp;
  }

  // Get dynamic spacing
  static double getSpacing(BuildContext context, double baseSpacing) {
    return baseSpacing.w;
  }

  // Get dynamic radius
  static double getRadius(double baseRadius) {
    return baseRadius.r;
  }

  // Get dynamic icon size
  static double getIconSize(double baseSize) {
    return baseSize.r;
  }

  // Get dynamic button height
  static double getButtonHeight(double baseHeight) {
    return baseHeight.h;
  }

  // Get dynamic input field height
  static double getInputHeight(double baseHeight) {
    return baseHeight.h;
  }
} 