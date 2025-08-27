import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../state/inspector_controller.dart';
import '../widgets/inspector_console_web.dart';
import '../widgets/inspector_panel_mobile.dart';

/// Platform detection utilities for determining the optimal inspector UI.
class PlatformUtils {
  /// Returns true if running on a web platform.
  static bool isWebPlatform() {
    return kIsWeb;
  }

  /// Returns true if running on a mobile platform (iOS or Android).
  static bool isMobilePlatform() {
    return !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.android);
  }

  /// Returns true if running on a desktop platform.
  static bool isDesktopPlatform() {
    return !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.macOS ||
            defaultTargetPlatform == TargetPlatform.linux);
  }

  /// Returns the optimal inspector widget based on the current platform.
  ///
  /// Returns [InspectorConsoleWeb] for web platforms, and
  /// [InspectorPanelMobile] for mobile platforms.
  static Widget getOptimalInspectorWidget({
    required InspectorController controller,
    double? height,
    double? width,
  }) {
    if (isWebPlatform() || isDesktopPlatform()) {
      return InspectorConsoleWeb(
        controller: controller,
        height: height ?? 400,
        width: width,
      );
    } else {
      return InspectorPanelMobile(
        controller: controller,
        maxHeight:
            height ??
            MediaQuery.of(
                  // This is a fallback context, ideally should be passed from outside
                  WidgetsBinding.instance.rootElement!,
                ).size.height *
                0.8,
      );
    }
  }
}

/// Extension on BuildContext for platform utilities.
extension PlatformUtilsExtension on BuildContext {
  /// Returns the optimal inspector widget for this context's platform.
  Widget getInspectorWidget({
    required InspectorController controller,
    double? height,
    double? width,
  }) {
    final mediaQuery = MediaQuery.of(this);

    if (PlatformUtils.isWebPlatform() || PlatformUtils.isDesktopPlatform()) {
      return InspectorConsoleWeb(
        controller: controller,
        height: height ?? 400,
        width: width,
      );
    } else {
      return InspectorPanelMobile(
        controller: controller,
        maxHeight: height ?? mediaQuery.size.height * 0.8,
      );
    }
  }

  /// Returns true if this context is on a mobile platform.
  bool get isMobile => PlatformUtils.isMobilePlatform();

  /// Returns true if this context is on a web platform.
  bool get isWeb => PlatformUtils.isWebPlatform();

  /// Returns true if this context is on a desktop platform.
  bool get isDesktop => PlatformUtils.isDesktopPlatform();
}
