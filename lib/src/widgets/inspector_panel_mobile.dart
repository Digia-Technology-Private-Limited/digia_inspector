import 'package:flutter/material.dart';
import '../state/inspector_controller.dart';
import 'inspector_dashboard.dart';

/// Mobile-optimized inspector panel for preview apps.
///
/// This is a legacy wrapper that now uses the unified InspectorDashboard.
/// Designed for touch interaction with larger tap targets and mobile-friendly navigation.
/// Can be shown as a bottom sheet or full-screen modal.
class InspectorPanelMobile extends StatelessWidget {
  final InspectorController controller;
  final double maxHeight;
  final bool showAsFullScreen;

  const InspectorPanelMobile({
    super.key,
    required this.controller,
    this.maxHeight = 600,
    this.showAsFullScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    if (showAsFullScreen) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Digia Inspector'),
          backgroundColor: Theme.of(context).colorScheme.surface,
        ),
        body: InspectorDashboard(
          controller: controller,
          onClose: () => Navigator.of(context).pop(),
        ),
      );
    } else {
      return Container(
        constraints: BoxConstraints(maxHeight: maxHeight),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            _buildHandle(context),
            Expanded(
              child: InspectorDashboard(
                controller: controller,
                // height: maxHeight - 16, // Account for handle height
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildHandle(BuildContext context) {
    return Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
