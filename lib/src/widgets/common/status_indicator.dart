import 'package:flutter/material.dart';

/// A reusable widget that maps action statuses to consistent colors and icons
class StatusIndicator extends StatelessWidget {
  /// A reusable widget that maps action statuses to consistent colors and icons
  const StatusIndicator({
    required this.status,
    super.key,
    this.size = 16.0,
  });

  /// Status
  final String status;

  /// Size
  final double size;

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
  /// Status data
  _StatusData({
    required this.icon,
    required this.color,
  });

  /// Icon
  final IconData icon;
  final Color color;
}
