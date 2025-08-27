/// A debug console for Digia apps, providing real-time logging of network requests, actions, and states.
library digia_inspector;

// Core contracts (re-exported for convenience)
export 'package:digia_inspector_core/digia_inspector_core.dart';

// Dio interceptor
export 'src/interceptors/digia_dio_interceptor.dart';
// Integration helpers
export 'src/provider/digia_inspector_provider.dart';
// State management
export 'src/state/inspector_controller.dart';
// UI components
export 'src/widgets/inspector_overlay.dart';
export 'src/widgets/log_console.dart';
export 'src/widgets/network_request_viewer.dart';
export 'src/widgets/inspector_console_web.dart';
export 'src/widgets/inspector_panel_mobile.dart';
// Utilities
export 'src/utils/platform_utils.dart';
