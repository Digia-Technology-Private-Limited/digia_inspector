import 'package:digia_inspector/src/models/log_event_type.dart';
import 'package:digia_inspector_core/digia_inspector_core.dart';

/// A simplified action log entry for UI display.
///
/// This class provides a simpler interface for logging user actions
/// compared to the full [ActionLog] class, while still extending [DigiaLogEvent].
class ActionLogEntry extends DigiaLogEvent {
  /// Creates a new action log entry.
  ActionLogEntry({
    required this.action,
    required this.status,
    required this.target,
    this.parameters,
    this.userId,
    super.id,
    super.timestamp,
    super.category = 'action',
    super.tags,
  }) : super(
         level: LogLevel.info,
       );

  /// The action that was performed.
  final String action;

  /// The status of the action.
  final ActionStatus status;

  /// The target of the action.
  final String target;

  /// Optional parameters associated with the action.
  final Map<String, dynamic>? parameters;

  /// Optional user ID who performed the action.
  final String? userId;

  @override
  String get eventType => LogEventType.action.name;

  @override
  String get title => 'Action: $action';

  @override
  String get description => '$action on $target';

  @override
  Map<String, dynamic> get metadata => {
    'action': action,
    'target': target,
    if (parameters != null) 'parameters': parameters,
    if (userId != null) 'userId': userId,
  };

  /// Creates an ActionLogEntry from a full ActionLog.
  factory ActionLogEntry.fromActionLog(ActionLog actionLog) {
    return ActionLogEntry(
      action: actionLog.actionType,
      status: actionLog.status,
      target: actionLog.sourceChain.isNotEmpty
          ? actionLog.sourceChain.last
          : 'unknown',
      parameters: actionLog.resolvedParameters,
      id: actionLog.eventId,
      timestamp: actionLog.timestamp,
    );
  }

  @override
  String toString() => 'ActionLogEntry($action: $target)';
}
