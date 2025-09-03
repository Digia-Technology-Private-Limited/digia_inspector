/// Individual log entry item widget for displaying different types of log entries.
///
/// This file contains widgets for rendering different types of log entries
/// in a consistent and informative way. Each entry type has specialized
/// display logic while maintaining a unified interface.
///
/// The widgets include support for network requests with loading states,
/// error entries with severity indicators, and action/state entries with
/// contextual information.
///
/// Example usage:
/// ```dart
/// LogEntryItem(
///   entry: networkLogEntry,
///   isSelected: false,
///   onTap: () => showDetails(entry),
///   controller: inspectorController,
/// )
/// ```
library log_entry_item;

import 'package:digia_inspector/digia_inspector.dart';
import 'package:flutter/material.dart';

import '../extensions/network_log_extensions.dart';
import '../extensions/string_extensions.dart';
import '../models/error_log_entry.dart';
import '../models/plain_log_entry.dart';
import '../models/network_log_entry.dart';
import '../models/action_log_entry.dart';
import '../models/state_log_entry.dart';
import '../models/action_flow_log_entry.dart';
import '../state/inspector_controller.dart';
import 'action_flow_item.dart';

/// Widget for displaying individual log entries with type-specific formatting.
///
/// This widget automatically detects the entry type and renders it with
/// appropriate styling, icons, and information. It supports selection
/// highlighting and provides contextual actions like copying cURL commands.
class LogEntryItem extends StatelessWidget {
  /// Creates a new log entry item.
  ///
  /// The [entry] determines the display format and content. The [controller]
  /// provides access to additional functionality like logging actions.
  const LogEntryItem({
    super.key,
    required this.entry,
    required this.controller,
    this.isSelected = false,
    this.onTap,
    this.showTimestamp = true,
    this.maxContentLength = 100,
  });

  /// The log entry to display.
  final DigiaLogEvent entry;

  /// The inspector controller for additional functionality.
  final InspectorController controller;

  /// Whether this entry is currently selected.
  final bool isSelected;

  /// Callback invoked when the entry is tapped.
  final VoidCallback? onTap;

  /// Whether to show the timestamp in the entry.
  final bool showTimestamp;

