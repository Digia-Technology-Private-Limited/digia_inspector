import 'package:digia_inspector/src/models/network_log_ui_entry.dart';
import 'package:digia_inspector/src/theme_system.dart';
import 'package:digia_inspector/src/utils/extensions.dart';
import 'package:digia_inspector/src/utils/network_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Bottom sheet for displaying detailed network request information
class NetworkDetailBottomSheet extends StatefulWidget {
  final NetworkLogUIEntry log;

  const NetworkDetailBottomSheet({
    super.key,
    required this.log,
  });

  @override
  State<NetworkDetailBottomSheet> createState() =>
      _NetworkDetailBottomSheetState();
}

class _NetworkDetailBottomSheetState extends State<NetworkDetailBottomSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    final tabCount = widget.log.method.hasRequestBody ? 3 : 2;
    _tabController = TabController(length: tabCount, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: InspectorColors.surfaceElevated,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(InspectorBorderRadius.xl),
              topRight: Radius.circular(InspectorBorderRadius.xl),
            ),
          ),
          child: Column(
            children: [
              _buildHeader(),
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildHeadersTab(scrollController),
                    if (widget.log.method.hasRequestBody)
                      _buildPayloadTab(scrollController),
                    _buildResponseTab(scrollController),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    final displayName = NetworkLogUtils.getDisplayName(widget.log);

    return Container(
      padding: InspectorSpacing.paddingMD,
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: InspectorColors.separator,
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: InspectorColors.contentTertiary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: InspectorSpacing.md),
          // Title row
          Row(
            children: [
              Icon(
                Icons.language,
                size: InspectorIconSizes.md,
                color: InspectorColors.accent,
              ),
              const SizedBox(width: InspectorSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.log.method} $displayName',
                      style: InspectorTypography.headline.copyWith(
                        color: InspectorColors.contentPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.close,
                  color: InspectorColors.contentSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    final showPayload = widget.log.method.hasRequestBody;

    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: InspectorColors.separator,
            width: 0.5,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: InspectorColors.accent,
        indicatorWeight: 2,
        labelColor: InspectorColors.contentPrimary,
        unselectedLabelColor: InspectorColors.contentSecondary,
        labelStyle: InspectorTypography.subheadBold,
        unselectedLabelStyle: InspectorTypography.subhead,
        tabs: [
          const Tab(text: 'Headers'),
          if (showPayload) const Tab(text: 'Payload'),
          const Tab(text: 'Response'),
        ],
      ),
    );
  }

  Widget _buildHeadersTab(ScrollController scrollController) {
    return SingleChildScrollView(
      controller: scrollController,
      child: Padding(
        padding: InspectorSpacing.paddingMD,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeadersSection(
              title: 'General',
              count: _getGeneralHeaders().length,
              headers: _getGeneralHeaders(),
              initiallyExpanded: true,
            ),
            const SizedBox(height: InspectorSpacing.md),
            _buildHeadersSection(
              title: 'Request Headers',
              count: widget.log.requestHeaders.length,
              headers: NetworkLogUtils.formatHeaders(
                widget.log.requestHeaders,
              ),
              initiallyExpanded: false,
            ),
            if (widget.log.responseHeaders != null) ...[
              const SizedBox(height: InspectorSpacing.md),
              _buildHeadersSection(
                title: 'Response Headers',
                count: widget.log.responseHeaders!.length,
                headers: NetworkLogUtils.formatHeaders(
                  widget.log.responseHeaders!,
                ),
                initiallyExpanded: false,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPayloadTab(ScrollController scrollController) {
    return SingleChildScrollView(
      controller: scrollController,
      child: Padding(
        padding: InspectorSpacing.paddingMD,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.log.requestBody != null)
              _buildContentSection(
                title: 'Request Body',
                content: widget.log.requestBody,
              )
            else
              _buildEmptyContentMessage('No request payload'),
          ],
        ),
      ),
    );
  }

  Widget _buildResponseTab(ScrollController scrollController) {
    return SingleChildScrollView(
      controller: scrollController,
      child: Padding(
        padding: InspectorSpacing.paddingMD,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.log.responseBody != null)
              _buildContentSection(
                title: 'Response Body',
                content: widget.log.responseBody,
              )
            else if (widget.log.error != null)
              _buildErrorSection()
            else if (widget.log.isPending)
              _buildEmptyContentMessage('Response pending...')
            else
              _buildEmptyContentMessage('No response data'),
          ],
        ),
      ),
    );
  }

  Widget _buildHeadersSection({
    required String title,
    required int count,
    required Map<String, String> headers,
    bool initiallyExpanded = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: InspectorColors.separator,
          width: 1,
        ),
        borderRadius: InspectorBorderRadius.radiusMD,
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          title: Text(
            '$title ($count)',
            style: InspectorTypography.subheadBold.copyWith(
              color: InspectorColors.contentPrimary,
            ),
          ),
          iconColor: InspectorColors.contentPrimary,
          collapsedIconColor: InspectorColors.contentSecondary,
          children: [
            if (headers.isEmpty)
              Padding(
                padding: InspectorSpacing.paddingMD,
                child: Text(
                  'No headers',
                  style: InspectorTypography.subhead.copyWith(
                    color: InspectorColors.contentTertiary,
                  ),
                ),
              )
            else
              ...headers.entries.map(
                (entry) => _buildKeyValueRow(entry.key, entry.value),
              ),
            const SizedBox(height: InspectorSpacing.sm),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyValueRow(String key, String value) {
    // Special handling for Status Code
    final isStatusCode = key == 'Status Code';
    Color? statusColor;

    if (isStatusCode && widget.log.statusCode != null) {
      statusColor = NetworkLogUtils.getStatusCodeColor(widget.log.statusCode);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: InspectorSpacing.md,
        vertical: 2,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              key,
              style: InspectorTypography.footnote.copyWith(
                color: InspectorColors.contentSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isStatusCode && statusColor != null)
                  Container(
                    margin: const EdgeInsets.only(right: 6),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                Expanded(
                  child: SelectableText(
                    value,
                    style: InspectorTypography.footnote.copyWith(
                      color: InspectorColors.contentPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentSection({
    required String title,
    required dynamic content,
  }) {
    final formattedContent = NetworkLogUtils.formatJsonForDisplay(content);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: InspectorColors.separator,
          width: 1,
        ),
        borderRadius: InspectorBorderRadius.radiusMD,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with copy button
          Container(
            padding: InspectorSpacing.paddingSM,
            decoration: const BoxDecoration(
              color: InspectorColors.backgroundPrimary,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(InspectorBorderRadius.md),
                topRight: Radius.circular(InspectorBorderRadius.md),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.code,
                  size: InspectorIconSizes.sm,
                  color: InspectorColors.contentSecondary,
                ),
                const SizedBox(width: InspectorSpacing.xs),
                Text(
                  title,
                  style: InspectorTypography.footnoteBold.copyWith(
                    color: InspectorColors.contentPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => _copyToClipboard(formattedContent),
                  icon: Icon(
                    Icons.copy,
                    size: InspectorIconSizes.sm,
                    color: InspectorColors.contentSecondary,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          // Content
          Container(
            width: double.infinity,
            padding: InspectorSpacing.paddingSM,
            child: SelectableText(
              formattedContent,
              style: InspectorTypography.monospace.copyWith(
                color: InspectorColors.contentPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorSection() {
    return Container(
      padding: InspectorSpacing.paddingMD,
      decoration: BoxDecoration(
        color: InspectorColors.statusError.withOpacity(0.1),
        border: Border.all(
          color: InspectorColors.statusError,
          width: 1,
        ),
        borderRadius: InspectorBorderRadius.radiusMD,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.error,
                color: InspectorColors.statusError,
                size: InspectorIconSizes.md,
              ),
              const SizedBox(width: InspectorSpacing.sm),
              Text(
                'Error Details',
                style: InspectorTypography.subheadBold.copyWith(
                  color: InspectorColors.statusError,
                ),
              ),
            ],
          ),
          const SizedBox(height: InspectorSpacing.sm),
          SelectableText(
            widget.log.error.toString(),
            style: InspectorTypography.subhead.copyWith(
              color: InspectorColors.contentPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyContentMessage(String message) {
    return Center(
      child: Padding(
        padding: InspectorSpacing.paddingXL,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox,
              size: 48,
              color: InspectorColors.contentTertiary,
            ),
            const SizedBox(height: InspectorSpacing.md),
            Text(
              message,
              style: InspectorTypography.subhead.copyWith(
                color: InspectorColors.contentSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Map<String, String> _getGeneralHeaders() {
    final headers = <String, String>{
      'Request URL': widget.log.url.toString(),
      'Request Method': widget.log.method,
    };

    if (widget.log.statusCode != null) {
      headers['Status Code'] = NetworkLogUtils.getStatusWithDescription(
        widget.log.statusCode,
      );
    }

    if (widget.log.url.host.isNotEmpty) {
      headers['Remote Address'] = widget.log.url.host;
    }

    return headers;
  }

  Future<void> _copyToClipboard(String text) async {
    final success = await ClipboardUtils.copyToClipboard(text);
    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Copied to clipboard',
            style: InspectorTypography.subhead.copyWith(
              color: InspectorColors.backgroundSecondary,
            ),
          ),
          backgroundColor: InspectorColors.contentPrimary,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
