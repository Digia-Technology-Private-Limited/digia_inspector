import 'package:digia_inspector/src/state/inspector_controller.dart';
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
  final double? width;

  @override
  Widget build(BuildContext context) {
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
  }
}
