import 'package:digia_inspector/src/log_managers/action_log_manager.dart';
import 'package:digia_inspector/src/theme/app_colors.dart';
import 'package:digia_inspector/src/theme/app_dimensions.dart';
import 'package:digia_inspector/src/theme/app_typography.dart';
import 'package:digia_inspector/src/utils/action_utils.dart';
import 'package:digia_inspector/src/utils/extensions.dart';
import 'package:digia_inspector_core/digia_inspector_core.dart';
import 'package:flutter/material.dart';

/// Widget for displaying individual action items with full details
class ActionItem extends StatefulWidget {
  /// Widget for displaying individual action items with full details
  const ActionItem({
    required this.action,
    super.key,
    this.isChild = false,
    this.actionLogManager,
  });

  /// Action log
  final ActionLog action;

  /// Whether the action is a child
  final bool isChild;

  /// Action log manager
  final ActionLogManager? actionLogManager;

  @override
  State<ActionItem> createState() => _ActionItemState();
}

class _ActionItemState extends State<ActionItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    // If we have an ActionLogManager, listen for real-time updates
    if (widget.actionLogManager != null) {
      return ValueListenableBuilder<List<ActionLog>>(
        valueListenable: widget.actionLogManager!.allLogsNotifier,
        builder: (context, allLogs, child) {
          // Get the current version of the action (in case it was updated)
          final currentAction = widget.actionLogManager!.getById(
            widget.action.id,
          );
          if (currentAction == null) {
            // Action was deleted, return empty container
            return const SizedBox.shrink();
          }
          return _buildActionItem(currentAction);
        },
      );
    }

    // Fallback to static display if no ActionLogManager provided
    return _buildActionItem(widget.action);
  }

  Widget _buildActionItem(ActionLog currentAction) {
    if (widget.isChild) {
      // For child items, create a stack with the indicator outside
      return Stack(
        clipBehavior: Clip.none,
        children: [
          // Child indicator positioned in the margin area
          Positioned(
            left: -AppSpacing.xs, // Position in the margin space
            top: AppSpacing.xs,
            child: _buildChildIndicator(),
          ),
          // Main container with reduced margin since indicator is outside
          Container(
            margin: const EdgeInsets.only(left: AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.backgroundSecondary,
              borderRadius: AppBorderRadius.radiusLG,
              border: Border.all(
                color: AppColors.borderDefault,
              ),
            ),
            child: InkWell(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              splashFactory: NoSplash.splashFactory,
              borderRadius: AppBorderRadius.radiusLG,
              child: Padding(
                padding: AppSpacing.paddingMD,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(currentAction),
                    if (_isExpanded) ...[
                      const SizedBox(height: AppSpacing.md),
                      _buildDetails(currentAction),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    // For parent items, no margin or indicator
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: AppBorderRadius.radiusLG,
        border: Border.all(
          color: AppColors.borderDefault,
        ),
      ),
      child: InkWell(
        onTap: () => setState(() => _isExpanded = !_isExpanded),
        splashFactory: NoSplash.splashFactory,
        borderRadius: AppBorderRadius.radiusLG,
        child: Padding(
          padding: AppSpacing.paddingMD,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(currentAction),
              if (_isExpanded) ...[
                const SizedBox(height: AppSpacing.md),
                _buildDetails(currentAction),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ActionLog currentAction) {
    return Row(
      children: [
        _buildStatusIndicator(currentAction),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: _buildActionInfo(currentAction)),
        if (currentAction.triggerName != null) ...[
          _buildTriggerChip(),
          const SizedBox(width: AppSpacing.sm),
        ],
        _buildExpandIcon(),
      ],
    );
  }

  Widget _buildTriggerChip() {
    final triggerName = widget.action.triggerName;
    // Display trigger name in a pill-shaped container
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.accent,
        ),
      ),
      child: Text(
        triggerName ?? 'Unknown',
        style: InspectorTypography.caption2.copyWith(
          color: AppColors.backgroundSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildChildIndicator() {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.contentTertiary,
        ),
      ),
      child: const Icon(
        Icons.subdirectory_arrow_right,
        size: AppIconSizes.xs,
        color: AppColors.contentTertiary,
      ),
    );
  }

  Widget _buildStatusIndicator(ActionLog currentAction) {
    final statusColor = ActionLogUtils.getStatusColor(
      currentAction.status.name,
    );
    final statusIcon = ActionLogUtils.getStatusIcon(currentAction.status.name);

    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor,
        ),
      ),
      child: Icon(
        statusIcon,
        size: AppIconSizes.sm,
        color: statusColor,
      ),
    );
  }

  Widget _buildActionInfo(ActionLog currentAction) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                currentAction.actionType,
                style: InspectorTypography.callout.copyWith(
                  color: AppColors.contentPrimary,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (currentAction.executionTime != null) ...[
              const SizedBox(width: AppSpacing.xs),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.searchBackground,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  ActionLogUtils.formatExecutionTime(
                    currentAction.executionTime,
                  ),
                  style: InspectorTypography.caption1.copyWith(
                    color: AppColors.contentSecondary,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            const Icon(
              Icons.schedule,
              size: AppIconSizes.xs,
              color: AppColors.contentTertiary,
            ),
            const SizedBox(width: 2),
            Text(
              currentAction.timestamp.networkLogFormat,
              style: InspectorTypography.footnote.copyWith(
                color: AppColors.contentSecondary,
              ),
            ),
            if (currentAction.sourceChain?.isNotEmpty ?? false) ...[
              const SizedBox(width: AppSpacing.sm),
              const Icon(
                Icons.link,
                size: AppIconSizes.xs,
                color: AppColors.contentTertiary,
              ),
              const SizedBox(width: 2),
              Expanded(
                child: Text(
                  currentAction.sourceChain?.last ?? 'Unknown',
                  style: InspectorTypography.footnote.copyWith(
                    color: AppColors.contentSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
        if (currentAction.errorMessage != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: AppColors.statusError.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: AppColors.statusError.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              currentAction.errorMessage!.length > 50
                  ? '${currentAction.errorMessage!.substring(0, 50)}...'
                  : currentAction.errorMessage!,
              style: InspectorTypography.caption1.copyWith(
                color: AppColors.statusError,
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
      size: AppIconSizes.md,
      color: AppColors.contentTertiary,
    );
  }

  Widget _buildDetails(ActionLog currentAction) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (currentAction.resolvedParameters.isNotEmpty)
          _buildParameters(currentAction),
        if (currentAction.actionDefinition.isNotEmpty)
          _buildDefinition(currentAction),
        if (currentAction.metadata.isNotEmpty) _buildMetadata(currentAction),
      ],
    );
  }

  Widget _buildParameters(ActionLog currentAction) {
    return _buildDetailSection(
      'Resolved Parameters',
      _buildJsonView(currentAction.resolvedParameters),
    );
  }

  Widget _buildDefinition(ActionLog currentAction) {
    return _buildDetailSection(
      'Action Definition',
      _buildJsonView(currentAction.actionDefinition),
    );
  }

  Widget _buildMetadata(ActionLog currentAction) {
    return _buildDetailSection(
      'Action Metadata',
      _buildJsonView(currentAction.metadata),
    );
  }

  Widget _buildDetailSection(String title, Widget content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: InspectorTypography.subheadBold.copyWith(
              color: AppColors.contentSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Container(
            width: double.infinity,
            padding: AppSpacing.paddingMD,
            decoration: BoxDecoration(
              color: AppColors.searchBackground,
              borderRadius: AppBorderRadius.radiusSM,
              border: Border.all(
                color: AppColors.separator,
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
      onTap: () => ClipboardUtils.copyToClipboardWithToast(
        context,
        jsonString,
      ),
      child: Text(
        jsonString,
        style: InspectorTypography.monospace.copyWith(
          color: AppColors.contentPrimary,
          fontSize: 11,
        ),
      ),
    );
  }

  String _formatJson(Map<String, dynamic> data) {
    if (data.isEmpty) return '{}';

    final entries = data.entries.map((entry) {
      final value = _formatValue(entry.value);
      return '  "${entry.key}": $value';
    }).join(',\n');

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
}
