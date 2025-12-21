import 'package:digia_inspector/src/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Typography factory for DigiaInspector
///
/// Access via `context.inspectorTypography`
class InspectorTypography {
  InspectorTypography._(this._context);
  final BuildContext _context;

  InspectorColorsExtension get _colors => _context.inspectorColors;

  /// The font family for the text
  static const String fontFamily = 'SF Pro Text';

  /// The font family for the monospace text
  static const String monoFontFamily = 'SF Mono';

  TextStyle _base({
    required double fontSize,
    required FontWeight fontWeight,
    required double letterSpacing,
    required double height,
    Color? color,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: height,
      color: color ?? _colors.contentPrimary,
    );
  }

  /// The style for the large title
  TextStyle get largeTitle => _base(
        fontSize: 34,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.37,
        height: 1.18,
      );

  /// The style for the title 1
  TextStyle get title1 => _base(
        fontSize: 28,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.36,
        height: 1.21,
      );

  /// The style for the title 2
  TextStyle get title2 => _base(
        fontSize: 22,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.35,
        height: 1.27,
      );

  /// The style for the title 3
  TextStyle get title3 => _base(
        fontSize: 20,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.38,
        height: 1.20,
      );

  /// The style for the headline
  TextStyle get headline => _base(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.41,
        height: 1.29,
      );

  /// The style for the body
  TextStyle get body => _base(
        fontSize: 17,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.41,
        height: 1.29,
      );

  /// The style for the callout
  TextStyle get callout => _base(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.32,
        height: 1.31,
      );

  /// The style for the subhead
  TextStyle get subhead => _base(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.24,
        height: 1.33,
      );

  /// The style for the footnote
  TextStyle get footnote => _base(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.08,
        height: 1.38,
      );

  /// The style for the caption 1
  TextStyle get caption1 => _base(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.33,
      );

  /// The style for the caption 2
  TextStyle get caption2 => _base(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.07,
        height: 1.36,
      );

  /// The style for the monospace
  TextStyle get monospace {
    return TextStyle(
      fontFamily: monoFontFamily,
      fontSize: 13,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1.38,
      color: _colors.contentPrimary,
    );
  }

  // Bold variants

  /// The style for the headline bold
  TextStyle get headlineBold => _base(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.41,
        height: 1.29,
      );

  /// The style for the callout bold
  TextStyle get calloutBold => _base(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.32,
        height: 1.31,
      );

  /// The style for the subhead bold
  TextStyle get subheadBold => _base(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.24,
        height: 1.33,
      );

  /// The style for the footnote bold
  TextStyle get footnoteBold => _base(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.08,
        height: 1.38,
      );

  /// The style for the caption 1 bold
  TextStyle get caption1Bold => _base(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.33,
      );
}

/// Extension for easy access to the inspector typography
extension InspectorTypographyGetter on BuildContext {
  /// The inspector typography
  InspectorTypography get inspectorTypography => InspectorTypography._(this);
}
