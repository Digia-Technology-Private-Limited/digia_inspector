import 'dart:convert';

import 'package:digia_inspector_core/digia_inspector_core.dart';
import 'package:flutter/material.dart';

/// Mobile-first network detail view that matches the design mockup.
///
/// This view provides comprehensive network request inspection with a three-tab
/// interface: General, Payload, Response. It automatically adapts the display
/// based on the available data in the unified network log.
class NetworkDetailView extends StatefulWidget {
  /// The unified network log entry to display in detail.
  final UnifiedNetworkLog entry;

  /// Callback when the user wants to go back to the list.
  final VoidCallback onBack;

  const NetworkDetailView({
    super.key,
    required this.entry,
    required this.onBack,
  });

  @override
  State<NetworkDetailView> createState() => _NetworkDetailViewState();
}

class _NetworkDetailViewState extends State<NetworkDetailView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildGeneralTab(),
                _buildPayloadTab(),
                _buildResponseTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF2D2D2D),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: widget.onBack,
      ),
      title: Text(
        widget.entry.displayName,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share, color: Colors.white),
          onPressed: () {
            // TODO: Implement share functionality
          },
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        border: Border(
          bottom: BorderSide(
            color: Color(0xFF333333),
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: const Color(0xFF007ACC),
        indicatorWeight: 3,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey,
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        tabs: const [
          Tab(text: 'General'),
          Tab(text: 'Payload'),
          Tab(text: 'Response'),
        ],
      ),
    );
  }

  Widget _buildGeneralTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overview section
          _buildExpandableSection(
            title: 'Overview',
            icon: Icons.info_outline,
            child: Column(
              children: [
                _buildInfoRow(
                  'Request URL',
                  widget.entry.request.url.toString(),
                ),
                _buildInfoRow('Request Method', widget.entry.request.method),
                if (widget.entry.statusCode != null)
                  _buildInfoRow('Status Code', '${widget.entry.statusCode}'),
                if (widget.entry.duration != null)
                  _buildInfoRow(
                    'Duration',
                    '${widget.entry.duration!.inMilliseconds}ms',
                  ),
                _buildInfoRow(
                  'Timestamp',
                  _formatTimestamp(widget.entry.timestamp),
                ),
                if (widget.entry.requestSize != null)
                  _buildInfoRow(
                    'Request Size',
                    _formatBytes(widget.entry.requestSize!),
                  ),
                if (widget.entry.responseSize != null)
                  _buildInfoRow(
                    'Response Size',
                    _formatBytes(widget.entry.responseSize!),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Request Headers section
          _buildExpandableSection(
            title: 'Request Headers',
            icon: Icons.upload,
            child: _buildHeadersList(widget.entry.request.headers),
          ),

          // Response Headers section (if available)
          if (widget.entry.response != null) ...[
            const SizedBox(height: 16),
            _buildExpandableSection(
              title: 'Response Headers',
              icon: Icons.download,
              child: _buildHeadersList(widget.entry.response!.headers),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPayloadTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Request Payload',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          if (widget.entry.request.body != null)
            _buildJsonViewer('Request Body', widget.entry.request.body)
          else
            _buildEmptyState('No request payload', Icons.upload),
        ],
      ),
    );
  }

  Widget _buildResponseTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Response Data',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          if (widget.entry.response != null &&
              widget.entry.response!.body != null)
            _buildJsonViewer('Response Body', widget.entry.response!.body)
          else if (widget.entry.error != null)
            _buildErrorDisplay()
          else if (widget.entry.isPending)
            _buildEmptyState('Response pending...', Icons.hourglass_empty)
          else
            _buildEmptyState('No response data', Icons.download),
        ],
      ),
    );
  }

  Widget _buildExpandableSection({
    required String title,
    required IconData icon,
    required Widget child,
    bool isExpanded = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF404040),
          width: 1,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          title: Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          iconColor: Colors.white,
          collapsedIconColor: Colors.grey,
          initiallyExpanded: isExpanded,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: child,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeadersList(Map<String, dynamic> headers) {
    if (headers.isEmpty) {
      return const Text(
        'No headers',
        style: TextStyle(
          color: Colors.grey,
          fontSize: 14,
        ),
      );
    }

    return Column(
      children: headers.entries.map((entry) {
        return _buildInfoRow(entry.key, entry.value.toString());
      }).toList(),
    );
  }

  Widget _buildJsonViewer(String title, dynamic data) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF404040),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFF333333),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.code, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.copy, color: Colors.grey, size: 16),
                  onPressed: () {
                    // TODO: Copy to clipboard
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: SelectableText(
              _formatJson(data),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorDisplay() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF44336).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFF44336),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.error, color: Color(0xFFF44336), size: 20),
              SizedBox(width: 8),
              Text(
                'Error Details',
                style: TextStyle(
                  color: Color(0xFFF44336),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SelectableText(
            widget.entry.error!.error.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  String _formatJson(dynamic data) {
    if (data == null) return 'null';

    try {
      if (data is String) {
        // Try to parse as JSON first
        try {
          final decoded = jsonDecode(data);
          return const JsonEncoder.withIndent('  ').convert(decoded);
        } catch (_) {
          return data;
        }
      } else {
        return const JsonEncoder.withIndent('  ').convert(data);
      }
    } catch (e) {
      return data.toString();
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-'
        '${timestamp.day.toString().padLeft(2, '0')} '
        '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')}:'
        '${timestamp.second.toString().padLeft(2, '0')}';
  }

  /// Formats bytes into human readable format (B, KB, MB).
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}
