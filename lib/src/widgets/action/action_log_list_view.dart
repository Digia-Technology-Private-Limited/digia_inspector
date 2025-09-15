import 'package:digia_inspector/src/log_managers/action_log_manager.dart';
import 'package:digia_inspector/src/theme/app_colors.dart';
import 'package:digia_inspector/src/theme/app_dimensions.dart';
import 'package:digia_inspector/src/theme/app_typography.dart';
import 'package:digia_inspector/src/widgets/action/action_detail_view.dart';
import 'package:digia_inspector/src/widgets/action/action_list_item.dart';
import 'package:digia_inspector_core/digia_inspector_core.dart';
import 'package:flutter/material.dart';

/// Action log list view
class ActionLogListView extends StatefulWidget {
  /// Constructor
  const ActionLogListView({
    required this.actionLogManager,
    super.key,
    this.onClearLogs,
    this.onItemTap,
  });

  /// Action log manager
  final ActionLogManager actionLogManager;

  /// Callback when logs are cleared
  final VoidCallback? onClearLogs;

  /// Callback when an item is tapped
  final ValueChanged<ActionLog>? onItemTap;

  @override
  State<ActionLogListView> createState() => _ActionLogListViewState();
}

class _ActionLogListViewState extends State<ActionLogListView> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<ActionLog>>(
      valueListenable: widget.actionLogManager.topLevelActionsNotifier,
      builder: (context, topLevelActions, child) {
        // Group actions by actionId to show only one item per unique action
        final groupedActions = _groupActionsByActionId(topLevelActions);

        return Column(
          children: [
            Expanded(
              child: groupedActions.isEmpty
                  ? _buildEmptyState()
                  : _buildActionList(groupedActions),
            ),
            _buildBottomBar(topLevelActions),
          ],
        );
      },
    );
  }

  /// Groups actions by actionId, keeping only the latest action
  List<ActionLog> _groupActionsByActionId(List<ActionLog> actions) {
    final latestActionsByActionId = <String, ActionLog>{};

    for (final action in actions) {
      final existing = latestActionsByActionId[action.id];
      if (existing == null || action.timestamp.isAfter(existing.timestamp)) {
        latestActionsByActionId[action.id] = action;
      }
    }

    return latestActionsByActionId.values.toList()
      ..sort(
        (a, b) => b.timestamp.compareTo(a.timestamp),
      ); // Sort by newest first
  }

  Widget _buildActionList(List<ActionLog> groupedActions) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      itemCount: groupedActions.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final flow = groupedActions[index];
        return ActionFlowListItem(
          actionLogManager: widget.actionLogManager,
          flow: flow,
          onTap: () {
            if (widget.onItemTap != null) {
              widget.onItemTap!(flow);
            } else {
              _showActionDetail(flow);
            }
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: AppSpacing.paddingXL,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.play_circle_outline,
              size: 64,
              color: AppColors.contentTertiary,
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              'No actions logged',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Action logs will appear here when your app performs actions',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(List<ActionLog> allActions) {
    // Group actions to get unique action IDs for display
    final groupedActions = _groupActionsByActionId(allActions);

    // Calculate total action count across all action IDs
    final totalActionCount = groupedActions.fold<int>(
      0,
      (sum, action) =>
          sum + widget.actionLogManager.countActionsInFlow(action.id),
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: const BoxDecoration(
        color: AppColors.backgroundPrimary,
        border: Border(
          top: BorderSide(
            color: AppColors.borderDefault,
          ),
        ),
      ),
      child: Text(
        groupedActions.length == 1
            ? '1 flow • $totalActionCount actions'
            : '${groupedActions.length} flows • $totalActionCount actions',
        style: InspectorTypography.footnote.copyWith(
          color: AppColors.contentPrimary,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  void _showActionDetail(ActionLog flow) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ActionDetailView(
        flow: flow,
        actionLogManager: widget.actionLogManager,
      ),
    );
  }
}
