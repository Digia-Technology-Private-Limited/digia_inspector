import 'package:digia_inspector/src/state/inspector_controller.dart';
import 'package:digia_inspector/src/theme/app_colors.dart';
import 'package:digia_inspector/src/utils/platform_utils.dart';
import 'package:digia_inspector/src/widgets/inspector_mobile_console.dart';
import 'package:digia_inspector/src/widgets/inspector_web_console.dart';
import 'package:flutter/material.dart';

/// Main inspector console with platform-specific implementations
///
/// This widget automatically detects the platform and shows the appropriate
/// console implementation:
/// - Web: InspectorWebConsole with nested navigation
/// - Mobile: InspectorMobileConsole with existing mobile structure
class InspectorConsole extends StatelessWidget {
  /// Main inspector console with platform-specific implementations
  ///
  /// This widget automatically detects the platform and shows the appropriate
  /// console implementation:
  /// - Web: InspectorWebConsole with nested navigation
  /// - Mobile: InspectorMobileConsole with existing mobile structure
  const InspectorConsole({
    required this.controller,
    super.key,
    this.onClose,
    this.initialTab = 0,
    this.height = 400,
    this.width,
    this.themeMode,
  });

  /// The inspector controller managing log data
  final InspectorController controller;

  /// Callback when the console should be closed
  final VoidCallback? onClose;

  /// Initial tab to display (0=Network, 1=Actions, 2=State)
  final int initialTab;

  /// Height of the console (web only)
  final double height;

  /// Width of the console (web only)
  /// Width of the console (web only)
  final double? width;

  /// Theme mode for the inspector (Defaults to light)
  final ThemeMode? themeMode;

  @override
  Widget build(BuildContext context) {
    // Determine brightness
    final effectiveThemeMode = themeMode ?? ThemeMode.light;
    final platformBrightness = MediaQuery.platformBrightnessOf(context);
    final brightness = effectiveThemeMode == ThemeMode.system
        ? platformBrightness
        : effectiveThemeMode == ThemeMode.light
            ? Brightness.light
            : Brightness.dark;

    final colors = brightness == Brightness.dark
        ? InspectorColorsExtension.dark
        : InspectorColorsExtension.light;

    // Create a theme data that includes our extension
    final theme = ThemeData(
      brightness: brightness,
      extensions: [colors],
      useMaterial3: true,
      scaffoldBackgroundColor: colors.backgroundPrimary,
      colorScheme: ColorScheme.fromSeed(
        seedColor: colors.accent,
        brightness: brightness,
        surface: colors.backgroundPrimary,
      ),
    );

    return Theme(
      data: theme,
      child: Builder(
        builder: (context) {
          if (PlatformUtils.isWeb) {
            return InspectorWebConsole(
              controller: controller,
              onClose: onClose,
              initialTabIndex: initialTab,
              height: height,
              width: width,
            );
          } else {
            return InspectorMobileConsole(
              controller: controller,
              onClose: onClose,
              initialTabIndex: initialTab,
            );
          }
        },
      ),
    );
  }
}
