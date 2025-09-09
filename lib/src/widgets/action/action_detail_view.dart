import 'package:digia_inspector/src/log_managers/action_log_manager.dart';
import 'package:digia_inspector/src/theme/app_colors.dart';
import 'package:digia_inspector/src/theme/app_dimensions.dart';
import 'package:digia_inspector/src/theme/app_typography.dart';
import 'package:digia_inspector/src/utils/action_utils.dart';
import 'package:digia_inspector/src/utils/extensions.dart';
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
          widget.flow.eventId,
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
        decoration: const BoxDecoration(
          color: AppColors.surfaceElevated,
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
      decoration: const BoxDecoration(
        color: AppColors.backgroundPrimary,
        borderRadius: BorderRadius.only(
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
        color: AppColors.contentTertiary,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader(ActionLog currentFlow) {
    return Container(
      padding: AppSpacing.paddingMD,
      decoration: const BoxDecoration(
        color: AppColors.backgroundSecondary,
        border: Border(
          bottom: BorderSide(
            color: AppColors.borderDefault,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            ActionLogUtils.getStatusIcon(currentFlow.status.name),
            color: ActionLogUtils.getStatusColor(currentFlow.status.name),
            size: AppIconSizes.lg,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentFlow.actionType,
                  style: InspectorTypography.headline.copyWith(
                    color: AppColors.contentPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (currentFlow.sourceChain.isNotEmpty)
                  Text(
                    currentFlow.formattedSourceChain,
                    style: InspectorTypography.subhead.copyWith(
                      color: AppColors.contentSecondary,
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
            icon: const Icon(
              Icons.close,
              color: AppColors.contentSecondary,
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
        color: AppColors.backgroundSecondary,
        borderRadius: AppBorderRadius.radiusLG,
        border: Border.all(
          color: AppColors.borderDefault,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Flow Information',
            style: InspectorTypography.title3.copyWith(
              color: AppColors.contentPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildInfoRow('Trigger', currentFlow.triggerName),
          _buildInfoRow('Status', currentFlow.status.name),
          _buildInfoRow(
            'Actions',
            '${widget.actionLogManager.countActions(currentFlow.eventId)}',
          ),
          _buildInfoRow(
            'Progress',
            // Progress data is a dynamic map
            // ignore: avoid_dynamic_calls
            '${(currentFlow.progressData?['progress'] ?? 0) * 100}%',
          ),
          _buildInfoRow('Timestamp', currentFlow.timestamp.networkLogFormat),
          if (currentFlow.sourceChain.isNotEmpty)
            _buildInfoSection('Widget Hierarchy', currentFlow.sourceChain),
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
              style: InspectorTypography.subhead.copyWith(
                color: AppColors.contentSecondary,
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => ClipboardUtils.copyToClipboardWithToast(
                context,
                value,
              ),
              child: Text(
                value,
                style: InspectorTypography.body.copyWith(
                  color: AppColors.contentPrimary,
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
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: InspectorTypography.subhead.copyWith(
              color: AppColors.contentSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(left: AppSpacing.md),
              child: Row(
                children: [
                  const Icon(
                    Icons.arrow_right,
                    size: AppIconSizes.sm,
                    color: AppColors.contentTertiary,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      item,
                      style: InspectorTypography.body.copyWith(
                        color: AppColors.contentPrimary,
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
    final children = widget.actionLogManager.getChildren(currentFlow.eventId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actions (${children.length + 1})', // +1 for the parent action
          style: InspectorTypography.title3.copyWith(
            color: AppColors.contentPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        // Show parent action first
        ActionItem(
          action: currentFlow,
          actionLogManager: widget.actionLogManager,
        ),
        // Show child actions with indentation
        ...children.asMap().entries.map((entry) {
          final index = entry.key;
          final action = entry.value;
          return Padding(
            padding: EdgeInsets.only(
              top: AppSpacing.sm,
              bottom: index < children.length - 1 ? AppSpacing.sm : 0,
            ),
            child: ActionItem(
              action: action,
              isChild: true,
              actionLogManager: widget.actionLogManager,
            ),
          );
        }),
      ],
    );
  }
}
