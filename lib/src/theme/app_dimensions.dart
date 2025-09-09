import 'package:flutter/material.dart';

/// Common spacing constants for consistent UI layout
abstract class AppSpacing {
  /// Base spacing unit
  static const double unit = 8;

  /// Micro spacing
  static const double xs = unit * 0.5; // 4px

  /// Small spacing
  static const double sm = unit; // 8px

  /// Medium spacing
  static const double md = unit * 2; // 16px

  /// Large spacing
  static const double lg = unit * 3; // 24px

  /// Extra large spacing
  static const double xl = unit * 4; // 32px

  /// Extra extra large spacing
  static const double xxl = unit * 6; // 48px

  // Padding values
  /// Extra small padding
  static const EdgeInsets paddingXS = EdgeInsets.all(xs);

  /// Small padding
  static const EdgeInsets paddingSM = EdgeInsets.all(sm);

  /// Medium padding
  static const EdgeInsets paddingMD = EdgeInsets.all(md);

  /// Large padding
  static const EdgeInsets paddingLG = EdgeInsets.all(lg);

  /// Extra large padding
  static const EdgeInsets paddingXL = EdgeInsets.all(xl);

  /// Horizontal padding
  static const EdgeInsets paddingHorizontalXS = EdgeInsets.symmetric(
    horizontal: xs,
  );

  /// Small horizontal padding
  static const EdgeInsets paddingHorizontalSM = EdgeInsets.symmetric(
    horizontal: sm,
  );

  /// Medium horizontal padding
  static const EdgeInsets paddingHorizontalMD = EdgeInsets.symmetric(
    horizontal: md,
  );

  /// Large horizontal padding
  static const EdgeInsets paddingHorizontalLG = EdgeInsets.symmetric(
    horizontal: lg,
  );

  /// Vertical padding
  static const EdgeInsets paddingVerticalXS = EdgeInsets.symmetric(
    vertical: xs,
  );

  /// Small vertical padding
  static const EdgeInsets paddingVerticalSM = EdgeInsets.symmetric(
    vertical: sm,
  );

  /// Medium vertical padding
  static const EdgeInsets paddingVerticalMD = EdgeInsets.symmetric(
    vertical: md,
  );

  /// Large vertical padding
  static const EdgeInsets paddingVerticalLG = EdgeInsets.symmetric(
    vertical: lg,
  );
}

/// Border radius constants
abstract class AppBorderRadius {
  /// Extra small border radius
  static const double xs = 4;

  /// Small border radius
  static const double sm = 6;

  /// Medium border radius
  static const double md = 8;

  /// Large border radius
  static const double lg = 12;

  /// Extra large border radius
  static const double xl = 16;

  /// Extra extra large border radius
  static const double xxl = 24;

  // BorderRadius objects
  /// Extra small border radius
  static const BorderRadius radiusXS = BorderRadius.all(Radius.circular(xs));

  /// Small border radius
  static const BorderRadius radiusSM = BorderRadius.all(Radius.circular(sm));

  /// Medium border radius
  static const BorderRadius radiusMD = BorderRadius.all(Radius.circular(md));

  /// Large border radius
  static const BorderRadius radiusLG = BorderRadius.all(Radius.circular(lg));

  /// Extra large border radius
  static const BorderRadius radiusXL = BorderRadius.all(Radius.circular(xl));

  /// Extra extra large border radius
  static const BorderRadius radiusXXL = BorderRadius.all(Radius.circular(xxl));
}

/// Elevation and shadow constants
abstract class AppElevation {
  /// Small shadow
  static const BoxShadow shadowSM = BoxShadow(
    color: Color(0x0A000000),
    offset: Offset(0, 1),
    blurRadius: 2,
  );

  /// Medium shadow
  static const BoxShadow shadowMD = BoxShadow(
    color: Color(0x14000000),
    offset: Offset(0, 2),
    blurRadius: 8,
  );

  /// Large shadow
  static const BoxShadow shadowLG = BoxShadow(
    color: Color(0x1F000000),
    offset: Offset(0, 4),
    blurRadius: 16,
  );

  // Shadow lists for multiple shadows
  /// Card shadow
  static const List<BoxShadow> cardShadow = [shadowSM];

  /// Modal shadow
  static const List<BoxShadow> modalShadow = [shadowLG];
}

/// Animation duration constants
abstract class AppAnimations {
  /// Fast animation duration
  static const Duration fast = Duration(milliseconds: 150);

  /// Medium animation duration
  static const Duration medium = Duration(milliseconds: 250);

  /// Slow animation duration
  static const Duration slow = Duration(milliseconds: 350);

  // Specific animation durations
  /// Button press animation duration
  static const Duration buttonPress = fast;

  /// Modal transition animation duration
  static const Duration modalTransition = medium;

  /// List item animation duration
  static const Duration listItemAnimation = fast;
}

/// Icon size constants
abstract class AppIconSizes {
  /// Extra small icon size
  static const double xs = 12;

  /// Small icon size
  static const double sm = 16;

  /// Medium icon size
  static const double md = 20;

  /// Large icon size
  static const double lg = 24;

  /// Extra large icon size
  static const double xl = 32;
}
