import 'dart:convert';

import 'package:digia_inspector_core/digia_inspector_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A detailed viewer for network requests, responses, and errors.
///
/// This widget displays comprehensive information about network activity
/// including headers, body content, timing, and error details.
class NetworkRequestViewer extends StatefulWidget {
  /// Creates a new network request viewer.
  const NetworkRequestViewer({
    required this.log,
    super.key,
  });

  /// The network log event to display.
  final DigiaLogEvent log;

  @override
  State<NetworkRequestViewer> createState() => _NetworkRequestViewerState();
}

class _NetworkRequestViewerState extends State<NetworkRequestViewer>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _getTabCount(), vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  int _getTabCount() {
    if (widget.log is NetworkErrorLog) {
      return 2; // Request + Error
    } else if (widget.log is NetworkResponseLog) {
      return 3; // Request + Response + Headers
    } else {
      return 2; // Request + Headers
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          children: [
            _buildHeader(),
            _buildTabs(),
            Expanded(child: _buildTabContent()),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: Row(
        children: [
          Icon(_getIconForLogType(), color: _getColorForLogType()),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.log.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  TimestampHelper.format(widget.log.timestamp),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    final tabs = <Tab>[];

    if (widget.log is NetworkRequestLog ||
        widget.log is NetworkResponseLog ||
        widget.log is NetworkErrorLog) {
      tabs.add(const Tab(text: 'Request'));
    }

    if (widget.log is NetworkResponseLog) {
      tabs.add(const Tab(text: 'Response'));
    }

    if (widget.log is NetworkErrorLog) {
      tabs.add(const Tab(text: 'Error'));
    } else {
      tabs.add(const Tab(text: 'Headers'));
    }

    return TabBar(
      controller: _tabController,
      tabs: tabs,
      labelColor: Colors.blue,
      unselectedLabelColor: Colors.grey,
      indicatorColor: Colors.blue,
    );
  }

  Widget _buildTabContent() {
    final views = <Widget>[];

    if (widget.log is NetworkRequestLog ||
        widget.log is NetworkResponseLog ||
        widget.log is NetworkErrorLog) {
      views.add(_buildRequestTab());
    }

    if (widget.log is NetworkResponseLog) {
      views.add(_buildResponseTab());
    }

    if (widget.log is NetworkErrorLog) {
      views.add(_buildErrorTab());
    } else {
      views.add(_buildHeadersTab());
    }

    return TabBarView(
      controller: _tabController,
      children: views,
    );
  }

  Widget _buildRequestTab() {
    final metadata = widget.log.metadata;
    final method = metadata['method'] as String? ?? 'GET';
    final url = metadata['url'] as String? ?? '';
    final headers = metadata['headers'] as Map<String, dynamic>? ?? {};
    final body = metadata['body'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection('Request Details', [
            _buildDetailRow('Method', method),
            _buildDetailRow('URL', url),
            if (metadata['requestSize'] != null)
              _buildDetailRow('Size', '${metadata['requestSize']} bytes'),
          ]),
          const SizedBox(height: 16),
          _buildSection('Request Headers', [
            if (headers.isEmpty)
              const Text('No headers', style: TextStyle(color: Colors.grey))
            else
              ...headers.entries.map(
                (entry) => _buildDetailRow(entry.key, entry.value.toString()),
              ),
          ]),
          if (body != null) ...[
            const SizedBox(height: 16),
            _buildSection('Request Body', [
              _buildBodyViewer(body),
            ]),
          ],
        ],
      ),
    );
  }

  Widget _buildResponseTab() {
    if (widget.log is! NetworkResponseLog) {
      return const Center(child: Text('No response data'));
    }

    final responseLog = widget.log as NetworkResponseLog;
    final metadata = responseLog.metadata;
    final statusCode = metadata['statusCode'] as int? ?? 0;
    final headers = metadata['headers'] as Map<String, dynamic>? ?? {};
    final body = metadata['body'];
    final duration = metadata['duration'] as int?;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection('Response Details', [
            _buildDetailRow(
              'Status Code',
              '$statusCode ${_getStatusText(statusCode)}',
            ),
            if (duration != null) _buildDetailRow('Duration', '${duration}ms'),
            if (metadata['responseSize'] != null)
              _buildDetailRow('Size', '${metadata['responseSize']} bytes'),
          ]),
          const SizedBox(height: 16),
          _buildSection('Response Headers', [
            if (headers.isEmpty)
              const Text('No headers', style: TextStyle(color: Colors.grey))
            else
              ...headers.entries.map(
                (entry) => _buildDetailRow(entry.key, entry.value.toString()),
              ),
          ]),
          if (body != null) ...[
            const SizedBox(height: 16),
            _buildSection('Response Body', [
              _buildBodyViewer(body),
            ]),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorTab() {
    if (widget.log is! NetworkErrorLog) {
      return const Center(child: Text('No error data'));
    }

    final errorLog = widget.log as NetworkErrorLog;
    final metadata = errorLog.metadata;
    final error = metadata['error'] as String? ?? 'Unknown error';
    final errorType = metadata['errorType'] as String? ?? '';
    final stackTrace = metadata['stackTrace'] as String?;
    final errorContext =
        metadata['errorContext'] as Map<String, dynamic>? ?? {};

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection('Error Details', [
            _buildDetailRow('Type', errorType),
            _buildDetailRow('Message', error),
            if (errorContext['statusCode'] != null)
              _buildDetailRow(
                'Status Code',
                errorContext['statusCode'].toString(),
              ),
          ]),
          if (errorContext.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildSection('Error Context', [
              ...errorContext.entries
                  .where((e) => e.key != 'statusCode')
                  .map(
                    (entry) =>
                        _buildDetailRow(entry.key, entry.value.toString()),
                  ),
            ]),
          ],
          if (stackTrace != null) ...[
            const SizedBox(height: 16),
            _buildSection('Stack Trace', [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  stackTrace,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
            ]),
          ],
        ],
      ),
    );
  }

