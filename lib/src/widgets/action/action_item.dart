import 'package:digia_inspector/src/theme/app_colors.dart';
import 'package:digia_inspector/src/theme/app_dimensions.dart';
import 'package:digia_inspector/src/theme/app_typography.dart';
import 'package:digia_inspector/src/utils/action_utils.dart';
import 'package:digia_inspector/src/utils/extensions.dart';
import 'package:digia_inspector_core/digia_inspector_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Widget for displaying individual action items with full details
class ActionItem extends StatefulWidget {
  const ActionItem({
    super.key,
    required this.action,
    this.isChild = false,
    this.showDetails = false,
  });

  final ActionLog action;
  final bool isChild;
  final bool showDetails;

  @override
  State<ActionItem> createState() => _ActionItemState();
}

class _ActionItemState extends State<ActionItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.isChild
          ? const EdgeInsets.only(left: InspectorSpacing.lg)
          : EdgeInsets.zero,
      decoration: BoxDecoration(
        color: InspectorColors.backgroundSecondary,
        borderRadius: InspectorBorderRadius.radiusLG,
        border: Border.all(
          color: widget.isChild
              ? InspectorColors.separator.withOpacity(0.5)
              : InspectorColors.separator,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: InspectorBorderRadius.radiusLG,
        child: InkWell(
          onTap: widget.showDetails
              ? () => setState(() => _isExpanded = !_isExpanded)
              : null,
          borderRadius: InspectorBorderRadius.radiusLG,
          child: Padding(
            padding: InspectorSpacing.paddingMD,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                if (_isExpanded && widget.showDetails) ...[
                  const SizedBox(height: InspectorSpacing.md),
                  _buildDetails(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        _buildStatusIndicator(),
        const SizedBox(width: InspectorSpacing.sm),
        Expanded(child: _buildActionInfo()),
        if (widget.showDetails) _buildExpandIcon(),
      ],
    );
  }

  Widget _buildStatusIndicator() {
    final statusColor = ActionLogUtils.getStatusColor(
      widget.action.status.name,
    );
    final statusIcon = ActionLogUtils.getStatusIcon(widget.action.status.name);

    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor,
          width: 1,
        ),
      ),
      child: Icon(
        statusIcon,
        size: InspectorIconSizes.sm,
        color: statusColor,
      ),
    );
  }

  Widget _buildActionInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                widget.action.actionType,
                style: InspectorTypography.callout.copyWith(
                  color: InspectorColors.contentPrimary,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (widget.action.executionTime != null) ...[
              const SizedBox(width: InspectorSpacing.xs),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: InspectorSpacing.xs,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: InspectorColors.searchBackground,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  ActionLogUtils.formatExecutionTime(
                    widget.action.executionTime,
                  ),
                  style: InspectorTypography.caption1.copyWith(
                    color: InspectorColors.contentSecondary,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            Icon(
              Icons.schedule,
              size: InspectorIconSizes.xs,
              color: InspectorColors.contentTertiary,
            ),
            const SizedBox(width: 2),
            Text(
              widget.action.timestamp.networkLogFormat,
              style: InspectorTypography.footnote.copyWith(
                color: InspectorColors.contentSecondary,
              ),
            ),
            if (widget.action.sourceChain.isNotEmpty) ...[
              const SizedBox(width: InspectorSpacing.sm),
              Icon(
                Icons.link,
                size: InspectorIconSizes.xs,
                color: InspectorColors.contentTertiary,
              ),
              const SizedBox(width: 2),
              Expanded(
                child: Text(
                  widget.action.sourceChain.last,
                  style: InspectorTypography.footnote.copyWith(
                    color: InspectorColors.contentSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
        if (widget.action.errorMessage != null) ...[
          const SizedBox(height: InspectorSpacing.xs),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: InspectorSpacing.xs,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: InspectorColors.statusError.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: InspectorColors.statusError.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              widget.action.errorMessage!.length > 50
                  ? '${widget.action.errorMessage!.substring(0, 50)}...'
                  : widget.action.errorMessage!,
              style: InspectorTypography.caption1.copyWith(
                color: InspectorColors.statusError,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildExpandIcon() {
    return Icon(
      _isExpanded ? Icons.expand_less : Icons.expand_more,
      size: InspectorIconSizes.md,
      color: InspectorColors.contentTertiary,
    );
  }

  Widget _buildDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.action.sourceChain.isNotEmpty) _buildSourceChain(),
        if (widget.action.resolvedParameters.isNotEmpty) _buildParameters(),
        if (widget.action.actionDefinition.isNotEmpty) _buildDefinition(),
        if (widget.action.metadata.isNotEmpty) _buildMetadata(),
      ],
    );
  }

  Widget _buildSourceChain() {
    return _buildDetailSection(
      'Widget Hierarchy',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widget.action.sourceChain
            .map(
              (source) => Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Row(
                  children: [
                    const Icon(
                      Icons.arrow_right,
                      size: InspectorIconSizes.xs,
                      color: InspectorColors.contentTertiary,
                    ),
                    const SizedBox(width: InspectorSpacing.xs),
                    Expanded(
                      child: Text(
                        source,
                        style: InspectorTypography.caption1.copyWith(
                          color: InspectorColors.contentSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildParameters() {
    return _buildDetailSection(
      'Parameters',
      _buildJsonView(widget.action.resolvedParameters),
    );
  }

  Widget _buildDefinition() {
    return _buildDetailSection(
      'Definition',
      _buildJsonView(widget.action.actionDefinition),
    );
  }

  Widget _buildMetadata() {
    return _buildDetailSection(
      'Metadata',
      _buildJsonView(widget.action.metadata),
    );
  }

  Widget _buildDetailSection(String title, Widget content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: InspectorSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: InspectorTypography.subheadBold.copyWith(
              color: InspectorColors.contentSecondary,
            ),
          ),
          const SizedBox(height: InspectorSpacing.xs),
          Container(
            width: double.infinity,
            padding: InspectorSpacing.paddingMD,
            decoration: BoxDecoration(
              color: InspectorColors.searchBackground,
              borderRadius: InspectorBorderRadius.radiusSM,
              border: Border.all(
                color: InspectorColors.separator,
                width: 0.5,
              ),
            ),
            child: content,
          ),
        ],
      ),
    );
  }

  Widget _buildJsonView(Map<String, dynamic> data) {
    final jsonString = _formatJson(data);

    return GestureDetector(
      onTap: () => _copyToClipboard(jsonString),
      child: Text(
        jsonString,
        style: InspectorTypography.monospace.copyWith(
          color: InspectorColors.contentPrimary,
          fontSize: 11,
        ),
      ),
    );
  }

  String _formatJson(Map<String, dynamic> data) {
    if (data.isEmpty) return '{}';

    final entries = data.entries
        .map((entry) {
          final value = _formatValue(entry.value);
          return '  "${entry.key}": $value';
        })
        .join(',\n');

    return '{\n$entries\n}';
  }

  String _formatValue(dynamic value) {
    if (value == null) return 'null';
    if (value is String) return '"$value"';
    if (value is num || value is bool) return value.toString();
    if (value is List) return '[${value.length} items]';
    if (value is Map) return '{${value.length} keys}';
    return '"$value"';
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Copied to clipboard'),
        duration: const Duration(seconds: 2),
        backgroundColor: InspectorColors.accent,
      ),
    );
  }
}
