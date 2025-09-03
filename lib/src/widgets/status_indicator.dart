import 'package:flutter/material.dart';

/// A reusable widget that maps action statuses to consistent colors and icons
class StatusIndicator extends StatelessWidget {
  final String status;
  final double size;

  const StatusIndicator({
    Key? key,
    required this.status,
    this.size = 16.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final statusData = _getStatusData(status);

    return Icon(
      statusData.icon,
      color: statusData.color,
      size: size,
    );
  }

  /// Maps status values to appropriate icons and colors
  _StatusData _getStatusData(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return _StatusData(
          icon: Icons.schedule,
          color: Colors.orange,
        );
      case 'running':
      case 'in_progress':
        return _StatusData(
          icon: Icons.play_circle_filled,
          color: Colors.blue,
        );
      case 'completed':
      case 'success':
        return _StatusData(
          icon: Icons.check_circle,
          color: Colors.green,
        );
      case 'error':
      case 'failed':
        return _StatusData(
          icon: Icons.error,
          color: Colors.red,
        );
      case 'disabled':
        return _StatusData(
          icon: Icons.disabled_by_default,
          color: Colors.grey,
        );
      case 'cancelled':
        return _StatusData(
          icon: Icons.cancel,
          color: Colors.orange[700]!,
        );
      case 'timeout':
        return _StatusData(
          icon: Icons.timer_off,
          color: Colors.amber[800]!,
        );
      default:
        // Fallback for custom status values
        return _StatusData(
          icon: Icons.help_outline,
          color: Colors.grey[600]!,
        );
    }
  }
}

/// Data class for status information
class _StatusData {
  final IconData icon;
  final Color color;

  _StatusData({
    required this.icon,
    required this.color,
  });
}

/// Extension to get status color for other components
extension StatusIndicatorExtension on String {
  Color get statusColor {
    switch (toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'running':
      case 'in_progress':
        return Colors.blue;
      case 'completed':
      case 'success':
        return Colors.green;
      case 'error':
      case 'failed':
        return Colors.red;
      case 'disabled':
        return Colors.grey;
      case 'cancelled':
        return Colors.orange.shade700;
      case 'timeout':
        return Colors.amber.shade800;
      default:
        return Colors.grey.shade600;
    }
  }
}
