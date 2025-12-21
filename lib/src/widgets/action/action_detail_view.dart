import 'package:digia_inspector/src/log_managers/action_log_manager.dart';
import 'package:digia_inspector/src/theme/app_colors.dart';
import 'package:digia_inspector/src/theme/app_dimensions.dart';
import 'package:digia_inspector/src/theme/app_typography.dart';
import 'package:digia_inspector/src/utils/action_utils.dart';
import 'package:digia_inspector/src/widgets/action/action_item.dart';
import 'package:digia_inspector_core/digia_inspector_core.dart';
import 'package:flutter/material.dart';

/// Bottom sheet showing detailed action flow information
class ActionDetailView extends StatefulWidget {
  /// Constructor
  const ActionDetailView({
    required this.actionLogManager,
    required this.flow,
    super.key,
    this.isWebView = false,
    this.onClose,
  });

  /// Action log manager
  final ActionLogManager actionLogManager;

  /// Action log
  final ActionLog flow;

  /// Whether to show the web view
  final bool isWebView;

  /// Callback when the widget is closed
  final VoidCallback? onClose;

  @override
  State<ActionDetailView> createState() => _ActionDetailViewState();
}

class _ActionDetailViewState extends State<ActionDetailView> {
  @override
  Widget build(BuildContext context) {
    // Listen to changes in the action log manager to get real-time updates
    return ValueListenableBuilder<List<ActionLog>>(
      valueListenable: widget.actionLogManager.allLogsNotifier,
      builder: (context, allLogs, child) {
        // Get the current version of the flow (in case it was updated)
        final currentFlow = widget.actionLogManager.getById(
          widget.flow.id,
        );
        if (currentFlow == null) {
          // Flow was deleted, close the bottom sheet
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              Navigator.of(context).pop();
            }
          });
          return const SizedBox.shrink();
        }

        return _buildContent(currentFlow);
      },
    );
  }

  Widget _buildContent(ActionLog currentFlow) {
    if (widget.isWebView) {
      return Container(
        decoration: BoxDecoration(
          color: context.inspectorColors.surfaceElevated,
        ),
        child: Column(
          children: [
            _buildHeader(currentFlow),
            Expanded(child: _buildContentBody(currentFlow)),
          ],
        ),
      );
    }

    final mediaQuery = MediaQuery.of(context);
    final maxHeight = mediaQuery.size.height * 0.9;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: BoxDecoration(
        color: context.inspectorColors.backgroundPrimary,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppSpacing.lg),
          topRight: Radius.circular(AppSpacing.lg),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!widget.isWebView) _buildHandle(),
          _buildHeader(currentFlow),
          Flexible(child: _buildContentBody(currentFlow)),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.sm),
      width: 36,
      height: 4,
      decoration: BoxDecoration(
        color: context.inspectorColors.contentTertiary,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader(ActionLog currentFlow) {
    return Container(
      padding: AppSpacing.paddingMD,
      decoration: BoxDecoration(
        color: context.inspectorColors.backgroundSecondary,
        border: Border(
          bottom: BorderSide(
            color: context.inspectorColors.borderDefault,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            ActionLogUtils.getStatusIcon(currentFlow.status.name),
            color: ActionLogUtils.getStatusColor(
              currentFlow.status.name,
              context.inspectorColors,
            ),
            size: AppIconSizes.lg,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentFlow.actionType,
                  style: context.inspectorTypography.headline.copyWith(
                    color: context.inspectorColors.contentPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (currentFlow.sourceChain?.isNotEmpty ?? false)
                  Text(
                    currentFlow.formattedSourceChain,
                    style: context.inspectorTypography.subhead.copyWith(
                      color: context.inspectorColors.contentSecondary,
                      fontSize: 14,
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
            icon: Icon(
              Icons.close,
              color: context.inspectorColors.contentSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentBody(ActionLog currentFlow) {
    return SingleChildScrollView(
      padding: AppSpacing.paddingMD,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFlowInfo(currentFlow),
          const SizedBox(height: AppSpacing.lg),
          _buildActionsList(currentFlow),
        ],
      ),
    );
  }

  Widget _buildFlowInfo(ActionLog currentFlow) {
    return Container(
      padding: AppSpacing.paddingMD,
      decoration: BoxDecoration(
        color: context.inspectorColors.backgroundSecondary,
        borderRadius: AppBorderRadius.radiusLG,
        border: Border.all(
          color: context.inspectorColors.borderDefault,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Trigger', currentFlow.triggerName ?? 'Unknown'),
          _buildInfoRow('Status', currentFlow.status.name),
          if (currentFlow.sourceChain?.isNotEmpty ?? false)
            _buildInfoSection(
                'Widget Hierarchy', currentFlow.sourceChain ?? []),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: context.inspectorTypography.subhead.copyWith(
                color: context.inspectorColors.contentSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: context.inspectorTypography.body.copyWith(
                color: context.inspectorColors.contentPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String label, List<String> items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: context.inspectorTypography.subhead.copyWith(
              color: context.inspectorColors.contentSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(left: AppSpacing.md),
              child: Row(
                children: [
                  Icon(
                    Icons.arrow_right,
                    size: AppIconSizes.sm,
                    color: context.inspectorColors.contentTertiary,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      item,
                      style: context.inspectorTypography.body.copyWith(
                        color: context.inspectorColors.contentPrimary,
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

  Widget _buildActionsList(ActionLog currentFlow) {
    final total = widget.actionLogManager.countActionsInFlow(currentFlow.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actions ($total)',
          style: context.inspectorTypography.title3.copyWith(
            color: context.inspectorColors.contentPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ..._buildActionTree(currentFlow, depth: 0),
      ],
    );
  }

  /// Build the full action tree recursively, returning a list of widgets
  /// with indentation based on depth.
  List<Widget> _buildActionTree(ActionLog node, {required int depth}) {
    final widgets = <Widget>[];

    final extraLeftIndent = depth > 1 ? (AppSpacing.lg * (depth - 1)) : 0.0;
    widgets.add(Padding(
      padding: EdgeInsets.only(
        top: depth == 0 ? 0 : AppSpacing.sm,
        left: extraLeftIndent,
      ),
      child: ActionItem(
        action: node,
        isChild: depth > 0,
        actionLogManager: widget.actionLogManager,
      ),
    ));

    final children = widget.actionLogManager.getChildren(node.id);
    for (final child in children) {
      widgets.addAll(_buildActionTree(child, depth: depth + 1));
    }

    return widgets;
  }
}
