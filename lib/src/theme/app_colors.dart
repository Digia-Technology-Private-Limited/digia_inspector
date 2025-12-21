import 'package:flutter/material.dart';

/// Color extension for DigiaInspector
///
/// Replaces static AppColors with theme-aware colors that support Light/Dark modes.
@immutable
class InspectorColorsExtension
    extends ThemeExtension<InspectorColorsExtension> {
  /// Constructor
  const InspectorColorsExtension({
    required this.backgroundPrimary,
    required this.backgroundSecondary,
    required this.backgroundTertiary,
    required this.backgroundOverlay,
    required this.surfaceElevated,
    required this.surfacePressed,
    required this.surfaceBorder,
    required this.borderDefault,
    required this.contentPrimary,
    required this.contentSecondary,
    required this.contentTertiary,
    required this.contentPlaceholder,
    required this.statusSuccess,
    required this.statusWarning,
    required this.statusError,
    required this.statusInfo,
    required this.methodGet,
    required this.methodPost,
    required this.methodPut,
    required this.methodDelete,
    required this.methodPatch,
    required this.methodHead,
    required this.methodOptions,
    required this.accent,
    required this.accentPressed,
    required this.separator,
    required this.shadow,
    required this.searchBackground,
    required this.chevronColor,
  });

  // Background Colors
  /// The primary background color
  final Color backgroundPrimary;

  /// The secondary background color
  final Color backgroundSecondary;

  /// The tertiary background color
  final Color backgroundTertiary;

  /// The overlay background color
  final Color backgroundOverlay;

  // Surface Colors
  /// The elevated surface color
  final Color surfaceElevated;

  /// The pressed surface color
  final Color surfacePressed;

  /// The border surface color
  final Color surfaceBorder;

  /// The default border color
  final Color borderDefault;

  // Content Colors
  /// The primary content color
  final Color contentPrimary;

  /// The secondary content color
  final Color contentSecondary;

  /// The tertiary content color
  final Color contentTertiary;

  /// The placeholder content color
  final Color contentPlaceholder;

  // Status Colors
  /// The success status color
  final Color statusSuccess;

  /// The warning status color
  final Color statusWarning;

  /// The error status color
  final Color statusError;

  /// The info status color
  final Color statusInfo;

  // Method Colors
  /// The get method color
  final Color methodGet;

  /// The post method color
  final Color methodPost;

  /// The put method color
  final Color methodPut;

  /// The delete method color
  final Color methodDelete;

  /// The patch method color
  final Color methodPatch;

  /// The head method color
  final Color methodHead;

  /// The options method color
  final Color methodOptions;

  // Interactive Colors
  /// The accent color
  final Color accent;

  /// The pressed accent color
  final Color accentPressed;

  // Utility Colors
  /// The separator color
  final Color separator;

  /// The shadow color
  final Color shadow;

  // Special Colors
  /// The search background color
  final Color searchBackground;

  /// The chevron color
  final Color chevronColor;

  /// The light theme colors
  static const light = InspectorColorsExtension(
    // Background colors
    backgroundPrimary: Color(0xFFFFFFFF), // FFFFFF
    backgroundSecondary: Color(0xFFF5F5F5), // F5F5F5
    backgroundTertiary: Color(0xFFE8E8E8), // E8E8E8
    backgroundOverlay: Color(0xFF0A0A0A),

    // Surface Colors
    surfaceElevated: Color(0xFFFFFFFF),
    surfacePressed: Color(0xFFE7E7FF), // backgroundLightAccent1
    surfaceBorder: Color(0x24000000), // borderDefault
    borderDefault: Color(0x24000000), // 24% opacity black

    // Content colors
    contentPrimary: Color(0xFF0A0A0A),
    contentSecondary: Color(0xFF4A4A4A),
    contentTertiary: Color(0xFF5E5E5E),
    contentPlaceholder: Color(0xFFA8A8A8),

    // Status colors
    statusSuccess: Color(0xFF25A511),
    statusWarning: Color(0xFFC79800),
    statusError: Color(0xFFF01331),
    statusInfo: Color(0xFF4945FF), // accent

    // Method colors (using status colors + accents)
    methodGet: Color(0xFF25A511),
    methodPost: Color(0xFF4945FF),
    methodPut: Color(0xFFC79800),
    methodDelete: Color(0xFFF01331),
    methodPatch: Color(0xFFAF33AD), // codeColor3
    methodHead: Color(0xFF2F6ED7), // codeColor4
    methodOptions: Color(0xFF5E5E5E),

    // Interactive
    accent: Color(0xFF4945FF),
    accentPressed: Color(0xFF3B37CC), // darker accent

    // Utility
    separator: Color(0x24000000),
    shadow: Color(0x12000000),

    // Special
    searchBackground: Color(0xFFF5F5F5), // backgroundSecondary
    chevronColor: Color(0xFF5E5E5E), // contentTertiary
  );

  /// The dark theme colors
  static const dark = InspectorColorsExtension(
    // Background colors
    backgroundPrimary: Color(0xFF1D1D1F), // 1D1D1F
    backgroundSecondary: Color(0xFF292929), // 292929
    backgroundTertiary: Color(0xFF3D3D3D), // 3D3D3D
    backgroundOverlay: Color(0xFF000000),

    // Surface Colors
    surfaceElevated: Color(0xFF292929), // backgroundSecondary
    surfacePressed: Color(0xFF37373D), // backgroundLightAccent1
    surfaceBorder: Color(0x24FFFFFF),
    borderDefault: Color(0x24FFFFFF), // 24% opacity white

    // Content colors
    contentPrimary: Color(0xFFFFFFFF),
    contentSecondary: Color(0xFFF5F5F5),
    contentTertiary: Color(0xFFE0E0E0),
    contentPlaceholder: Color(0xFF5C5C5C),

    // Status colors
    statusSuccess: Color(0xFF25A511),
    statusWarning: Color(0xFFC79800),
    statusError: Color(0xFFF03750), // slightly lighter for dark
    statusInfo: Color(0xFF3B76FF), // accent dark

    // Method colors
    methodGet: Color(0xFF25A511),
    methodPost: Color(0xFF3B76FF),
    methodPut: Color(0xFFC79800),
    methodDelete: Color(0xFFF03750),
    methodPatch: Color(0xFFAF33AD),
    methodHead: Color(0xFF2F6ED7),
    methodOptions: Color(0xFFE0E0E0),

    // Interactive
    accent: Color(0xFF3B76FF),
    accentPressed: Color(0xFF4945FF),

    // Utility
    separator: Color(0x24FFFFFF),
    shadow: Color(0x06FFFFFF),

    // Special
    searchBackground: Color(0xFF1D1D1F), // backgroundPrimary for contrast
    chevronColor: Color(0xFFE0E0E0),
  );

  /// Copy with new colors
  @override
  ThemeExtension<InspectorColorsExtension> copyWith({
    Color? backgroundPrimary,
    Color? backgroundSecondary,
    Color? backgroundTertiary,
    Color? backgroundOverlay,
    Color? surfaceElevated,
    Color? surfacePressed,
    Color? surfaceBorder,
    Color? borderDefault,
    Color? contentPrimary,
    Color? contentSecondary,
    Color? contentTertiary,
    Color? contentPlaceholder,
    Color? statusSuccess,
    Color? statusWarning,
    Color? statusError,
    Color? statusInfo,
    Color? methodGet,
    Color? methodPost,
    Color? methodPut,
    Color? methodDelete,
    Color? methodPatch,
    Color? methodHead,
    Color? methodOptions,
    Color? accent,
    Color? accentPressed,
    Color? separator,
    Color? shadow,
    Color? searchBackground,
    Color? chevronColor,
  }) {
    return InspectorColorsExtension(
      backgroundPrimary: backgroundPrimary ?? this.backgroundPrimary,
      backgroundSecondary: backgroundSecondary ?? this.backgroundSecondary,
      backgroundTertiary: backgroundTertiary ?? this.backgroundTertiary,
      backgroundOverlay: backgroundOverlay ?? this.backgroundOverlay,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      surfacePressed: surfacePressed ?? this.surfacePressed,
      surfaceBorder: surfaceBorder ?? this.surfaceBorder,
      borderDefault: borderDefault ?? this.borderDefault,
      contentPrimary: contentPrimary ?? this.contentPrimary,
      contentSecondary: contentSecondary ?? this.contentSecondary,
      contentTertiary: contentTertiary ?? this.contentTertiary,
      contentPlaceholder: contentPlaceholder ?? this.contentPlaceholder,
      statusSuccess: statusSuccess ?? this.statusSuccess,
      statusWarning: statusWarning ?? this.statusWarning,
      statusError: statusError ?? this.statusError,
      statusInfo: statusInfo ?? this.statusInfo,
      methodGet: methodGet ?? this.methodGet,
      methodPost: methodPost ?? this.methodPost,
      methodPut: methodPut ?? this.methodPut,
      methodDelete: methodDelete ?? this.methodDelete,
      methodPatch: methodPatch ?? this.methodPatch,
      methodHead: methodHead ?? this.methodHead,
      methodOptions: methodOptions ?? this.methodOptions,
      accent: accent ?? this.accent,
      accentPressed: accentPressed ?? this.accentPressed,
      separator: separator ?? this.separator,
      shadow: shadow ?? this.shadow,
      searchBackground: searchBackground ?? this.searchBackground,
      chevronColor: chevronColor ?? this.chevronColor,
    );
  }

  /// Lerp between two colors
  @override
  ThemeExtension<InspectorColorsExtension> lerp(
    ThemeExtension<InspectorColorsExtension>? other,
    double t,
  ) {
    if (other is! InspectorColorsExtension) {
      return this;
    }
    return InspectorColorsExtension(
      backgroundPrimary:
          Color.lerp(backgroundPrimary, other.backgroundPrimary, t)!,
      backgroundSecondary:
          Color.lerp(backgroundSecondary, other.backgroundSecondary, t)!,
      backgroundTertiary:
          Color.lerp(backgroundTertiary, other.backgroundTertiary, t)!,
      backgroundOverlay:
          Color.lerp(backgroundOverlay, other.backgroundOverlay, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      surfacePressed: Color.lerp(surfacePressed, other.surfacePressed, t)!,
      surfaceBorder: Color.lerp(surfaceBorder, other.surfaceBorder, t)!,
      borderDefault: Color.lerp(borderDefault, other.borderDefault, t)!,
      contentPrimary: Color.lerp(contentPrimary, other.contentPrimary, t)!,
      contentSecondary:
          Color.lerp(contentSecondary, other.contentSecondary, t)!,
      contentTertiary: Color.lerp(contentTertiary, other.contentTertiary, t)!,
      contentPlaceholder:
          Color.lerp(contentPlaceholder, other.contentPlaceholder, t)!,
      statusSuccess: Color.lerp(statusSuccess, other.statusSuccess, t)!,
      statusWarning: Color.lerp(statusWarning, other.statusWarning, t)!,
      statusError: Color.lerp(statusError, other.statusError, t)!,
      statusInfo: Color.lerp(statusInfo, other.statusInfo, t)!,
      methodGet: Color.lerp(methodGet, other.methodGet, t)!,
      methodPost: Color.lerp(methodPost, other.methodPost, t)!,
      methodPut: Color.lerp(methodPut, other.methodPut, t)!,
      methodDelete: Color.lerp(methodDelete, other.methodDelete, t)!,
      methodPatch: Color.lerp(methodPatch, other.methodPatch, t)!,
      methodHead: Color.lerp(methodHead, other.methodHead, t)!,
      methodOptions: Color.lerp(methodOptions, other.methodOptions, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentPressed: Color.lerp(accentPressed, other.accentPressed, t)!,
      separator: Color.lerp(separator, other.separator, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
      searchBackground:
          Color.lerp(searchBackground, other.searchBackground, t)!,
      chevronColor: Color.lerp(chevronColor, other.chevronColor, t)!,
    );
  }
}

/// Extension for easy access to the inspector colors
extension InspectorColorsExtensionGetter on BuildContext {
  /// The inspector colors
  InspectorColorsExtension get inspectorColors =>
      Theme.of(this).extension<InspectorColorsExtension>() ??
      InspectorColorsExtension.light;
}
