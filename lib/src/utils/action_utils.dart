import 'package:digia_inspector/src/models/action_flow_ui_entry.dart';
import 'package:digia_inspector/src/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Utility class for action log operations and formatting
abstract class ActionLogUtils {
  /// Filters flows by status
  static List<ActionFlowUIEntry> filterFlowsByStatus(
    List<ActionFlowUIEntry> flows,
    ActionStatusFilter filter,
  ) {
    switch (filter) {
      case ActionStatusFilter.all:
        return flows;
      case ActionStatusFilter.pending:
        return flows.where((f) => f.isPending).toList();
      case ActionStatusFilter.running:
        return flows.where((f) => f.isRunning).toList();
      case ActionStatusFilter.completed:
        return flows.where((f) => f.isCompleted).toList();
      case ActionStatusFilter.error:
        return flows.where((f) => f.hasFailed).toList();
    }
  }

  /// Checks if a flow matches the search query
  static bool matchesFlowSearchQuery(ActionFlowUIEntry flow, String query) {
    if (query.isEmpty) return true;

    final searchQuery = query.toLowerCase();
    return flow.displayName.toLowerCase().contains(searchQuery) ||
        flow.triggerName.toLowerCase().contains(searchQuery) ||
        flow.sourceChain.any(
          (source) => source.toLowerCase().contains(searchQuery),
        ) ||
        flow.rootAction.actionType.toLowerCase().contains(searchQuery);
  }

  /// Gets color for action status
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return InspectorColors.statusSuccess;
      case 'error':
      case 'failed':
        return InspectorColors.statusError;
      case 'running':
        return InspectorColors.statusWarning;
      case 'pending':
        return InspectorColors.statusInfo;
      default:
        return InspectorColors.contentTertiary;
    }
  }

  /// Gets display text for action status
  static String getStatusDisplayText(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return 'completed';
      case 'error':
        return 'failed';
      case 'failed':
        return 'failed';
      case 'running':
        return 'running';
      case 'pending':
        return 'pending';
      default:
        return status;
    }
  }

  /// Gets icon for action status
  static IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Icons.check_circle;
      case 'error':
      case 'failed':
        return Icons.error;
      case 'running':
        return Icons.refresh;
      case 'pending':
        return Icons.schedule;
      default:
        return Icons.help_outline;
    }
  }

  /// Gets color for trigger type
  static Color getTriggerColor(String trigger) {
    switch (trigger.toLowerCase()) {
      case 'onclick':
      case 'click':
        return InspectorColors.accent;
      case 'onsubmit':
      case 'submit':
        return InspectorColors.methodPost;
      case 'onchange':
      case 'change':
        return InspectorColors.methodPut;
      case 'onload':
      case 'load':
        return InspectorColors.methodGet;
      case 'onvalidate':
      case 'validate':
        return InspectorColors.statusWarning;
      default:
        return InspectorColors.contentSecondary;
    }
  }

  /// Formats execution time for display
  static String formatExecutionTime(Duration? duration) {
    if (duration == null) return '';

    final ms = duration.inMilliseconds;
    if (ms < 1000) return '${ms}ms';
    if (ms < 60000) return '${(ms / 1000).toStringAsFixed(1)}s';

    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}m ${seconds}s';
  }

  /// Formats parameters for display (truncated)
  static String formatParameters(Map<String, dynamic> parameters) {
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
      return '$entries...';
    }

    return entries;
  }

  /// Gets progress color based on progress value
  static Color getProgressColor(double progress) {
    if (progress >= 1.0) return InspectorColors.statusSuccess;
    if (progress >= 0.5) return InspectorColors.statusWarning;
    return InspectorColors.statusInfo;
  }

  /// Gets formatted progress text
  static String getProgressText(double progress) {
    return '${(progress * 100).toInt()}%';
  }
}
