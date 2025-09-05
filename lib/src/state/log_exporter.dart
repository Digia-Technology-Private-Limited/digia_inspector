// import 'package:digia_inspector/src/models/network_log_entry.dart';
// import 'package:digia_inspector/src/models/plain_log_entry.dart';
// import 'package:digia_inspector/src/models/error_log_entry.dart';
// import 'package:digia_inspector/src/models/action_log_entry.dart';
// import 'package:digia_inspector/src/models/state_log_entry.dart';
// import 'package:digia_inspector_core/digia_inspector_core.dart';

// /// Handles exporting log entries to various formats.
// ///
// /// This class is responsible for converting log entries into different
// /// export formats (JSON, CSV, etc.), providing a clean separation of
// /// concerns for export functionality.
// class LogExporter {
//   /// Exports log entries as JSON.
//   ///
//   /// Returns a structured JSON representation of all log entries
//   /// including metadata and timestamps.
//   Map<String, dynamic> exportAsJson(List<DigiaLogEvent> logs) {
//     return {
//       'exportTime': TimestampHelper.formatISO(DateTime.now()),
//       'totalLogs': logs.length,
//       'entries': logs
//           .map(
//             (entry) => {
//               'type': entry.eventType,
//               'timestamp': entry.timestamp.toIso8601String(),
//               'contents': entry.description,
//               'data': _entryToJson(entry),
//             },
//           )
//           .toList(),
//     };
//   }

//   /// Exports log entries as CSV string.
//   ///
//   /// Returns a CSV representation suitable for spreadsheet applications.
//   String exportAsCsv(List<DigiaLogEvent> logs) {
//     final buffer = StringBuffer()
//       // CSV header
//       ..writeln('Timestamp,Type,Contents,Details');

//     // CSV rows
//     for (final entry in logs) {
//       final timestamp = entry.timestamp.toIso8601String();
//       final type = entry.eventType;
//       final contents = _escapeCsvField(entry.description);
//       final details = _escapeCsvField(_getEntryDetails(entry));

//       buffer.writeln('$timestamp,$type,$contents,$details');
//     }

//     return buffer.toString();
//   }

//   /// Exports log entries as plain text.
//   ///
//   /// Returns a human-readable text representation of the logs.
//   String exportAsText(List<DigiaLogEvent> logs) {
//     final buffer = StringBuffer()
//       ..writeln('Digia Inspector Log Export')
//       ..writeln('Generated: ${TimestampHelper.formatISO(DateTime.now())}')
//       ..writeln('Total entries: ${logs.length}')
//       ..writeln('${'=' * 50}')
//       ..writeln();

//     for (final entry in logs) {
//       buffer.writeln(
//         '[${TimestampHelper.format(entry.timestamp)}] ${entry.eventType.toUpperCase()}',
//       );
//       buffer.writeln('Contents: ${entry.description}');

//       final details = _getEntryDetails(entry);
//       if (details.isNotEmpty) {
//         buffer.writeln('Details: $details');
//       }

//       buffer.writeln('-' * 30);
//     }

//     return buffer.toString();
//   }

//   /// Exports only network logs with enhanced formatting.
//   ///
//   /// Returns a JSON structure optimized for network debugging.
//   Map<String, dynamic> exportNetworkLogsAsJson(List<DigiaLogEvent> logs) {
//     final networkLogs = logs.whereType<NetworkLogEntry>().toList();

//     return {
//       'exportTime': TimestampHelper.formatISO(DateTime.now()),
//       'totalNetworkRequests': networkLogs.length,
//       'successfulRequests': networkLogs
//           .where((log) => log.response?.isSuccess ?? false)
//           .length,
//       'failedRequests': networkLogs.where((log) => log.error != null).length,
//       'requests': networkLogs
//           .map(
//             (log) => {
//               'timestamp': log.timestamp.toIso8601String(),
//               'method': log.request.method,
//               'url': log.request.url,
//               'statusCode': log.response?.statusCode,
//               'duration': log.response?.duration?.inMilliseconds,
//               'isError': log.error != null,
//               'requestHeaders': log.request.headers,
//               'responseHeaders': log.response?.headers,
//               'requestBody': log.request.body,
//               'responseBody': log.response?.body,
//               'error': log.error?.error,
//             },
//           )
//           .toList(),
//     };
//   }

