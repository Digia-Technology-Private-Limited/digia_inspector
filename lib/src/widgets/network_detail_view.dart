import 'package:digia_inspector/src/extensions/network_log_extensions.dart';
import 'package:digia_inspector/src/models/network_log_entry.dart';
import 'package:digia_inspector/src/widgets/headers_section.dart';
import 'package:digia_inspector/src/widgets/json_viewer.dart';
import 'package:flutter/material.dart';

/// Detailed view for network log entries with Chrome DevTools-like interface.
///
/// This widget provides comprehensive network request inspection with multiple
/// tabs for different aspects of the request/response cycle. It automatically
/// adapts the display based on the available data in the network entry.
class NetworkDetailView extends StatefulWidget {
  /// Creates a new network detail view.
  ///
  /// The [entry] contains all the network request/response information
  /// to display in the detailed interface.
  const NetworkDetailView({
    super.key,
    required this.entry,
  });

  /// The network log entry to display in detail.
  final NetworkLogEntry entry;

  @override
  State<NetworkDetailView> createState() => _NetworkDetailViewState();
}

class _NetworkDetailViewState extends State<NetworkDetailView>
    with SingleTickerProviderStateMixin {
  /// Tab controller for the detail view tabs.
  late TabController _tabController;

  /// Available tabs for the detail view.
  late List<_DetailTab> _tabs;

  @override
  void initState() {
    super.initState();
    _initializeTabs();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void didUpdateWidget(NetworkDetailView oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Reinitialize tabs if entry changed
    if (oldWidget.entry != widget.entry) {
      _initializeTabs();

      // Update tab controller if tab count changed
      if (_tabController.length != _tabs.length) {
        _tabController.dispose();
        _tabController = TabController(length: _tabs.length, vsync: this);
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Initializes the available tabs based on entry data.
  void _initializeTabs() {
    _tabs = [
      _DetailTab(
        name: 'Headers',
        icon: Icons.list,
        builder: _buildHeadersTab,
      ),
    ];

    // Add Payload tab if there's request body
    if (widget.entry.request.body != null && widget.entry.request.body is Map) {
      _tabs.add(
        _DetailTab(
          name: 'Payload',
          icon: Icons.upload,
          builder: _buildPayloadTab,
        ),
      );
    }

    // Add Response tab if there's response data
    if (widget.entry.response != null || widget.entry.statusCode != null) {
      if (widget.entry.response?.body is Map) {
        _tabs.add(
          _DetailTab(
            name: 'Response',
            icon: Icons.download,
            builder: _buildResponseTab,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildOverview(),
        _buildTabBar(),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: _tabs.map((tab) => tab.builder()).toList(),
          ),
        ),
      ],
    );
  }

  /// Builds the overview section with key request information.
  Widget _buildOverview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Request line
          Row(
            children: [
              _buildMethodBadge(),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // API name if available, otherwise URL
                    if (widget.entry.apiName != null) ...[
                      Text(
                        widget.entry.apiName!,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.entry.url,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).disabledColor,
                        ),
                      ),
                    ] else ...[
                      Text(
                        widget.entry.url,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Status and timing info
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _buildInfoChip(
                icon: Icons.info,
                label: 'Status',
                value: _getStatusText(),
                color: _getStatusColor(),
              ),
              _buildInfoChip(
                icon: Icons.timer,
                label: 'Duration',
                value: widget.entry.asReadableDuration(),
              ),
              if (widget.entry.responseSize != null)
                _buildInfoChip(
                  icon: Icons.data_usage,
                  label: 'Size',
                  value: widget.entry.formattedResponseSize,
                ),
              if (widget.entry.contentType != null)
                _buildInfoChip(
                  icon: Icons.description,
                  label: 'Type',
                  value: widget.entry.contentType!,
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds the method badge with appropriate coloring.
  Widget _buildMethodBadge() {
    final color = _getMethodColor(widget.entry.method);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        widget.entry.method.toUpperCase(),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  /// Builds an information chip with icon, label, and value.
  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required String value,
    Color? color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: color ?? Theme.of(context).disabledColor,
        ),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).disabledColor,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }

  /// Builds the tab bar for the detail sections.
  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 2,
          ),
        ),
        labelColor: Theme.of(context).primaryColor,
        unselectedLabelColor: Theme.of(context).textTheme.bodyMedium?.color,
        tabs: _tabs
            .map(
              (tab) => Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(tab.icon, size: 16),
                    const SizedBox(width: 4),
                    Text(tab.name),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  /// Builds the Headers tab content.
  Widget _buildHeadersTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // General information
          HeadersSection(
            title: 'General',
            icon: Icons.info,
            headers: {
              if (widget.entry.apiName != null)
                'API Name': widget.entry.apiName!,
              'Request URL': widget.entry.url,
              'Request Method': widget.entry.method.toUpperCase(),
              if (widget.entry.statusCode != null)
                'Status Code':
                    '${widget.entry.statusCode} ${widget.entry.statusDescription}',
              if (widget.entry.host != null)
                'Remote Address': widget.entry.host!,
            },
          ),

          // Response headers
          if (widget.entry.responseHeaders != null) ...[
            const SizedBox(height: 16),
            HeadersSection(
              title:
                  'Response Headers (${widget.entry.responseHeaders!.length})',
              icon: Icons.download,
              headers: Map<String, String>.from(
                widget.entry.responseHeaders!.map(
                  (k, v) => MapEntry(k, v.toString()),
                ),
              ),
              isCollapsible: true,
            ),
          ],

          // Request headers
          if (widget.entry.request.headers.isNotEmpty) ...[
            const SizedBox(height: 16),
            HeadersSection(
              title: 'Request Headers (${widget.entry.request.headers.length})',
              icon: Icons.upload,
              headers: Map<String, String>.from(
                widget.entry.request.headers.map(
                  (k, v) => MapEntry(k, v.toString()),
                ),
              ),
              isCollapsible: true,
            ),
          ],

          // Query parameters
          if (widget.entry.request.queryParameters.isNotEmpty) ...[
            const SizedBox(height: 16),
            HeadersSection(
              title:
                  'Query String Parameters (${widget.entry.request.queryParameters.length})',
              icon: Icons.search,
              headers: Map<String, String>.from(
                widget.entry.request.queryParameters.map(
                  (k, v) => MapEntry(k, v.toString()),
                ),
              ),
              isCollapsible: true,
            ),
          ],
        ],
      ),
    );
  }

  /// Builds the Payload tab content.
  Widget _buildPayloadTab() {
    final requestBody = widget.entry.request.body;

    if (requestBody == null) {
      return const Center(
        child: Text('No request payload'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.upload, size: 20),
              const SizedBox(width: 8),
              Text(
                'Request Payload',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.content_copy, size: 16),
                onPressed: () => _copyPayload(requestBody),
                tooltip: 'Copy Payload',
              ),
            ],
          ),
          const SizedBox(height: 16),
          JsonViewer(
            data: requestBody,
            title: 'Request Body',
            isCollapsible: false,
          ),
        ],
      ),
    );
  }

  /// Builds the Response tab content.
  Widget _buildResponseTab() {
    final responseBody = widget.entry.response?.body;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.download, size: 20),
              const SizedBox(width: 8),
              Text(
                'Response',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (responseBody != null)
                IconButton(
                  icon: const Icon(Icons.content_copy, size: 16),
                  onPressed: () => _copyResponse(responseBody),
                  tooltip: 'Copy Response',
                ),
            ],
          ),
          const SizedBox(height: 16),

          if (responseBody != null)
            JsonViewer(
              data: responseBody,
              title: 'Response Body',
              isCollapsible: false,
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 48,
                      color: Theme.of(context).disabledColor,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.entry.isPending
                          ? 'Response pending...'
                          : 'No response body',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).disabledColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Copies the request payload to clipboard.
  Future<void> _copyPayload(dynamic payload) async {
    final payloadString = payload.prettyJson;
    await payloadString.copyToClipboard(
      context,
      label: 'Request payload',
    );
  }

  /// Copies the response body to clipboard.
  Future<void> _copyResponse(dynamic response) async {
    final responseString = response.prettyJson;
    await responseString.copyToClipboard(
      context,
      label: 'Response body',
    );
  }

  /// Gets the status text for display.
  String _getStatusText() {
    if (widget.entry.isPending) {
      return 'Pending';
    } else if (widget.entry.statusCode != null) {
      return '${widget.entry.statusCode} ${widget.entry.statusDescription}';
    } else {
      return 'Unknown';
    }
  }

  /// Gets the appropriate color for the status.
  Color? _getStatusColor() {
    if (widget.entry.isPending) {
      return Colors.orange;
    } else if (widget.entry.isError) {
      return Colors.red;
    } else if (widget.entry.isSuccessful) {
      return Colors.green;
    }
    return null;
  }

  /// Gets the appropriate color for HTTP methods.
  Color _getMethodColor(String method) {
    switch (method.toUpperCase()) {
      case 'GET':
        return Colors.blue;
      case 'POST':
        return Colors.green;
      case 'PUT':
        return Colors.orange;
      case 'DELETE':
        return Colors.red;
      case 'PATCH':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}

/// Information about a detail tab.
class _DetailTab {
  const _DetailTab({
    required this.name,
    required this.icon,
    required this.builder,
  });

  /// Display name for the tab.
  final String name;

  /// Icon to display in the tab.
  final IconData icon;

  /// Builder function for the tab content.
  final Widget Function() builder;
}
