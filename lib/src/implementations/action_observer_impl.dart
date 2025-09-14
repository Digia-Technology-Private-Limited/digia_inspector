import 'package:digia_inspector/src/state/inspector_controller.dart';
import 'package:digia_inspector_core/digia_inspector_core.dart';

/// Implementation of ActionObserver that integrates with InspectorController.
///
/// This class handles action lifecycle events and delegates them to the
/// appropriate managers within the InspectorController, providing a clean
/// separation of concerns similar to the Dio interceptor pattern.
///
/// Example usage:
/// ```dart
/// final controller = InspectorController();
/// final actionObserver = ActionObserverImpl(controller: controller);
/// ```
class ActionObserverImpl implements ActionObserver {
  /// Creates a new action observer implementation with the
  /// specified controller.
  ActionObserverImpl({required InspectorController controller})
      : _controller = controller;

  /// The inspector controller to delegate action events to.
  final InspectorController _controller;

  @override
  void onActionPending(ActionLog event) {
    // Add action to the action log manager for UI display
    _controller.actionLogManager.upsert(event);
  }

  @override
  void onActionStart(ActionLog event) {
    // Add action to the action log manager for UI display
    _controller.actionLogManager.upsert(event);
  }

  @override
  void onActionProgress(ActionLog event) {
    // Update existing action with progress information
    _controller.actionLogManager.upsert(event);
  }

  @override
  void onActionComplete(ActionLog event) {
    // Update existing action with completion status
    _controller.actionLogManager.upsert(event);
  }

  @override
  void onActionDisabled(ActionLog event) {
    // Add disabled action to the action log manager
    _controller.actionLogManager.upsert(event);
  }
}
