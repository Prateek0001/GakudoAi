import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppConstants {
  // API Keys
  static const String openAiKey = 'YOUR_OPENAI_API_KEY_HERE';
  static const String openAiModel = 'gpt-3.5-turbo';
  static const String razorpayKey = 'YOUR_RAZORPAY_KEY_HERE';
  
  // Font Sizes
  static double get headingLarge => 24.sp;
  static double get headingMedium => 20.sp;
  static double get headingSmall => 18.sp;
  static double get bodyLarge => 16.sp;
  static double get bodyMedium => 14.sp;
  static double get bodySmall => 12.sp;
  static double get labelLarge => 16.sp;
  static double get labelMedium => 14.sp;
  static double get labelSmall => 12.sp;

  // Spacing
  static double get spacingXXS => 4.w;
  static double get spacingXS => 8.w;
  static double get spacingS => 12.w;
  static double get spacingM => 16.w;
  static double get spacingL => 24.w;
  static double get spacingXL => 32.w;
  static double get spacingXXL => 48.w;

  // Border Radius
  static double get radiusXS => 4.r;
  static double get radiusS => 8.r;
  static double get radiusM => 12.r;
  static double get radiusL => 16.r;
  static double get radiusXL => 24.r;
  static double get radiusXXL => 32.r;

  // Icon Sizes
  static double get iconXS => 16.r;
  static double get iconS => 20.r;
  static double get iconM => 24.r;
  static double get iconL => 32.r;
  static double get iconXL => 48.r;

  // Input Field Heights
  static double get inputHeightS => 40.h;
  static double get inputHeightM => 48.h;
  static double get inputHeightL => 56.h;

  // Button Heights
  static double get buttonHeightS => 32.h;
  static double get buttonHeightM => 40.h;
  static double get buttonHeightL => 48.h;

  // Container Widths
  static double get containerWidthS => 0.3.sw; // 30% of screen width
  static double get containerWidthM => 0.5.sw; // 50% of screen width
  static double get containerWidthL => 0.7.sw; // 70% of screen width
  static double get containerWidthXL => 0.9.sw; // 90% of screen width

  // Container Heights
  static double get containerHeightS => 0.3.sh; // 30% of screen height
  static double get containerHeightM => 0.5.sh; // 50% of screen height
  static double get containerHeightL => 0.7.sh; // 70% of screen height
  static double get containerHeightXL => 0.9.sh; // 90% of screen height

  // Chat UI Constants
  static double get chatInputHeight => 60.h;
  static double get maxMessageWidth => 0.8.sw; // 80% of screen width
  static double get chatAvatarSize => 40.r;
  static double get chatBubblePadding => 12.w;
  static double get chatBubbleRadius => 16.r;

  // Profile Image Sizes
  static double get profileImageS => 48.r;
  static double get profileImageM => 64.r;
  static double get profileImageL => 96.r;
  static double get profileImageXL => 128.r;

  // Card Dimensions
  static double get cardPadding => 16.w;
  static double get cardMargin => 8.w;
  static double get cardRadius => 12.r;
  static double get cardElevation => 2.r;

  // List Item Heights
  static double get listItemHeightS => 48.h;
  static double get listItemHeightM => 64.h;
  static double get listItemHeightL => 80.h;

  // Bottom Sheet Heights
  static double get bottomSheetHeightS => 0.3.sh;
  static double get bottomSheetHeightM => 0.5.sh;
  static double get bottomSheetHeightL => 0.7.sh;

  // Dialog Dimensions
  static double get dialogWidthS => 0.7.sw;
  static double get dialogWidthM => 0.8.sw;
  static double get dialogWidthL => 0.9.sw;
  static double get dialogPadding => 24.w;

  // App Bar Height
  static double get appBarHeight => 56.h;

  // Bottom Navigation Bar Height
  static double get bottomNavBarHeight => 56.h;

  // Drawer Width
  static double get drawerWidth => 0.7.sw;
} 