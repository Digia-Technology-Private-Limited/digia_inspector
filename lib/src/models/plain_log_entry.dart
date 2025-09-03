import 'package:digia_inspector_core/digia_inspector_core.dart';
import 'log_event_type.dart';

/// A simple log entry for plain text messages.
///
/// This class extends [DigiaLogEvent] to provide basic text logging
/// functionality with different log levels and optional categorization.
class PlainLogEntry extends DigiaLogEvent {
  /// The text message for this log entry.
  final String message;

  /// Creates a new plain log entry.
  PlainLogEntry({
    required this.message,
    super.level = LogLevel.info,
    super.id,
    DateTime? timestamp,
    super.category,
    super.tags,
  }) : super(
         timestamp: timestamp,
       );

  @override
  String get eventType => LogEventType.log.name;

  @override
  String get title =>
      message.length > 50 ? '${message.substring(0, 50)}...' : message;

  @override
  String get description => message;

  @override
  Map<String, dynamic> get metadata => {
    'message': message,
  };

  @override
  String toString() => 'PlainLogEntry(${level.name}: $message)';
}
