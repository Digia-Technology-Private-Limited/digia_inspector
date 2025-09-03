import 'package:digia_inspector/src/models/action_log_entry.dart';
import 'package:digia_inspector/src/widgets/status_indicator.dart';
import 'package:flutter/material.dart';

/// Widget for displaying individual child actions within an action flow
class ActionChildItem extends StatelessWidget {
  const ActionChildItem({
    required this.action,
    Key? key,
    this.isLastChild = false,
  }) : super(key: key);

  final ActionLogEntry action;
  final bool isLastChild;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        left: 16.0,
        right: 8.0,
        bottom: isLastChild ? 0 : 4.0,
      ),
      child: Card(
        elevation: 1,
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status indicator
              StatusIndicator(
                status: action.status.name,
                size: 14.0,
              ),
              const SizedBox(width: 8.0),

              // Action content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Action name and target
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            action.action,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (action.target.isNotEmpty) ...[
                          const SizedBox(width: 4.0),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4.0,
                              vertical: 1.0,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            child: Text(
                              action.target,
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    fontSize: 10.0,
                                  ),
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 2.0),

                    // Execution details
                    Row(
                      children: [
                        // Execution time
                        if (action.parameters?['executionTime'] != null) ...[
                          Icon(
                            Icons.timer,
                            size: 10.0,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 2.0),
                          Text(
                            '${action.parameters?['executionTime']!.inMilliseconds}ms',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: Colors.grey[600],
                                  fontSize: 10.0,
                                ),
                          ),
                        ],

                        // Parameters (if any)
                        if (action.parameters?.isNotEmpty == true) ...[
                          if (action.parameters?['executionTime'] != null)
                            const SizedBox(width: 8.0),
                          Icon(
                            Icons.settings,
                            size: 10.0,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 2.0),
                          Expanded(
                            child: Text(
                              _formatParameters(action.parameters!),
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: Colors.grey[600],
                                    fontSize: 10.0,
                                  ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),

                    // Error message (if any)
                    if (action.parameters?['errorMessage'] != null &&
                        action.parameters?['errorMessage']! is String &&
                        (action.parameters?['errorMessage']! as String)
                            .isNotEmpty) ...[
                      const SizedBox(height: 2.0),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4.0,
                          vertical: 2.0,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(4.0),
                          border: Border.all(
                            color: Colors.red[200]!,
                            width: 0.5,
                          ),
                        ),
                        child: Text(
                          action.parameters?['errorMessage']! as String,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: Colors.red[700],
                                fontSize: 10.0,
                              ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Formats parameters map into a readable string
  String _formatParameters(Map<String, dynamic> parameters) {
    if (parameters.isEmpty) return '';

    final entries = parameters.entries
        .take(2)
        .map((entry) {
          final value = entry.value.toString();
          final truncatedValue = value.length > 20
              ? '${value.substring(0, 20)}...'
              : value;
          return '${entry.key}: $truncatedValue';
        })
        .join(', ');

    if (parameters.length > 2) {
      return '$entries, ...';
    }

    return entries;
  }
}
