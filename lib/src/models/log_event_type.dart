/// Enumeration of different log event types supported by the inspector.
///
/// This enum helps categorize and filter log entries in the debugging interface.
/// Each type represents a different kind of event that can be logged and monitored.
enum LogEventType {
  /// Plain text log messages.
  log('log'),

  /// Application errors and exceptions.
  error('error'),

  /// HTTP/network requests and responses.
  httpRequest('http_request'),

  /// Unified network logs (combining request, response, and error).
  unifiedNetwork('unified_network'),

  /// User actions and interactions.
  action('action'),

  /// Action flows with multiple related actions.
  actionFlow('action_flow'),

  /// Application state changes.
  state('state'),

  /// Expression evaluations and results.
  expression('expression');

  /// Creates a log event type with the given name.
  const LogEventType(this.name);

  /// The string name of this log event type.
  final String name;

  /// Gets a LogEventType from a string name.
  static LogEventType? fromString(String name) {
    for (final type in LogEventType.values) {
      if (type.name == name) return type;
    }
    return null;
  }

  @override
  String toString() => name;
}
