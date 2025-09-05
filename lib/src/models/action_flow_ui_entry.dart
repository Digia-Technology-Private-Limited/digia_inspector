import 'package:digia_inspector_core/digia_inspector_core.dart';

/// Filter options for action status
enum ActionStatusFilter {
  all,
  pending,
  running,
  completed,
  error,
}

/// UI wrapper for action flows to simplify display logic
class ActionFlowUIEntry {
  final String flowId;
  final ActionLog rootAction;
  final List<ActionLog> actions;
  final DateTime timestamp;
  final String triggerName;
  final List<String> sourceChain;

  const ActionFlowUIEntry({
    required this.flowId,
    required this.rootAction,
    required this.actions,
    required this.timestamp,
    required this.triggerName,
    required this.sourceChain,
  });

  /// Display name for the flow
  String get displayName => rootAction.actionType;

  /// Number of actions in this flow
  int get actionCount => actions.length;

  /// Number of completed actions
  int get completedCount => actions.where((a) => a.isCompleted).length;

  /// Number of failed actions
  int get failedCount =>
      actions.where((a) => a.status == ActionStatus.error).length;

  /// Number of running actions
  int get runningCount => actions.where((a) => a.isRunning).length;

  /// Whether this flow is pending
  bool get isPending => rootAction.isPending;

  /// Whether this flow is currently running
  bool get isRunning => actions.any((a) => a.isRunning);

  /// Whether this flow has completed (all actions completed)
  bool get isCompleted =>
      actions.isNotEmpty && actions.every((a) => a.isCompleted);

  /// Whether this flow has failed (any action failed)
  bool get hasFailed => actions.any((a) => a.status == ActionStatus.error);

  /// Progress percentage (0.0 to 1.0)
  double get progress {
    if (actions.isEmpty) return 0.0;
    return completedCount / actions.length;
  }

  /// Status summary text
  String get statusSummary {
    if (hasFailed) return 'error';
    if (isRunning) return 'running';
    if (isCompleted) return 'completed';
    if (isPending) return 'pending';
    return 'unknown';
  }

  /// Source chain display text
  String get sourceChainDisplay => sourceChain.join(' → ');

  /// Creates a copy with updated fields
  ActionFlowUIEntry copyWith({
    String? flowId,
    ActionLog? rootAction,
    List<ActionLog>? actions,
    DateTime? timestamp,
    String? triggerName,
    List<String>? sourceChain,
  }) {
    return ActionFlowUIEntry(
      flowId: flowId ?? this.flowId,
      rootAction: rootAction ?? this.rootAction,
      actions: actions ?? this.actions,
      timestamp: timestamp ?? this.timestamp,
      triggerName: triggerName ?? this.triggerName,
      sourceChain: sourceChain ?? this.sourceChain,
    );
  }
}
