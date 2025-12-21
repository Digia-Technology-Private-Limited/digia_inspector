import 'dart:convert';

import 'package:digia_inspector/src/log_managers/network_log_manager.dart';
import 'package:digia_inspector/src/models/network_log_ui_entry.dart';
import 'package:digia_inspector/src/theme/theme_system.dart';
import 'package:digia_inspector/src/utils/extensions.dart';
import 'package:digia_inspector/src/utils/network_utils.dart';
import 'package:digia_inspector/src/widgets/json_viewer/monaco_json_view_stub.dart'
    if (dart.library.js) 'package:digia_inspector/src/widgets/json_viewer/monaco_json_viewer_web.dart'
    if (dart.library.io) 'package:digia_inspector/src/widgets/json_viewer/monaco_json_viewer_mobile.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Widget for displaying detailed network request information
class NetworkDetailView extends StatefulWidget {
  /// Constructor
  const NetworkDetailView({
    super.key,
    this.networkLogManager,
    this.logId,
    this.isWebView = false,
    this.onClose,
  });

  /// Network log manager to listen for updates
  final NetworkLogManager? networkLogManager;

  /// ID of the log to monitor
  final String? logId;

  /// Whether to show the web view
  final bool isWebView;

  /// Callback when the widget is closed
  final VoidCallback? onClose;

  @override
  State<NetworkDetailView> createState() => _NetworkDetailViewState();
}

