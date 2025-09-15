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
  void onCreate({
    required String id,
    required StateType stateType,
    String? namespace,
    Map<String, Object?>? argData,
    Map<String, Object?>? stateData,
  }) {
    _controller.stateLogManager.addStateLog(
      StateLog.onCreate(
        id: id,
        stateType: stateType,
        namespace: namespace,
        argData: argData,
        stateData: stateData,
      ),
    );
  }

  @override
  void onChange({
    required String id,
    required StateType stateType,
    String? namespace,
    Map<String, Object?>? argData,
    Map<String, Object?>? stateData,
  }) {
    _controller.stateLogManager.addStateLog(
      StateLog.onChange(
        id: id,
        stateType: stateType,
        namespace: namespace,
        argData: argData,
        stateData: stateData,
      ),
    );
  }

  @override
  void onDispose({
    required String id,
    required StateType stateType,
    String? namespace,
    Map<String, Object?>? argData,
    Map<String, Object?>? stateData,
  }) {
    _controller.stateLogManager.addStateLog(
      StateLog.onDispose(
        id: id,
        stateType: stateType,
        namespace: namespace,
        argData: argData,
        stateData: stateData,
      ),
    );
  }

  @override
  void onError({
    required String id,
    required StateType stateType,
    required Object error,
    required StackTrace stackTrace,
    String? namespace,
  }) {
    _controller.stateLogManager.addStateLog(
      StateLog.onError(
        id: id,
        stateType: stateType,
        error: error,
        stackTrace: stackTrace,
        namespace: namespace,
      ),
    );
  }
}
