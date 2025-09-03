import 'package:digia_inspector_core/digia_inspector_core.dart';
import 'log_event_type.dart';

/// Severity level for error log entries.
enum ErrorSeverity {
  /// Warning level - indicates potential issues.
  warning,

  /// Error level - indicates failures that don't crash the app.
  error,

  /// Critical level - indicates severe failures that may crash the app.
  critical,
}

/// A log entry for application errors.
///
/// This class extends [DigiaLogEvent] to provide specialized handling
/// for application errors, including error objects, stack traces,
/// and context information for debugging.
class ErrorLogEntry extends DigiaLogEvent {
  /// The error object that occurred.
  final Object error;

  /// The stack trace associated with the error, if available.
  final StackTrace? stackTrace;

  /// Additional context about where or when the error occurred.
  final String? context;

  /// The severity level of this error.
  final ErrorSeverity severity;

  /// Creates a new error log entry.
  ErrorLogEntry({
    required this.error,
    this.stackTrace,
    this.context,
    this.severity = ErrorSeverity.error,
    super.id,
    DateTime? timestamp,
    super.category = 'error',
    super.tags,
  }) : super(
         level: _severityToLogLevel(severity),
         timestamp: timestamp,
       );

  @override
  String get eventType => LogEventType.error.name;

  @override
  String get title => 'Application Error';

  @override
  String get description {
    final contextText = context != null ? ' in $context' : '';
    return 'Error$contextText: ${error.toString()}';
  }

  @override
  Map<String, dynamic> get metadata => {
    'error': error.toString(),
    'errorType': error.runtimeType.toString(),
    if (context != null) 'context': context,
    if (stackTrace != null) 'stackTrace': stackTrace.toString(),
    'severity': severity.name,
  };

  /// Converts error severity to appropriate log level.
  static LogLevel _severityToLogLevel(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.warning:
        return LogLevel.warning;
      case ErrorSeverity.error:
        return LogLevel.error;
      case ErrorSeverity.critical:
        return LogLevel.critical;
    }
  }

  @override
  String toString() => 'ErrorLogEntry(${severity.name}: ${error.toString()})';
}
