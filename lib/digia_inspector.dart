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
/// // Show inspector dashboard
/// showDialog(
///   context: context,
///   builder: (_) => InspectorDashboard(
///     controller: controller,
///     onClose: () => Navigator.pop(context),
///   ),
/// );
/// ```
library;

// Core contracts (re-exported for convenience)
export 'package:digia_inspector_core/digia_inspector_core.dart';

// Interceptors
export 'src/interceptors/digia_dio_interceptor.dart';
export 'src/models/error_log_entry.dart';
// Models
export 'src/models/log_event_type.dart';
export 'src/models/network_log_ui_entry.dart';
export 'src/models/plain_log_entry.dart';
export 'src/models/state_log_entry.dart';
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
// Legacy UI components (backwards compatibility wrappers)
export 'src/widgets/inspector_console_web.dart';
// Main UI components
export 'src/widgets/inspector_dashboard.dart';
export 'src/widgets/inspector_mobile_view.dart';
export 'src/widgets/inspector_overlay.dart';
export 'src/widgets/inspector_panel_mobile.dart';
