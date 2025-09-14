/// A unified debug inspector for Digia apps
///
/// This library provides comprehensive debugging capabilities including network
/// request monitoring, error tracking, action logging, and state management
/// inspection. It features a unified logging system with a Chrome DevTools-like
/// UI for web and mobile platforms.
///
/// ## Key Features
///
/// Example usage:
/// ```dart
/// final controller = InspectorController();
///
/// // Setup Dio interceptor
/// dio.interceptors.add(DigiaDioInterceptor(controller: controller));
///
/// // Show inspector console (automatically detects platform)
/// showDialog(
///   context: context,
///   builder: (_) => InspectorConsole(
///     controller: controller,
///     onClose: () => Navigator.pop(context),
///   ),
/// );
///
/// // Or use directly in your app
/// InspectorConsole(
///   controller: controller,
///   height: 400, // Web only
///   width: 600,  // Web only
/// )
/// ```
library;

export 'src/implementations/network_observer_impl.dart';
export 'src/log_managers/action_log_manager.dart';
export 'src/log_managers/network_log_manager.dart';
export 'src/log_managers/state_log_manager.dart';
export 'src/models/network_log_ui_entry.dart';
export 'src/state/inspector_controller.dart';
export 'src/theme/theme_system.dart';
export 'src/utils/action_utils.dart';
export 'src/widgets/action/action_detail_view.dart';
export 'src/widgets/action/action_item.dart';
export 'src/widgets/action/action_list_view.dart';
export 'src/widgets/inspector_console.dart';
export 'src/widgets/inspector_mobile_console.dart';
export 'src/widgets/inspector_web_console.dart';
export 'src/widgets/state/state_log_list_view.dart';
