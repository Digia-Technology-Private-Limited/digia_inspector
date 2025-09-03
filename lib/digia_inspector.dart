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

// Models
export 'src/models/log_event_type.dart';
export 'src/models/error_log_entry.dart';
export 'src/models/plain_log_entry.dart';
export 'src/models/state_log_entry.dart';
export 'src/models/action_log_entry.dart';
export 'src/models/action_flow_log_entry.dart';
export 'src/models/network_log_entry.dart';

// Extensions
export 'src/extensions/network_log_extensions.dart';
export 'src/extensions/object_extensions.dart';
export 'src/extensions/string_extensions.dart';
// Interceptors
export 'src/interceptors/digia_dio_interceptor.dart';
// Integration helpers
export 'src/provider/digia_inspector_provider.dart';
export 'src/state/action_log_handler.dart';
// State management (refactored for better separation of concerns)
export 'src/state/inspector_controller.dart';
export 'src/state/log_entry_manager.dart';
export 'src/state/log_exporter.dart';
export 'src/state/network_log_correlator.dart';
// Utilities
export 'src/utils/platform_utils.dart';
// Supporting UI components
export 'src/widgets/headers_section.dart';
// Legacy UI components (backwards compatibility wrappers)
export 'src/widgets/inspector_console_web.dart';
// Main UI components
export 'src/widgets/inspector_dashboard.dart';
export 'src/widgets/inspector_overlay.dart';
export 'src/widgets/inspector_panel_mobile.dart';
export 'src/widgets/json_viewer.dart';
export 'src/widgets/log_console.dart';
export 'src/widgets/log_entry_item.dart';
export 'src/widgets/network_detail_view.dart';
export 'src/widgets/network_logs_panel.dart';
