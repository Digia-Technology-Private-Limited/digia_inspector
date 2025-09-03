/// Type alias for NetworkLogEntry to use UnifiedNetworkLog.
///
/// This provides a consistent interface for the inspector while using
/// the unified network logging system from the core package.
import 'package:digia_inspector_core/digia_inspector_core.dart';

typedef NetworkLogEntry = UnifiedNetworkLog;

/// Factory function to create a NetworkLogEntry (UnifiedNetworkLog) from request parameters.
NetworkLogEntry createNetworkLogEntry({
  required String method,
  required String url,
  Map<String, dynamic>? requestHeaders,
  dynamic requestBody,
  Map<String, dynamic>? queryParameters,
  String? apiName,
  String? apiId,
}) {
  final requestId = apiId ?? DateTime.now().millisecondsSinceEpoch.toString();

  final request = NetworkRequestLog(
    method: method,
    url: Uri.parse(url),
    headers: requestHeaders ?? {},
    body: requestBody,
    queryParameters: queryParameters ?? {},
    requestId: requestId,
    apiName: apiName,
    apiId: apiId,
  );

  return UnifiedNetworkLog(
    request: request,
    id: requestId,
    timestamp: DateTime.now(),
  );
}
