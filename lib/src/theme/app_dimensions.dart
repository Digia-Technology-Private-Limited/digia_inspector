import 'package:flutter/material.dart';

/// Common spacing constants for consistent UI layout
abstract class InspectorSpacing {
  // Base spacing unit
  static const double unit = 8.0;

  // Micro spacing
  static const double xs = unit * 0.5; // 4px

  // Small spacing
  static const double sm = unit; // 8px

  // Medium spacing
  static const double md = unit * 2; // 16px

  // Large spacing
  static const double lg = unit * 3; // 24px

  // Extra large spacing
  static const double xl = unit * 4; // 32px

  // Extra extra large spacing
  static const double xxl = unit * 6; // 48px

  // Padding values
  static const EdgeInsets paddingXS = EdgeInsets.all(xs);
  static const EdgeInsets paddingSM = EdgeInsets.all(sm);
  static const EdgeInsets paddingMD = EdgeInsets.all(md);
  static const EdgeInsets paddingLG = EdgeInsets.all(lg);
  static const EdgeInsets paddingXL = EdgeInsets.all(xl);

  // Horizontal padding
  static const EdgeInsets paddingHorizontalXS = EdgeInsets.symmetric(
    horizontal: xs,
  );
  static const EdgeInsets paddingHorizontalSM = EdgeInsets.symmetric(
    horizontal: sm,
  );
  static const EdgeInsets paddingHorizontalMD = EdgeInsets.symmetric(
    horizontal: md,
  );
  static const EdgeInsets paddingHorizontalLG = EdgeInsets.symmetric(
    horizontal: lg,
  );

  // Vertical padding
  static const EdgeInsets paddingVerticalXS = EdgeInsets.symmetric(
    vertical: xs,
  );
  static const EdgeInsets paddingVerticalSM = EdgeInsets.symmetric(
    vertical: sm,
  );
  static const EdgeInsets paddingVerticalMD = EdgeInsets.symmetric(
    vertical: md,
  );
  static const EdgeInsets paddingVerticalLG = EdgeInsets.symmetric(
    vertical: lg,
  );
}

/// Border radius constants
abstract class InspectorBorderRadius {
  static const double xs = 4.0;
  static const double sm = 6.0;
  static const double md = 8.0;
  static const double lg = 12.0;
  static const double xl = 16.0;
  static const double xxl = 24.0;

  // BorderRadius objects
  static const BorderRadius radiusXS = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius radiusSM = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius radiusMD = BorderRadius.all(Radius.circular(md));
  static const BorderRadius radiusLG = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius radiusXL = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius radiusXXL = BorderRadius.all(Radius.circular(xxl));
}

/// Elevation and shadow constants
abstract class InspectorElevation {
  static const BoxShadow shadowSM = BoxShadow(
    color: Color(0x0A000000),
    offset: Offset(0, 1),
    blurRadius: 2,
    spreadRadius: 0,
  );

  static const BoxShadow shadowMD = BoxShadow(
    color: Color(0x14000000),
    offset: Offset(0, 2),
    blurRadius: 8,
    spreadRadius: 0,
  );

  static const BoxShadow shadowLG = BoxShadow(
    color: Color(0x1F000000),
    offset: Offset(0, 4),
    blurRadius: 16,
    spreadRadius: 0,
  );

  // Shadow lists for multiple shadows
  static const List<BoxShadow> cardShadow = [shadowSM];
  static const List<BoxShadow> modalShadow = [shadowLG];
}

/// Animation duration constants
abstract class InspectorAnimations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 350);

  // Specific animation durations
  static const Duration buttonPress = fast;
  static const Duration modalTransition = medium;
  static const Duration listItemAnimation = fast;
}

/// Icon size constants
abstract class InspectorIconSizes {
  static const double xs = 12.0;
  static const double sm = 16.0;
  static const double md = 20.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
}
