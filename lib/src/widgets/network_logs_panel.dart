import 'package:flutter/material.dart';
import 'package:digia_inspector_core/digia_inspector_core.dart';
import '../state/inspector_controller.dart';
import 'unified_network_detail_view.dart';

/// Network logs panel showing unified network entries in a mobile-first design.
///
/// This panel displays network requests, responses, and errors as unified entries
/// matching the Chrome DevTools-like design shown in the mockup.
class NetworkLogsPanel extends StatefulWidget {
  /// The inspector controller managing network logs.
  final InspectorController controller;

  /// Search query for filtering network logs.
  final String searchQuery;

  const NetworkLogsPanel({
    super.key,
    required this.controller,
    this.searchQuery = '',
  });

  @override
  State<NetworkLogsPanel> createState() => _NetworkLogsPanelState();
}

class _NetworkLogsPanelState extends State<NetworkLogsPanel> {
  final ScrollController _scrollController = ScrollController();
  UnifiedNetworkLog? _selectedEntry;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedEntry != null) {
      return NetworkDetailView(
        entry: _selectedEntry!,
        onBack: () {
          setState(() {
            _selectedEntry = null;
          });
        },
      );
    }

    // For now, we'll create some demo data
    // TODO: This needs to be replaced with real data from the controller
    return ValueListenableBuilder<dynamic>(
      valueListenable: widget.controller.filteredLogsNotifier,
      builder: (context, allLogs, child) {
        // Create demo network logs for demonstration
        final networkLogs = _createDemoNetworkLogs();

        // Apply search filter
        final filteredLogs = widget.searchQuery.isEmpty
            ? networkLogs
            : networkLogs
                  .where(
                    (UnifiedNetworkLog log) => log.matches(widget.searchQuery),
                  )
                  .toList();

        if (filteredLogs.isEmpty) {
          return _buildEmptyState();
        }

        return Column(
          children: [
            _buildStatusBar(filteredLogs.length),
            Expanded(
              child: ListView.separated(
                controller: _scrollController,
                itemCount: filteredLogs.length,
                padding: const EdgeInsets.all(16),
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final entry = filteredLogs[index];
                  return _buildNetworkLogItem(entry);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  List<UnifiedNetworkLog> _createDemoNetworkLogs() {
    // Create demo data to demonstrate the UI
    final demoLogs = <UnifiedNetworkLog>[];

    // Demo API call - successful
    final getUsersRequest = NetworkRequestLog(
      method: 'GET',
      url: Uri.parse('https://api.example.com/api/users'),
      requestId: 'req_001',
      apiName: '/api/users',
    );
    final getUsersResponse = NetworkResponseLog(
      requestId: 'req_001',
      statusCode: 200,
      headers: {'content-type': 'application/json'},
      body: <String, dynamic>{'users': <dynamic>[]},
      duration: const Duration(milliseconds: 456),
    );
    demoLogs.add(
      UnifiedNetworkLog.fromRequest(
        getUsersRequest,
      ).withResponse(getUsersResponse),
    );

    // Demo API call - error
    final loginRequest = NetworkRequestLog(
      method: 'POST',
      url: Uri.parse('https://api.example.com/api/auth/login'),
      requestId: 'req_002',
      apiName: '/api/auth/login',
      body: <String, dynamic>{'username': 'user', 'password': 'pass'},
    );
    final loginResponse = NetworkResponseLog(
      requestId: 'req_002',
      statusCode: 500,
      headers: {'content-type': 'application/json'},
      body: <String, dynamic>{'error': 'Internal server error'},
      duration: const Duration(milliseconds: 1200),
    );
    demoLogs.add(
      UnifiedNetworkLog.fromRequest(loginRequest).withResponse(loginResponse),
    );

    // Demo API call - successful
    final getProfileRequest = NetworkRequestLog(
      method: 'GET',
      url: Uri.parse('https://api.example.com/api/profile'),
      requestId: 'req_003',
      apiName: '/api/profile',
    );
    final getProfileResponse = NetworkResponseLog(
      requestId: 'req_003',
      statusCode: 200,
      headers: {'content-type': 'application/json'},
      body: <String, dynamic>{
        'profile': <String, dynamic>{'name': 'John Doe'},
      },
      duration: const Duration(milliseconds: 120),
      responseSize: 3400,
    );
    demoLogs.add(
      UnifiedNetworkLog.fromRequest(
        getProfileRequest,
      ).withResponse(getProfileResponse),
    );

    return demoLogs;
  }

  Widget _buildStatusBar(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        border: Border(
          bottom: BorderSide(
            color: Color(0xFF333333),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            count == 1 ? '1 request' : '$count requests',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkLogItem(UnifiedNetworkLog entry) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedEntry = entry;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2D2D2D),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF404040),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // HTTP Method
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getMethodColor(
                      entry.request.method,
                    ).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    entry.request.method,
                    style: TextStyle(
                      color: _getMethodColor(entry.request.method),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // URL/API Name
                Expanded(
                  child: Text(
                    entry.displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                // Arrow icon
                const Icon(
                  Icons.chevron_right,
                  color: Colors.grey,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                // Timestamp
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      color: Colors.grey,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatTime(entry.timestamp),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                // Duration (if available)
                if (entry.duration != null) ...[
                  Row(
                    children: [
                      Text(
                        '${entry.duration!.inMilliseconds}ms',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                ],
                // Size
                Row(
                  children: [
                    Text(
                      entry.sizeDisplay,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // Status code
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(entry).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _getStatusText(entry),
                    style: TextStyle(
                      color: _getStatusColor(entry),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.language,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'No network requests',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Network requests will appear here when your app makes API calls',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getMethodColor(String method) {
    switch (method.toUpperCase()) {
      case 'GET':
        return const Color(0xFF4CAF50); // Green
      case 'POST':
        return const Color(0xFF2196F3); // Blue
      case 'PUT':
        return const Color(0xFFFF9800); // Orange
      case 'DELETE':
        return const Color(0xFFF44336); // Red
      case 'PATCH':
        return const Color(0xFF9C27B0); // Purple
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(UnifiedNetworkLog entry) {
    if (entry.hasNetworkError) {
      return const Color(0xFFF44336); // Red
    }

    final statusCode = entry.statusCode;
    if (statusCode == null) {
      return Colors.grey; // Pending
    }

    if (statusCode >= 200 && statusCode < 300) {
      return const Color(0xFF4CAF50); // Green
    } else if (statusCode >= 400) {
      return const Color(0xFFF44336); // Red
    } else {
      return const Color(0xFFFF9800); // Orange
    }
  }

  String _getStatusText(UnifiedNetworkLog entry) {
    if (entry.hasNetworkError) {
      return 'Error';
    }

    final statusCode = entry.statusCode;
    if (statusCode == null) {
      return 'Pending';
    }

    return statusCode.toString();
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final logDate = DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (logDate == today) {
      // Today - show time only
      return '${timestamp.hour.toString().padLeft(2, '0')}:'
          '${timestamp.minute.toString().padLeft(2, '0')}:'
          '${timestamp.second.toString().padLeft(2, '0')}';
    } else {
      // Other day - show date and time
      return '${timestamp.month}/${timestamp.day} '
          '${timestamp.hour.toString().padLeft(2, '0')}:'
          '${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
}
