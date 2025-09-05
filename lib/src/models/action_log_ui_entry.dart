import 'package:digia_inspector_core/digia_inspector_core.dart';

/// A UI wrapper for action logs to simplify display logic
class ActionLogUIEntry {
  final String eventId;
  final String actionType;
  final ActionStatus status;
  final DateTime timestamp;
  final String? parentEventId;
  final String triggerName;
  final List<String> sourceChain;
  final Map<String, dynamic>? resolvedParameters;
  final String? errorMessage;
  final Duration? executionTime;

  const ActionLogUIEntry({
    required this.eventId,
    required this.actionType,
    required this.status,
    required this.timestamp,
    this.parentEventId,
    required this.triggerName,
    this.sourceChain = const [],
    this.resolvedParameters,
    this.errorMessage,
    this.executionTime,
  });

  /// Display name for the action
  String get displayName => actionType;

  /// Whether this action is pending
  bool get isPending => status == ActionStatus.pending;

  /// Whether this action is currently running
  bool get isRunning => status == ActionStatus.running;

  /// Whether this action has completed successfully
  bool get isCompleted => status == ActionStatus.completed;

  /// Whether this action has failed
  bool get hasFailed => status == ActionStatus.error;

  /// Whether this action is disabled
  bool get isDisabled => status == ActionStatus.disabled;

  /// Progress text for display
  String get statusText {
    switch (status) {
      case ActionStatus.pending:
        return 'Pending';
      case ActionStatus.running:
        return 'Running';
      case ActionStatus.completed:
        return 'Completed';
      case ActionStatus.error:
        return 'Failed';
      case ActionStatus.disabled:
        return 'Disabled';
    }
  }

  /// Source chain display text
  String get sourceChainDisplay => sourceChain.join(' → ');

  /// Target of the action (last in source chain or fallback)
  String get target => sourceChain.isNotEmpty ? sourceChain.last : 'unknown';

  /// Creates an ActionLogUIEntry from a full ActionLog
  factory ActionLogUIEntry.fromActionLog(ActionLog actionLog) {
    return ActionLogUIEntry(
      eventId: actionLog.eventId,
      actionType: actionLog.actionType,
      status: actionLog.status,
      timestamp: actionLog.timestamp,
      parentEventId: actionLog.parentEventId,
      triggerName: actionLog.triggerName,
      sourceChain: List<String>.from(actionLog.sourceChain),
      resolvedParameters: Map<String, dynamic>.from(
        actionLog.resolvedParameters,
      ),
      errorMessage: actionLog.errorMessage,
      executionTime: actionLog.executionTime,
    );
  }

  /// Creates a copy with updated fields
  ActionLogUIEntry copyWith({
    String? eventId,
    String? actionType,
    ActionStatus? status,
    DateTime? timestamp,
    String? parentEventId,
    String? triggerName,
    List<String>? sourceChain,
    Map<String, dynamic>? resolvedParameters,
    String? errorMessage,
    Duration? executionTime,
  }) {
    return ActionLogUIEntry(
      eventId: eventId ?? this.eventId,
      actionType: actionType ?? this.actionType,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      parentEventId: parentEventId ?? this.parentEventId,
      triggerName: triggerName ?? this.triggerName,
      sourceChain: sourceChain ?? this.sourceChain,
      resolvedParameters: resolvedParameters ?? this.resolvedParameters,
      errorMessage: errorMessage ?? this.errorMessage,
      executionTime: executionTime ?? this.executionTime,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ActionLogUIEntry && other.eventId == eventId;
  }

  @override
  int get hashCode => eventId.hashCode;

  @override
  String toString() => 'ActionLogUIEntry($actionType: $statusText)';
}
