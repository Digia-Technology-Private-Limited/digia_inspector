import 'package:digia_inspector/src/theme/theme_system.dart';
import 'package:digia_inspector/src/utils/extensions.dart';
import 'package:digia_inspector/src/widgets/common/json_view.dart';
import 'package:flutter/material.dart';

/// Widget for displaying a single state variable with its value, type,
/// and timestamp
class StateVariableItem extends StatelessWidget {
  /// State variable item
  const StateVariableItem({
    required this.variableKey,
    required this.value,
    required this.lastUpdated,
    super.key,
  });

  /// Variable key
  final String variableKey;

  /// Value
  final dynamic value;

  /// Last updated
  final DateTime lastUpdated;

  @override
  Widget build(BuildContext context) {
    final type = _getValueType(value);
    final formattedValue = _formatValue(value);
    final timeString = _formatTimeStamp(lastUpdated);

    return Container(
      padding: AppSpacing.paddingSM,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: const BoxDecoration(
        color: AppColors.backgroundPrimary,
        borderRadius: AppBorderRadius.radiusMD,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      variableKey,
                      style: InspectorTypography.calloutBold.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      timeString,
                      style: InspectorTypography.caption1.copyWith(
                        color: AppColors.contentSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                if (value is Map || value is List)
                  JsonView(
                    value: value,
                    inline: true,
                    showCopyButton: false,
                  )
                else
                  Text(
                    formattedValue,
                    style: InspectorTypography.title3.copyWith(
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          InkWell(
            onTap: () => ClipboardUtils.copyToClipboardWithToast(
              context,
              value.toString(),
              customMessage: 'Value copied',
            ),
            child: const Icon(
              Icons.copy,
              size: 14,
              color: AppColors.contentSecondary,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: const BoxDecoration(
              color: AppColors.backgroundSecondary,
              borderRadius: AppBorderRadius.radiusSM,
            ),
            child: Text(
              type,
              style: InspectorTypography.caption1.copyWith(
                color: AppColors.contentSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getValueType(dynamic value) {
    if (value == null) return 'null';
    if (value is String) return 'string';
    if (value is num) return 'number';
    if (value is bool) return 'boolean';
    if (value is List) return 'array';
    if (value is Map) return 'object';
    return 'unknown';
  }

  String _formatValue(dynamic value) {
    if (value == null) return 'null';
    if (value is String) return '"$value"';
    if (value is Map) {
      final length = value.length;
      return 'object ($length propert${length == 1 ? 'y' : 'ies'})';
    }
    if (value is List) {
      final length = value.length;
      return 'array ($length item${length == 1 ? '' : 's'})';
    }
    return value.toString();
  }

  String _formatTimeStamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inSeconds < 5) {
      return 'Updated just now';
    } else if (diff.inSeconds < 60) {
      return 'Updated ${diff.inSeconds}s ago';
    } else if (diff.inMinutes < 60) {
      return 'Updated ${diff.inMinutes}m ago';
    } else {
      // Format as HH:MM:SS
      final hour = timestamp.hour;
      final minute = timestamp.minute.toString().padLeft(2, '0');
      final second = timestamp.second.toString().padLeft(2, '0');
      return 'Updated $hour:$minute:$second';
    }
  }
}
