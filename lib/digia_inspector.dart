/// A unified debug inspector for Digia apps with Chrome DevTools-like interface.
///
/// This library provides comprehensive debugging capabilities including network
/// request monitoring, error tracking, action logging, and state management
/// inspection. It features a unified logging system with a Chrome DevTools-like
/// UI for web and mobile platforms.
///
/// Key features:
/// - Unified log entry system for all debug information
/// - Network request inspection with cURL generation
/// - Chrome DevTools-like tabbed interface
/// - Real-time filtering and searching
/// - Cross-platform compatibility (web, mobile)
/// - Detailed request/response viewers with syntax highlighting
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

// Core contracts (re-exported for convenience)
export 'package:digia_inspector_core/digia_inspector_core.dart';

// Interceptors
export 'src/interceptors/digia_dio_interceptor.dart';
// Models
export 'src/models/network_log_ui_entry.dart';
export 'src/state/action_log_manager.dart';
// State management (refactored for better separation of concerns)
export 'src/state/inspector_controller.dart';
export 'src/state/log_exporter.dart';
export 'src/state/network_log_manager.dart';
// New mobile-first design system
export 'src/theme_system.dart';
// Utilities
export 'src/utils/action_utils.dart';
export 'src/widgets/action/action_detail_bottom_sheet.dart';
export 'src/widgets/action/action_item.dart';
// Action widgets
export 'src/widgets/action/action_list_view.dart';
export 'src/widgets/action/action_search_filter.dart';
// Main UI components
export 'src/widgets/inspector_console.dart';
export 'src/widgets/inspector_mobile_console.dart';
export 'src/widgets/inspector_web_console.dart';