//   /// Exports only action logs with enhanced formatting.
//   ///
//   /// Returns a JSON structure optimized for action debugging.
//   Map<String, dynamic> exportActionLogsAsJson(List<DigiaLogEvent> logs) {
//     final actionLogs = logs.whereType<ActionLogEntry>().toList();

//     return {
//       'exportTime': TimestampHelper.formatISO(DateTime.now()),
//       'totalActions': actionLogs.length,
//       'completedActions': actionLogs
//           .where((log) => log.status == ActionStatus.completed)
//           .length,
//       'failedActions': actionLogs
//           .where((log) => log.status == ActionStatus.error)
//           .length,
//       'runningActions': actionLogs
//           .where((log) => log.status == ActionStatus.running)
//           .length,
//       'actions': actionLogs
//           .map(
//             (log) => {
//               'timestamp': log.timestamp.toIso8601String(),
//               'action': log.action,
//               'target': log.target,
//               'status': log.status,
//               'eventId': log.id,
//               'parentEventId': log.parameters?['parentEventId'],
//               'sourceChain': log.parameters?['sourceChain'],
//               'actionType': log.parameters?['actionType'],
//               'executionTime': log.parameters?['executionTime']?.inMilliseconds,
//               'parameters': log.parameters,
//               'error': log.parameters?['error']?.toString(),
//               'errorMessage': log.parameters?['errorMessage'],
//             },
//           )
//           .toList(),
//     };
//   }

//   /// Converts a log entry to JSON data.
//   Map<String, dynamic> _entryToJson(DigiaLogEvent entry) {
//     switch (entry) {
//       case final PlainLogEntry plain:
//         return {
//           'message': plain.message,
//           'level': plain.level.name,
//           'category': plain.category,
//         };
//       case final NetworkLogEntry network:
//         return {
//           'method': network.request.method,
//           'url': network.request.url,
//           'status': network.response?.statusCode,
//           'statusCode': network.response?.statusCode,
//           'requestHeaders': network.request.headers,
//           'responseHeaders': network.response?.headers,
//           'duration': network.response?.duration?.inMilliseconds,
//           'error': network.error?.error,
//         };
//       case final ErrorLogEntry error:
//         return {
//           'error': error.error.toString(),
//           'context': error.context,
//           'severity': error.severity.name,
//           'stackTrace': error.stackTrace?.toString(),
//         };
//       case final ActionLogEntry action:
//         return {
//           'action': action.action,
//           'target': action.target,
//           'parameters': action.parameters,
//           'userId': action.userId,
//           'eventId': action.id,
//           'parentEventId': action.parameters?['parentEventId'],
//           'sourceChain': action.parameters?['sourceChain'],
//           'actionType': action.parameters?['actionType'],
//           'status': action.status,
//           'executionTime': action.parameters?['executionTime']?.inMilliseconds,
//           'error': action.parameters?['error']?.toString(),
//           'errorMessage': action.parameters?['errorMessage'],
//         };
//       case final StateLogEntry state:
//         return {
//           'stateName': state.stateName,
//           'changeType': state.changeType,
//           'oldValue': state.oldValue?.toString(),
//           'newValue': state.newValue?.toString(),
//           'context': state.context,
//         };
//       default:
//         return {'unknown': entry.toString()};
//     }
//   }

//   /// Gets a summary of details for a log entry.
//   String _getEntryDetails(DigiaLogEvent entry) {
//     switch (entry) {
//       case final PlainLogEntry plain:
//         return '${plain.level.name}: ${plain.message}';
//       case final NetworkLogEntry network:
//         return '${network.request.method} ${network.request.url} → ${network.response?.statusCode ?? 'pending'}';
//       case final ErrorLogEntry error:
//         return '${error.severity.name}: ${error.error}';
//       case final ActionLogEntry action:
//         return '${action.action} (${action.status}) → ${action.target}';
//       case final StateLogEntry state:
//         return '${state.stateName}: ${state.changeType}';
//       default:
//         return entry.toString();
//     }
//   }

//   /// Escapes a field for CSV output.
//   String _escapeCsvField(String field) {
//     // Replace quotes with double quotes and wrap in quotes if needed
//     if (field.contains(',') || field.contains('"') || field.contains('\n')) {
//       return '"${field.replaceAll('"', '""')}"';
//     }
//     return field;
//   }
// }