  Widget _buildHeadersTab() {
    final metadata = widget.log.metadata;
    final headers = (metadata['headers'] as Map<String, dynamic>?) ?? {};

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: _buildSection('Headers', [
        if (headers.isEmpty)
          const Text('No headers', style: TextStyle(color: Colors.grey))
        else
          ...headers.entries.map(
            (entry) => _buildDetailRow(entry.key, entry.value.toString()),
          ),
      ]),
    );
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => _copyToClipboard(),
            child: const Text('Copy JSON'),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 2),
          SelectableText(
            value,
            style: const TextStyle(fontFamily: 'monospace'),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyViewer(dynamic body) {
    if (body == null) {
      return const Text('Empty body', style: TextStyle(color: Colors.grey));
    }

    String bodyString;
    bool isJson = false;

    try {
      if (body is String) {
        bodyString = body;
        // Try to parse as JSON to check if it's valid JSON
        try {
          final parsed = jsonDecode(body);
          bodyString = const JsonEncoder.withIndent('  ').convert(parsed);
          isJson = true;
        } catch (_) {
          // Not JSON, keep as string
        }
      } else {
        bodyString = const JsonEncoder.withIndent('  ').convert(body);
        isJson = true;
      }
    } catch (e) {
      bodyString = body.toString();
    }

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxHeight: 300),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: SelectableText(
              bodyString,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: isJson ? Colors.blue.shade800 : Colors.black,
              ),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: IconButton(
              icon: const Icon(Icons.copy, size: 16),
              onPressed: () => _copyBodyToClipboard(bodyString),
              tooltip: 'Copy body',
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForLogType() {
    if (widget.log is NetworkErrorLog) {
      return Icons.error;
    } else if (widget.log is NetworkResponseLog) {
      final statusCode = (widget.log as NetworkResponseLog).statusCode;
      if (statusCode >= 200 && statusCode < 300) {
        return Icons.check_circle;
      } else if (statusCode >= 400) {
        return Icons.error;
      } else {
        return Icons.info;
      }
    } else {
      return Icons.send;
    }
  }

  Color _getColorForLogType() {
    if (widget.log is NetworkErrorLog) {
      return Colors.red;
    } else if (widget.log is NetworkResponseLog) {
      final statusCode = (widget.log as NetworkResponseLog).statusCode;
      if (statusCode >= 200 && statusCode < 300) {
        return Colors.green;
      } else if (statusCode >= 400) {
        return Colors.red;
      } else {
        return Colors.orange;
      }
    } else {
      return Colors.blue;
    }
  }

  String _getStatusText(int statusCode) {
    switch (statusCode) {
      case 200:
        return 'OK';
      case 201:
        return 'Created';
      case 204:
        return 'No Content';
      case 400:
        return 'Bad Request';
      case 401:
        return 'Unauthorized';
      case 403:
        return 'Forbidden';
      case 404:
        return 'Not Found';
      case 500:
        return 'Internal Server Error';
      case 502:
        return 'Bad Gateway';
      case 503:
        return 'Service Unavailable';
      default:
        return '';
    }
  }

  void _copyToClipboard() {
    final json = const JsonEncoder.withIndent(
      '  ',
    ).convert(widget.log.toJson());
    Clipboard.setData(ClipboardData(text: json));
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard')),
    );
  }

  void _copyBodyToClipboard(String body) {
    Clipboard.setData(ClipboardData(text: body));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Body copied to clipboard')),
    );
  }
}
