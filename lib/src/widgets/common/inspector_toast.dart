import 'package:flutter/material.dart';
import 'package:digia_inspector/src/theme/app_colors.dart';
import 'package:digia_inspector/src/theme/app_dimensions.dart';
import 'package:digia_inspector/src/theme/app_typography.dart';

class InspectorToast extends StatelessWidget {
  final String message;
  const InspectorToast({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 32),
          child: Material(
            color: Colors.transparent,
            child: IntrinsicWidth(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 320),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: AppBorderRadius.radiusLG,
                  boxShadow: AppElevation.cardShadow,
                ),
                padding: AppSpacing.paddingMD,
                margin: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.methodGet,
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        message,
                        style: InspectorTypography.callout.copyWith(
                          color: AppColors.contentPrimary,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void showInspectorToast(BuildContext context, String message) {
  final overlay = Overlay.of(context);
  final entry = OverlayEntry(
    builder: (ctx) => InspectorToast(message: message),
  );
  overlay.insert(entry);
  Future.delayed(const Duration(milliseconds: 1800), () {
    entry.remove();
  });
}