  /// Maximum length for content preview before truncation.
  final int maxContentLength;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: isSelected ? 4 : 1,
      color: isSelected
          ? Theme.of(context).primaryColor.withOpacity(0.1)
          : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: _buildEntryContent(context),
        ),
      ),
    );
  }

  /// Builds the appropriate content based on entry type.
  Widget _buildEntryContent(BuildContext context) {
    switch (entry.runtimeType) {
      case NetworkLogEntry:
        return _buildNetworkEntry(context, entry as NetworkLogEntry);
      case ErrorLogEntry:
        return _buildErrorEntry(context, entry as ErrorLogEntry);
      case ActionLogEntry:
        return _buildActionEntry(context, entry as ActionLogEntry);
      case ActionFlowLogEntry:
        return _buildActionFlowEntry(context, entry as ActionFlowLogEntry);
      case StateLogEntry:
        return _buildStateEntry(context, entry as StateLogEntry);
      case PlainLogEntry:
        return _buildPlainEntry(context, entry as PlainLogEntry);
      default:
        return _buildGenericEntry(context);
    }
  }

  /// Builds content for network log entries.
  Widget _buildNetworkEntry(BuildContext context, NetworkLogEntry entry) {
    final statusColor = _getStatusColor(entry);
    final methodColor = _getMethodColor(entry.method);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Status indicator
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            // Method badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: methodColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(
                entry.method.toUpperCase(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: methodColor,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Status code (if available)
            if (entry.statusCode != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  entry.statusCode.toString(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            const Spacer(),
            // Duration
            Text(
              entry.asReadableDuration(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).disabledColor,
              ),
            ),
            const SizedBox(width: 8),
            // Copy cURL button
            IconButton(
              icon: const Icon(Icons.content_copy, size: 16),
              onPressed: () => _copyCurlCommand(context, entry),
              tooltip: 'Copy as cURL',
              constraints: const BoxConstraints(
                minWidth: 24,
                minHeight: 24,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // API Name / URL
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Primary text: API name if available, otherwise URL
            Tooltip(
              message: entry.apiName != null
                  ? '${entry.apiName}\n${entry.url}'
                  : entry.url,
              child: Text(
                entry.displayName.truncate(maxContentLength),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            // Secondary text: URL if API name is available
            if (entry.apiName != null) ...[
              const SizedBox(height: 2),
              Text(
                entry.url.truncate(maxContentLength),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).disabledColor,
                ),
              ),
            ],
          ],
        ),
        if (entry.error != null) ...[
          const SizedBox(height: 4),
          Text(
            'Error: ${entry.error!}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.red[700],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
        if (showTimestamp) ...[
          const SizedBox(height: 4),
          _buildTimestamp(context),
        ],
      ],
    );
  }

  /// Builds content for error log entries.
  Widget _buildErrorEntry(BuildContext context, ErrorLogEntry entry) {
    final severityColor = _getSeverityColor(entry.severity);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.error_outline,
              color: severityColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: severityColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(
                entry.severity.name.toUpperCase(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: severityColor,
                ),
              ),
            ),
            if (entry.context != null) ...[
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  entry.context!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).disabledColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Text(
          entry.error.toString().truncate(maxContentLength),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        if (showTimestamp) ...[
          const SizedBox(height: 4),
          _buildTimestamp(context),
        ],
      ],
    );
  }

  /// Builds content for action log entries.
  Widget _buildActionEntry(BuildContext context, ActionLogEntry entry) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.touch_app,
              color: Theme.of(context).primaryColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(
                'ACTION',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                StringExtensions(entry.action).toDisplayName(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).disabledColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '${entry.action}: ${entry.target}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        if (entry.parameters != null) ...[
          const SizedBox(height: 4),
          Text(
            entry.parameters.toString().truncate(maxContentLength),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).disabledColor,
              fontFamily: 'monospace',
            ),
          ),
        ],
        if (showTimestamp) ...[
          const SizedBox(height: 4),
          _buildTimestamp(context),
        ],
      ],
    );
  }

  /// Builds content for action flow log entries.
  Widget _buildActionFlowEntry(BuildContext context, ActionFlowLogEntry entry) {
    return ActionFlowItem(actionFlow: entry);
  }

  /// Builds content for state log entries.
  Widget _buildStateEntry(BuildContext context, StateLogEntry entry) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.data_object,
              color: Colors.blue[600],
              size: 20,
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(
                'STATE',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(
                entry.changeType.toUpperCase(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[700],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '${entry.stateName}: ${entry.changeType}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        if (entry.oldValue != null || entry.newValue != null) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              if (entry.oldValue != null) ...[
                Expanded(
                  child: Text(
                    'From: ${entry.oldValue.toString().truncate(50)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.red[600],
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
              if (entry.oldValue != null && entry.newValue != null)
                const SizedBox(width: 8),
              if (entry.newValue != null) ...[
                Expanded(
                  child: Text(
                    'To: ${entry.newValue.toString().truncate(50)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.green[600],
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
        if (showTimestamp) ...[
          const SizedBox(height: 4),
          _buildTimestamp(context),
        ],
      ],
    );
  }

  /// Builds content for plain log entries.
  Widget _buildPlainEntry(BuildContext context, PlainLogEntry entry) {
    final levelColor = _getLevelColor(entry.level);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              _getLevelIcon(entry.level),
              color: levelColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: levelColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(
                entry.level.name.toUpperCase(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: levelColor,
                ),
              ),
            ),
            if (entry.category != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).disabledColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  entry.category!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).disabledColor,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Text(
          entry.message.truncate(maxContentLength),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        if (showTimestamp) ...[
          const SizedBox(height: 4),
          _buildTimestamp(context),
        ],
      ],
    );
  }

  /// Builds content for generic/unknown entry types.
  Widget _buildGenericEntry(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.help_outline,
              color: Theme.of(context).disabledColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              StringExtensions(entry.eventType).toDisplayName(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).disabledColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          entry.description.truncate(maxContentLength),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        if (showTimestamp) ...[
          const SizedBox(height: 4),
          _buildTimestamp(context),
        ],
      ],
    );
  }

  /// Builds the timestamp display.
  Widget _buildTimestamp(BuildContext context) {
    return Text(
      _formatTimestamp(entry.timestamp),
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: Theme.of(context).disabledColor,
        fontFamily: 'monospace',
      ),
    );
  }

  /// Copies the cURL command for a network entry.
  Future<void> _copyCurlCommand(
    BuildContext context,
    NetworkLogEntry entry,
  ) async {
    final curlCommand = entry.toCurlCommand();
    if (curlCommand != null) {
      await curlCommand.copyToClipboard(
        context,
        label: 'cURL command',
      );

      // Log this action
      controller.logAction(
        'copy_curl',
        entry.url,
        parameters: {'method': entry.method},
      );
    }
  }

  /// Gets the appropriate color for network request status.
  Color _getStatusColor(NetworkLogEntry entry) {
    if (entry.isPending) {
      return Colors.orange;
    } else if (entry.isError) {
      return Colors.red;
    } else {
      return Colors.green;
    }
  }

  /// Gets the appropriate color for HTTP methods.
  Color _getMethodColor(String method) {
    switch (method.toUpperCase()) {
      case 'GET':
        return Colors.blue;
      case 'POST':
        return Colors.green;
      case 'PUT':
        return Colors.orange;
      case 'DELETE':
        return Colors.red;
      case 'PATCH':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  /// Gets the appropriate color for error severity.
  Color _getSeverityColor(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.warning:
        return Colors.orange;
      case ErrorSeverity.error:
        return Colors.red;
      case ErrorSeverity.critical:
        return Colors.red[900]!;
    }
  }

  /// Gets the appropriate color for log levels.
  Color _getLevelColor(LogLevel level) {
    switch (level) {
      case LogLevel.verbose:
      case LogLevel.debug:
        return Colors.grey;
      case LogLevel.info:
        return Colors.blue;
      case LogLevel.warning:
        return Colors.orange;
      case LogLevel.error:
      case LogLevel.critical:
        return Colors.red;
    }
  }

  /// Gets the appropriate icon for log levels.
  IconData _getLevelIcon(LogLevel level) {
    switch (level) {
      case LogLevel.verbose:
      case LogLevel.debug:
        return Icons.info_outline;
      case LogLevel.info:
        return Icons.info;
      case LogLevel.warning:
        return Icons.warning;
      case LogLevel.error:
      case LogLevel.critical:
        return Icons.error;
    }
  }

  /// Formats a timestamp for display.
  String _formatTimestamp(DateTime timestamp) {
    final local = timestamp.toLocal();
    return '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}:'
        '${local.second.toString().padLeft(2, '0')}'
        '.${local.millisecond.toString().padLeft(3, '0')}';
  }
}
