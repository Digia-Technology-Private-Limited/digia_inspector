import 'package:digia_inspector/src/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Utility class for action log operations and formatting
abstract class ActionLogUtils {
  /// Gets color for action status
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return AppColors.statusSuccess;
      case 'error':
      case 'failed':
        return AppColors.statusError;
      case 'running':
        return AppColors.statusWarning;
      case 'pending':
        return AppColors.statusInfo;
      default:
        return AppColors.contentTertiary;
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
        return AppColors.accent;
      case 'onsubmit':
      case 'submit':
        return AppColors.methodPost;
      case 'onchange':
      case 'change':
        return AppColors.methodPut;
      case 'onload':
      case 'load':
        return AppColors.methodGet;
      case 'onvalidate':
      case 'validate':
        return AppColors.statusWarning;
      default:
        return AppColors.contentSecondary;
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

    final entries = parameters.entries.take(2).map((entry) {
      final value = entry.value.toString();
      final truncatedValue =
          value.length > 20 ? '${value.substring(0, 20)}...' : value;
      return '${entry.key}: $truncatedValue';
    }).join(', ');

    if (parameters.length > 2) {
      return '$entries...';
    }

    return entries;
  }

  /// Gets progress color based on progress value
  static Color getProgressColor(double progress) {
    if (progress >= 1.0) return AppColors.statusSuccess;
    if (progress >= 0.5) return AppColors.statusWarning;
    return AppColors.statusInfo;
  }

  /// Gets formatted progress text
  static String getProgressText(double progress) {
    return '${(progress * 100).toInt()}%';
  }
}
