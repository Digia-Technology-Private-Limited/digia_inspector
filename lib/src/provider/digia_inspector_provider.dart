import 'package:digia_inspector/src/state/inspector_controller.dart';
import 'package:digia_inspector/src/widgets/inspector_overlay.dart';
import 'package:digia_inspector_core/digia_inspector_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Provides debugging inspector capabilities to a Flutter app.
///
/// This widget should wrap your app to enable debugging features.
/// It provides an [InspectorController] to descendant widgets and
/// optionally displays an overlay with debugging controls.
///
/// Example usage:
/// ```dart
/// DigiaInspectorProvider(
///   enabled: kDebugMode,
///   child: MyApp(),
/// )
/// ```
class DigiaInspectorProvider extends StatefulWidget {
  /// The child widget to wrap.
  final Widget child;

  /// Whether the inspector is enabled. Defaults to debug mode.
  final bool enabled;

  /// Whether to show the floating overlay button. Defaults to true.
  final bool showOverlayButton;

  /// Custom inspector controller to use. If not provided, a new one is created.
  final InspectorController? controller;

  /// Maximum number of logs to keep in memory.
  final int maxLogs;

  /// Creates a new inspector provider.
  const DigiaInspectorProvider({
    super.key,
    required this.child,
    this.enabled = kDebugMode,
    this.showOverlayButton = true,
    this.controller,
    this.maxLogs = 1000,
  });

  @override
  State<DigiaInspectorProvider> createState() => _DigiaInspectorProviderState();

  /// Gets the [InspectorController] from the widget tree.
  ///
  /// This method should be called from within a widget that has a
  /// [DigiaInspectorProvider] ancestor.
  static InspectorController of(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<_InheritedInspectorProvider>();
    assert(provider != null, 'DigiaInspectorProvider not found in widget tree');
    return provider!.controller;
  }

  /// Gets the [InspectorController] from the widget tree, or null if not found.
  static InspectorController? maybeOf(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<_InheritedInspectorProvider>();
    return provider?.controller;
  }
}

class _DigiaInspectorProviderState extends State<DigiaInspectorProvider> {
  late InspectorController _controller;
  bool _controllerCreatedLocally = false;

  @override
  void initState() {
    super.initState();

    if (widget.controller != null) {
      _controller = widget.controller!;
      _controllerCreatedLocally = false;
    } else {
      _controller = InspectorController(maxLogs: widget.maxLogs);
      _controllerCreatedLocally = true;
    }
  }

  @override
  void dispose() {
    // Only dispose the controller if we created it locally
    if (_controllerCreatedLocally) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    return _InheritedInspectorProvider(
      controller: _controller,
      child: Stack(
        children: [
          widget.child,
          if (widget.showOverlayButton)
            InspectorOverlay(controller: _controller),
        ],
      ),
    );
  }
}

/// Inherited widget that provides the inspector controller down the widget tree.
class _InheritedInspectorProvider extends InheritedWidget {
  final InspectorController controller;

  const _InheritedInspectorProvider({
    required this.controller,
    required super.child,
  });

  @override
  bool updateShouldNotify(_InheritedInspectorProvider oldWidget) {
    return controller != oldWidget.controller;
  }
}

/// Mixin that provides easy access to the inspector controller.
///
/// Mix this into widgets that need to log events to the inspector.
mixin InspectorMixin<T extends StatefulWidget> on State<T> {
  InspectorController? get inspector => DigiaInspectorProvider.maybeOf(context);

  /// Logs a debug message to the inspector.
  void logDebug(String message, {String? category, Set<String>? tags}) {
    inspector?.debug(message, category: category, tags: tags);
  }

  /// Logs an info message to the inspector.
  void logInfo(String message, {String? category, Set<String>? tags}) {
    inspector?.info(message, category: category, tags: tags);
  }

  /// Logs a warning message to the inspector.
  void logWarning(String message, {String? category, Set<String>? tags}) {
    inspector?.warning(message, category: category, tags: tags);
  }

  /// Logs an error message to the inspector.
  void logError(String message, {String? category, Set<String>? tags}) {
    inspector?.error(message, category: category, tags: tags);
  }

  /// Logs an application error to the inspector.
  void logException(Object error, {StackTrace? stackTrace, String? source}) {
    inspector?.logError(error, stackTrace: stackTrace, context: source);
  }
}