class _NetworkDetailViewState extends State<NetworkDetailView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  /// Gets the current log, either from widget.log or by fetching from manager
  NetworkLogUIEntry? get currentLog {
    if (widget.networkLogManager != null && widget.logId != null) {
      final allEntries = widget.networkLogManager!.allEntries;
      return allEntries.cast<NetworkLogUIEntry?>().firstWhere(
            (entry) => entry?.id == widget.logId,
            orElse: () => null,
          );
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    final log = currentLog;
    final tabCount = log?.method.hasRequestBody ?? false ? 3 : 2;
    _tabController = TabController(length: tabCount, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If we have a network log manager, listen for changes
    if (widget.networkLogManager != null) {
      return ListenableBuilder(
        listenable: widget.networkLogManager!,
        builder: (context, child) => _buildContent(),
      );
    }

    // Otherwise, build static content
    return _buildContent();
  }

  Widget _buildContent() {
    final log = currentLog;
    if (log == null) {
      return Container(
        decoration: BoxDecoration(
          color: context.inspectorColors.surfaceElevated,
        ),
        child: const Center(
          child: Text('Log not found'),
        ),
      );
    }

    // Update tab count if it changed
    final tabCount = log.method.hasRequestBody ? 3 : 2;
    if (_tabController.length != tabCount) {
      _tabController.dispose();
      _tabController = TabController(length: tabCount, vsync: this);
    }
    if (widget.isWebView) {
      return Container(
        decoration: BoxDecoration(
          color: context.inspectorColors.surfaceElevated,
        ),
        child: Column(
          children: [
            _buildHeader(log),
            _buildTabBar(log),
            Expanded(
              child: TabBarView(
                physics: const NeverScrollableScrollPhysics(),
                controller: _tabController,
                children: [
                  _buildHeadersTab(null, log),
                  if (log.method.hasRequestBody) _buildPayloadTab(null, log),
                  _buildResponseTab(null, log),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: context.inspectorColors.surfaceElevated,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppBorderRadius.xl),
              topRight: Radius.circular(AppBorderRadius.xl),
            ),
          ),
          child: Column(
            children: [
              _buildHeader(log),
              _buildTabBar(log),
              Expanded(
                child: TabBarView(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: _tabController,
                  children: [
                    _buildHeadersTab(scrollController, log),
                    if (log.method.hasRequestBody)
                      _buildPayloadTab(scrollController, log),
                    _buildResponseTab(scrollController, log),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(NetworkLogUIEntry log) {
    final displayName = NetworkLogUtils.getDisplayName(log);

    return Container(
      padding: AppSpacing.paddingMD,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: context.inspectorColors.borderDefault,
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        children: [
          // Drag handle (hidden on web view)
          if (!widget.isWebView) ...[
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: context.inspectorColors.contentTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          // Title row
          Row(
            children: [
              Icon(
                Icons.language,
                size: AppIconSizes.md,
                color: context.inspectorColors.accent,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${log.method}: $displayName',
                          style: context.inspectorTypography.headline.copyWith(
                            fontSize: 16,
                            color: context.inspectorColors.contentPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.copy,
                              size: 18,
                              color: context.inspectorColors.contentSecondary),
                          tooltip: 'Copy as cURL',
                          onPressed: () async {
                            final curl = NetworkLogUtils.toCurl(log);
                            await ClipboardUtils.copyToClipboardWithToast(
                                context, curl);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  if (widget.isWebView) {
                    widget.onClose?.call();
                  } else {
                    Navigator.pop(context);
                  }
                },
                icon: Icon(
                  Icons.close,
                  color: context.inspectorColors.contentPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(NetworkLogUIEntry log) {
    final showPayload = log.method.hasRequestBody;

    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.md,
      ),
      child: TabBar(
        tabAlignment: TabAlignment.start,
        isScrollable: true,
        physics: const NeverScrollableScrollPhysics(),
        controller: _tabController,
        indicator: BoxDecoration(
          color: context.inspectorColors.backgroundTertiary,
          borderRadius: AppBorderRadius.radiusXXL,
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: context.inspectorColors.contentPrimary,
        unselectedLabelColor: context.inspectorColors.contentSecondary,
        labelStyle: context.inspectorTypography.subheadBold,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        splashFactory: NoSplash.splashFactory,
        labelPadding: const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        tabs: [
          const Tab(text: 'Headers'),
          if (showPayload) const Tab(text: 'Payload'),
          const Tab(text: 'Response'),
        ],
      ),
    );
  }

  Widget _buildHeadersTab(
    ScrollController? scrollController,
    NetworkLogUIEntry log,
  ) {
    return SingleChildScrollView(
      controller: scrollController,
      child: Padding(
        padding: AppSpacing.paddingMD,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeadersSection(
              title: 'General',
              count: _getGeneralHeaders(log).length,
              headers: _getGeneralHeaders(log),
              log: log,
              initiallyExpanded: true,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildHeadersSection(
              title: 'Request Headers',
              count: log.requestHeaders.length,
              headers: NetworkLogUtils.formatHeaders(
                log.requestHeaders,
              ),
              log: log,
            ),
            if (log.responseHeaders != null) ...[
              const SizedBox(height: AppSpacing.md),
              _buildHeadersSection(
                title: 'Response Headers',
                count: log.responseHeaders!.length,
                headers: NetworkLogUtils.formatHeaders(
                  log.responseHeaders!,
                ),
                log: log,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPayloadTab(
    ScrollController? scrollController,
    NetworkLogUIEntry log,
  ) {
    return SingleChildScrollView(
      controller: scrollController,
      child: Padding(
        padding: AppSpacing.paddingMD,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (log.requestBody != null)
              _buildContentSection(
                title: 'Request Body',
                content: log.requestBody,
              )
            else
              _buildEmptyContentMessage('No request payload'),
          ],
        ),
      ),
    );
  }

  Widget _buildResponseTab(
    ScrollController? scrollController,
    NetworkLogUIEntry log,
  ) {
    return SingleChildScrollView(
      controller: scrollController,
      child: Padding(
        padding: AppSpacing.paddingMD,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (log.responseBody != null)
              _buildContentSection(
                title: 'Response Body',
                content: log.responseBody,
              )
            else if (log.error != null)
              _buildErrorSection(log)
            else if (log.isPending)
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
    required NetworkLogUIEntry log,
    bool initiallyExpanded = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: context.inspectorColors.separator,
        ),
        borderRadius: AppBorderRadius.radiusMD,
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          title: Text(
            '$title ($count)',
            style: context.inspectorTypography.subheadBold.copyWith(
              color: context.inspectorColors.contentPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          iconColor: context.inspectorColors.contentPrimary,
          collapsedIconColor: context.inspectorColors.contentSecondary,
          children: [
            if (headers.isEmpty)
              Padding(
                padding: AppSpacing.paddingMD,
                child: Text(
                  'No headers',
                  style: context.inspectorTypography.subhead.copyWith(
                    color: context.inspectorColors.contentTertiary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            else
              ...headers.entries.map(
                (entry) => _buildKeyValueRow(entry.key, entry.value, log),
              ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyValueRow(String key, String value, NetworkLogUIEntry log) {
    // Special handling for Status Code
    final isStatusCode = key == 'Status Code';
    Color? statusColor;

    if (isStatusCode && log.statusCode != null) {
      statusColor = NetworkLogUtils.getStatusCodeColor(
          log.statusCode, context.inspectorColors);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 2,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              key,
              style: context.inspectorTypography.footnote.copyWith(
                color: context.inspectorColors.contentSecondary,
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
                    style: context.inspectorTypography.footnote.copyWith(
                      color: context.inspectorColors.contentPrimary,
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
    dynamic value = content;
    if (content is String) {
      try {
        value = NetworkLogUtils.tryDecodeJson(content) ?? content;
      } on Exception catch (_) {
        value = content;
      }
    }

    String pretty;
    try {
      pretty = const JsonEncoder.withIndent('  ').convert(value);
    } on Exception catch (_) {
      pretty = value.toString();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: context.inspectorTypography.subheadBold.copyWith(
            color: context.inspectorColors.contentPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        if (kIsWeb)
          MonacoJsonViewer(content: pretty)
        else
          SizedBox(
            child: MonacoJsonViewer(content: pretty),
          ),
      ],
    );
  }

  Widget _buildErrorSection(NetworkLogUIEntry log) {
    return Container(
      padding: AppSpacing.paddingMD,
      decoration: BoxDecoration(
        color: context.inspectorColors.statusError.withValues(alpha: 0.1),
        border: Border.all(
          color: context.inspectorColors.statusError,
        ),
        borderRadius: AppBorderRadius.radiusMD,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.error,
                color: context.inspectorColors.statusError,
                size: AppIconSizes.md,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Error Details',
                style: context.inspectorTypography.subheadBold.copyWith(
                  color: context.inspectorColors.statusError,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          SelectableText(
            log.error.toString(),
            style: context.inspectorTypography.subhead.copyWith(
              color: context.inspectorColors.contentPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyContentMessage(String message) {
    return Center(
      child: Padding(
        padding: AppSpacing.paddingXL,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox,
              size: 48,
              color: context.inspectorColors.contentTertiary,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              style: context.inspectorTypography.subhead.copyWith(
                color: context.inspectorColors.contentSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Map<String, String> _getGeneralHeaders(NetworkLogUIEntry log) {
    final headers = <String, String>{
      'Request URL': log.url.toString(),
      'Request Method': log.method,
      'Query Parameters': log.url.query.isEmpty ? '(none)' : log.url.query,
    };

    if (log.statusCode != null) {
      headers['Status Code'] = NetworkLogUtils.getStatusWithDescription(
        log.statusCode,
      );
    }

    if (log.url.host.isNotEmpty) {
      headers['Remote Address'] = log.url.host;
    }

    return headers;
  }
}
