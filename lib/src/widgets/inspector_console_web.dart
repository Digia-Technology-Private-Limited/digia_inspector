import 'package:digia_inspector/src/state/inspector_controller.dart';
import 'package:digia_inspector/src/widgets/inspector_dashboard.dart';
import 'package:flutter/material.dart';

/// Web-optimized console widget for the dashboard.
///
/// This is a legacy wrapper that now uses the unified InspectorDashboard.
/// Provides a Chrome DevTools-like experience with tabs for Network, Logs, Errors, etc.
/// Designed for desktop/web platforms with mouse and keyboard interaction.
class InspectorConsoleWeb extends StatelessWidget {
  const InspectorConsoleWeb({
    required this.controller,
    super.key,
    this.height = 400,
    this.width,
    this.isDockable = true,
  });

  final InspectorController controller;
  final double height;
  final double? width;
  final bool isDockable;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width ?? double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InspectorDashboard(
        controller: controller,
      ),
    );
  }
}
