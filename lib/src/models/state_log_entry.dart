import 'package:digia_inspector_core/digia_inspector_core.dart';
import 'log_event_type.dart';

/// A log entry for state changes in the application.
///
/// This class extends [DigiaLogEvent] to track state changes,
/// including the state name, type of change, old and new values.
class StateLogEntry extends DigiaLogEvent {
  /// The name of the state that changed.
  final String stateName;

  /// The type of change that occurred (e.g., 'updated', 'created', 'deleted').
  final String changeType;

  /// The previous value of the state, if available.
  final dynamic oldValue;

  /// The new value of the state, if available.
  final dynamic newValue;

  /// Additional context about the state change.
  final String? context;

  /// Creates a new state log entry.
  StateLogEntry({
    required this.stateName,
    required this.changeType,
    this.oldValue,
    this.newValue,
    this.context,
    super.id,
    DateTime? timestamp,
    super.category = 'state',
    super.tags,
  }) : super(
         level: LogLevel.debug,
         timestamp: timestamp,
       );

  @override
  String get eventType => LogEventType.state.name;

  @override
  String get title => 'State Change: $stateName';

  @override
  String get description {
    final contextText = context != null ? ' ($context)' : '';
    return 'State $stateName $changeType$contextText';
  }

  @override
  Map<String, dynamic> get metadata => {
    'stateName': stateName,
    'changeType': changeType,
    if (oldValue != null) 'oldValue': _serializeValue(oldValue),
    if (newValue != null) 'newValue': _serializeValue(newValue),
    if (context != null) 'context': context,
  };

  /// Safely serializes a value for JSON output.
  dynamic _serializeValue(dynamic value) {
    if (value == null) return null;
    if (value is String || value is num || value is bool) return value;
    if (value is List || value is Map) return value;
    return value.toString();
  }

  @override
  String toString() => 'StateLogEntry($stateName: $changeType)';
}
