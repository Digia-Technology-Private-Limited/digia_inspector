import 'package:digia_inspector/src/models/action_flow_ui_entry.dart';
import 'package:digia_inspector/src/theme/app_colors.dart';
import 'package:digia_inspector/src/theme/app_dimensions.dart';
import 'package:digia_inspector/src/theme/app_typography.dart';
import 'package:digia_inspector/src/utils/action_utils.dart';
import 'package:digia_inspector/src/utils/extensions.dart';
import 'package:digia_inspector/src/widgets/action/action_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Bottom sheet showing detailed action flow information
class ActionDetailBottomSheet extends StatefulWidget {
  const ActionDetailBottomSheet({
    required this.flow,
    super.key,
    this.isWebView = false,
    this.onClose,
  });

  final ActionFlowUIEntry flow;
  final bool isWebView;
  final VoidCallback? onClose;

  @override
  State<ActionDetailBottomSheet> createState() =>
      _ActionDetailBottomSheetState();
}

class _ActionDetailBottomSheetState extends State<ActionDetailBottomSheet> {
  @override
  Widget build(BuildContext context) {
    if (widget.isWebView) {
      return Container(
        decoration: const BoxDecoration(
          color: InspectorColors.surfaceElevated,
        ),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildContent()),
          ],
        ),
      );
    }

    final mediaQuery = MediaQuery.of(context);
    final maxHeight = mediaQuery.size.height * 0.9;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: const BoxDecoration(
        color: InspectorColors.backgroundPrimary,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(InspectorSpacing.lg),
          topRight: Radius.circular(InspectorSpacing.lg),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandle(),
          _buildHeader(),
          Flexible(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.only(top: InspectorSpacing.sm),
      width: 36,
      height: 4,
      decoration: BoxDecoration(
        color: InspectorColors.contentTertiary,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: InspectorSpacing.paddingMD,
      decoration: const BoxDecoration(
        color: InspectorColors.backgroundSecondary,
        border: Border(
          bottom: BorderSide(
            color: InspectorColors.separator,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            ActionLogUtils.getStatusIcon(widget.flow.statusSummary),
            color: ActionLogUtils.getStatusColor(widget.flow.statusSummary),
            size: InspectorIconSizes.lg,
          ),
          const SizedBox(width: InspectorSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.flow.displayName,
                  style: InspectorTypography.headline.copyWith(
                    color: InspectorColors.contentPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (widget.flow.sourceChain.isNotEmpty)
                  Text(
                    widget.flow.sourceChainDisplay,
                    style: InspectorTypography.subhead.copyWith(
                      color: InspectorColors.contentSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              if (widget.isWebView) {
                widget.onClose?.call();
              } else {
                Navigator.of(context).pop();
              }
            },
            icon: const Icon(
              Icons.close,
              color: InspectorColors.contentSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: InspectorSpacing.paddingMD,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFlowInfo(),
          const SizedBox(height: InspectorSpacing.lg),
          _buildActionsList(),
        ],
      ),
    );
  }

  Widget _buildFlowInfo() {
    return Container(
      padding: InspectorSpacing.paddingMD,
      decoration: BoxDecoration(
        color: InspectorColors.backgroundSecondary,
        borderRadius: InspectorBorderRadius.radiusLG,
        border: Border.all(
          color: InspectorColors.separator,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Flow Information',
            style: InspectorTypography.title3.copyWith(
              color: InspectorColors.contentPrimary,
            ),
          ),
          const SizedBox(height: InspectorSpacing.md),
          _buildInfoRow('Trigger', widget.flow.triggerName),
          _buildInfoRow('Status', widget.flow.statusSummary),
          _buildInfoRow('Actions', '${widget.flow.actionCount}'),
          _buildInfoRow('Progress', '${(widget.flow.progress * 100).toInt()}%'),
          _buildInfoRow('Timestamp', widget.flow.timestamp.networkLogFormat),
          if (widget.flow.sourceChain.isNotEmpty)
            _buildInfoSection('Widget Hierarchy', widget.flow.sourceChain),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: InspectorSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: InspectorTypography.subhead.copyWith(
                color: InspectorColors.contentSecondary,
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => _copyToClipboard(value),
              child: Text(
                value,
                style: InspectorTypography.body.copyWith(
                  color: InspectorColors.contentPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String label, List<String> items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: InspectorSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: InspectorTypography.subhead.copyWith(
              color: InspectorColors.contentSecondary,
            ),
          ),
          const SizedBox(height: InspectorSpacing.xs),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(left: InspectorSpacing.md),
              child: Row(
                children: [
                  const Icon(
                    Icons.arrow_right,
                    size: InspectorIconSizes.sm,
                    color: InspectorColors.contentTertiary,
                  ),
                  const SizedBox(width: InspectorSpacing.xs),
                  Expanded(
                    child: Text(
                      item,
                      style: InspectorTypography.body.copyWith(
                        color: InspectorColors.contentPrimary,
                      ),
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

  Widget _buildActionsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actions (${widget.flow.actionCount})',
          style: InspectorTypography.title3.copyWith(
            color: InspectorColors.contentPrimary,
          ),
        ),
        const SizedBox(height: InspectorSpacing.md),
        ...widget.flow.actions.asMap().entries.map((entry) {
          final index = entry.key;
          final action = entry.value;
          return Padding(
            padding: EdgeInsets.only(
              bottom: index < widget.flow.actions.length - 1
                  ? InspectorSpacing.sm
                  : 0,
            ),
            child: ActionItem(
              action: action,
              isChild: !action.isTopLevel,
              showDetails: true,
            ),
          );
        }),
      ],
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied to clipboard: $text'),
        duration: const Duration(seconds: 2),
        backgroundColor: InspectorColors.accent,
      ),
    );
  }
}
