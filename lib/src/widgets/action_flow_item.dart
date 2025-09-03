import 'package:digia_inspector/digia_inspector.dart';
import 'package:digia_inspector/src/models/action_flow_log_entry.dart';
import 'package:flutter/material.dart';

import 'status_indicator.dart';
import 'action_child_item.dart';

/// Widget for displaying ActionFlowLogEntry objects with hierarchical action flows
class ActionFlowItem extends StatefulWidget {
  final ActionFlowLogEntry actionFlow;

  const ActionFlowItem({
    Key? key,
    required this.actionFlow,
  }) : super(key: key);

  @override
  State<ActionFlowItem> createState() => _ActionFlowItemState();
}

class _ActionFlowItemState extends State<ActionFlowItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Column(
        children: [
          // Main flow header
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Flow title and status
                  Row(
                    children: [
                      StatusIndicator(
                        status: widget.actionFlow.rootAction.status.name,
                        size: 18.0,
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Action Flow',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            if (widget.actionFlow.id.isNotEmpty)
                              Text(
                                'ID: ${widget.actionFlow.id}',
                                style: Theme.of(context).textTheme.labelSmall!
                                    .copyWith(
                                      color: Colors.grey[600],
                                    ),
                              ),
                          ],
                        ),
                      ),
                      // Expand/collapse icon
                      Icon(
                        _isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: Colors.grey[600],
                      ),
                    ],
                  ),

                  const SizedBox(height: 8.0),

                  // Flow summary
                  _buildFlowSummary(),

                  const SizedBox(height: 8.0),

                  // Progress bar
                  _buildProgressBar(),

                  const SizedBox(height: 4.0),

                  // Additional flow details
                  _buildFlowDetails(),
                ],
              ),
            ),
          ),

          // Expandable child actions
          if (_isExpanded && widget.actionFlow.actions.isNotEmpty)
            _buildChildActionsList(),
        ],
      ),
    );
  }

  /// Builds the flow summary with action counts
  Widget _buildFlowSummary() {
    final totalActions = widget.actionFlow.actions.length;
    final completedActions = widget.actionFlow.actions
        .where((action) => action.status.name.toLowerCase() == 'completed')
        .length;
    final failedActions = widget.actionFlow.actions
        .where(
          (action) =>
              ['error', 'failed'].contains(action.status.name.toLowerCase()),
        )
        .length;

    return Row(
      children: [
        _buildSummaryChip('Total', totalActions.toString(), Colors.grey[700]!),
        const SizedBox(width: 8.0),
        _buildSummaryChip(
          'Completed',
          completedActions.toString(),
          Colors.green,
        ),
        if (failedActions > 0) ...[
          const SizedBox(width: 8.0),
          _buildSummaryChip('Failed', failedActions.toString(), Colors.red),
        ],
      ],
    );
  }

  /// Builds a summary chip for action counts
  Widget _buildSummaryChip(String label, String count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        '$label: $count',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// Builds the progress bar
  Widget _buildProgressBar() {
    final totalActions = widget.actionFlow.actions.length;
    final completedActions = widget.actionFlow.actions
        .where((action) => action.status.name.toLowerCase() == 'completed')
        .length;

    final progress = totalActions > 0 ? completedActions / totalActions : 0.0;
    final progressColor = _getProgressColor();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress',
              style: Theme.of(context).textTheme.labelSmall!.copyWith(
                color: Colors.grey[600],
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4.0),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(progressColor),
          minHeight: 4.0,
        ),
      ],
    );
  }

  /// Gets the appropriate color for the progress bar
  Color _getProgressColor() {
    final status = widget.actionFlow.rootAction.status.name.toLowerCase();
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'error':
      case 'failed':
        return Colors.red;
      case 'running':
      case 'in_progress':
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }

  /// Builds additional flow details
  Widget _buildFlowDetails() {
    return Row(
      children: [
        // Trigger name
        if (widget.actionFlow.rootAction.triggerName.isNotEmpty) ...[
          Icon(
            Icons.play_arrow,
            size: 14.0,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 4.0),
          Text(
            widget.actionFlow.rootAction.triggerName,
            style: Theme.of(context).textTheme.labelSmall!.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],

        // Source chain
        if (widget.actionFlow.rootAction.sourceChain.isNotEmpty) ...[
          if (widget.actionFlow.rootAction.triggerName.isNotEmpty)
            const SizedBox(width: 12.0),
          Icon(
            Icons.link,
            size: 14.0,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 4.0),
          Expanded(
            child: Text(
              widget.actionFlow.rootAction.sourceChain.join(' → '),
              style: Theme.of(context).textTheme.labelSmall!.copyWith(
                color: Colors.grey[600],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }

  /// Builds the expandable list of child actions
  Widget _buildChildActionsList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          top: BorderSide(
            color: Colors.grey[200]!,
            width: 1.0,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
              child: Text(
                'Actions (${widget.actionFlow.actions.length})',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
            ),
            ...widget.actionFlow.actions.asMap().entries.map((entry) {
              final index = entry.key;
              final action = entry.value;
              final isLastChild = index == widget.actionFlow.actions.length - 1;

              return ActionChildItem(
                action: ActionLogEntry.fromActionLog(action),
                isLastChild: isLastChild,
              );
            }),
          ],
        ),
      ),
    );
  }
}
