import 'package:digia_inspector/src/state/inspector_controller.dart';
import 'package:digia_inspector_core/digia_inspector_core.dart';

/// Implementation of StateObserver that integrates with InspectorController.
///
/// This class handles state lifecycle events and delegates them to the
/// appropriate managers within the InspectorController, providing a clean
/// separation of concerns similar to the Dio interceptor pattern.
///
/// Example usage:
/// ```dart
/// final controller = InspectorController();
/// final stateObserver = StateObserverImpl(controller: controller);
/// ```
class StateObserverImpl implements StateObserver {
  /// Creates a new state observer implementation with the
  /// specified controller.
  StateObserverImpl({required InspectorController controller})
      : _controller = controller;

  /// The inspector controller to delegate state events to.
  final InspectorController _controller;

  @override
  void onCreate(
    String stateId,
    StateType stateType, {
    String? namespace,
    Map<String, Object?>? args,
    Map<String, Object?>? initialState,
    Map<String, Object?>? metadata,
  }) {
    // Add state to the state log manager for UI display
    _controller.stateLogManager.addStateLog(
      StateLog.onCreate(
        stateId: stateId,
        stateType: stateType,
        namespace: namespace,
        args: args,
        initialState: initialState,
        metadata: metadata,
      ),
    );
  }

  @override
  void onChange(
    String stateId,
    StateType stateType, {
    String? namespace,
    Map<String, Object?>? args,
    Map<String, Object?>? changes,
    Map<String, Object?>? previousState,
    Map<String, Object?>? currentState,
    Map<String, Object?>? metadata,
  }) {
    // Add state to the state log manager for UI display
    _controller.stateLogManager.addStateLog(
      StateLog.onChange(
        stateId: stateId,
        stateType: stateType,
        namespace: namespace,
        args: args,
        changes: changes,
        previousState: previousState,
        currentState: currentState,
        metadata: metadata,
      ),
    );
  }

  @override
  void onDispose(
    String stateId,
    StateType stateType, {
    String? namespace,
    Map<String, Object?>? args,
    Map<String, Object?>? finalState,
    Map<String, Object?>? metadata,
  }) {
    // Update existing state with progress information
    _controller.stateLogManager.addStateLog(
      StateLog.onDispose(
        stateId: stateId,
        stateType: stateType,
        namespace: namespace,
        args: args,
        finalState: finalState,
        metadata: metadata,
      ),
    );
  }

  @override
  void onError(
    String stateId,
    StateType stateType,
    Object error,
    StackTrace stackTrace, {
    String? namespace,
    Map<String, Object?>? args,
    Map<String, Object?>? metadata,
  }) {
    // Update existing state with error information
    _controller.stateLogManager.addStateLog(
      StateLog.onError(
        stateId: stateId,
        stateType: stateType,
        error: error,
        stackTrace: stackTrace,
        namespace: namespace,
        args: args,
        metadata: metadata,
      ),
    );
  }
}
