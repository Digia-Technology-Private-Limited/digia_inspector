import 'package:digia_inspector_core/digia_inspector_core.dart';
import 'log_event_type.dart';

/// A log entry that represents a complete action flow.
///
/// This class extends [DigiaLogEvent] to track entire action flows,
/// including nested actions and their hierarchical relationships.
class ActionFlowLogEntry extends DigiaLogEvent {
  /// The root action that started this flow.
  final ActionLog rootAction;

  /// All actions in this flow, including the root and nested actions.
  final List<ActionLog> actions;

  /// Whether this flow has completed.
  final bool isComplete;

  /// Creates a new action flow log entry.
  ActionFlowLogEntry({
    required this.rootAction,
    required this.actions,
    this.isComplete = false,
    super.id,
    DateTime? timestamp,
    super.category = 'action_flow',
    super.tags,
  }) : super(
         level: _determineLogLevel(actions),
         timestamp: timestamp ?? rootAction.timestamp,
       );

  @override
  String get eventType => LogEventType.actionFlow.name;

  @override
  String get title => 'Action Flow: ${rootAction.actionType}';

  @override
  String get description {
    final completedCount = actions.where((a) => a.isCompleted).length;
    final failedCount = actions.where((a) => a.isFailed).length;
    final status = isComplete ? 'completed' : 'in progress';

    return 'Action flow ${rootAction.actionType} ($status) - '
        '$completedCount completed, $failedCount failed of ${actions.length} actions';
  }

  @override
  Map<String, dynamic> get metadata => {
    'rootActionId': rootAction.actionId,
    'rootActionType': rootAction.actionType,
    'totalActions': actions.length,
    'completedActions': actions.where((a) => a.isCompleted).length,
    'failedActions': actions.where((a) => a.isFailed).length,
    'isComplete': isComplete,
    'actions': actions
        .map(
          (a) => {
            'id': a.actionId,
            'type': a.actionType,
            'status': a.status.name,
            'timestamp': a.timestamp.toIso8601String(),
          },
        )
        .toList(),
  };

  /// Determines the appropriate log level based on the actions in the flow.
  static LogLevel _determineLogLevel(List<ActionLog> actions) {
    if (actions.any((a) => a.isFailed)) return LogLevel.error;
    if (actions.any((a) => a.isRunning)) return LogLevel.info;
    if (actions.every((a) => a.isCompleted)) return LogLevel.info;
    return LogLevel.debug;
  }

  /// Gets all top-level actions (actions without parents).
  List<ActionLog> get topLevelActions {
    return actions.where((a) => a.isTopLevel).toList();
  }

  /// Gets all child actions for a given parent action.
  List<ActionLog> getChildActions(String parentEventId) {
    return actions.where((a) => a.parentEventId == parentEventId).toList();
  }

  /// Creates a copy of this flow with updated actions.
  ActionFlowLogEntry copyWith({
    ActionLog? rootAction,
    List<ActionLog>? actions,
    bool? isComplete,
    String? id,
    DateTime? timestamp,
    String? category,
    Set<String>? tags,
  }) {
    return ActionFlowLogEntry(
      rootAction: rootAction ?? this.rootAction,
      actions: actions ?? this.actions,
      isComplete: isComplete ?? this.isComplete,
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      category: category ?? this.category,
      tags: tags ?? this.tags,
    );
  }

  @override
  String toString() =>
      'ActionFlowLogEntry(${rootAction.actionType}: ${actions.length} actions)';
}
