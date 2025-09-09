import 'package:flutter/material.dart';

/// Typography constants for DigiaInspector
abstract class InspectorTypography {
  /// Base font
  static const String fontFamily = 'SF Pro Text';

  /// Large Title - Used for main titles
  static const largeTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 34,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.37,
    height: 1.18,
  );

  /// Title 1 - Section headers
  static const title1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.36,
    height: 1.21,
  );

  /// Title 2 - Subsection headers
  static const title2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.35,
    height: 1.27,
  );

  /// Title 3 - Card headers
  static const title3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.38,
    height: 1.20,
  );

  /// Headline - Important content
  static const headline = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.41,
    height: 1.29,
  );

  /// Body - Main content text
  static const body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 17,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.41,
    height: 1.29,
  );

  /// Callout - Secondary content
  static const callout = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.32,
    height: 1.31,
  );

  /// Subhead - List items, descriptions
  static const subhead = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.24,
    height: 1.33,
  );

  /// Footnote - Timestamps, metadata
  static const footnote = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.08,
    height: 1.38,
  );

  /// Caption 1 - Small labels
  static const caption1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.33,
  );

  /// Caption 2 - Very small text
  static const caption2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.07,
    height: 1.36,
  );

  /// Monospace - Code/JSON display
  static const monospace = TextStyle(
    fontFamily: 'SF Mono',
    fontSize: 13,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.38,
  );

  /// Bold variants
  static const headlineBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 17,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.41,
    height: 1.29,
  );

  /// Callout bold
  static const calloutBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.32,
    height: 1.31,
  );

  /// Subhead bold
  static const subheadBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.24,
    height: 1.33,
  );

  /// Footnote bold
  static const footnoteBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.08,
    height: 1.38,
  );

  /// Caption 1 bold
  static const caption1Bold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.33,
  );
}
