import 'package:digia_inspector/src/state/inspector_controller.dart';
import 'package:digia_inspector/src/widgets/inspector_mobile_view.dart';
import 'package:flutter/material.dart';

/// Main debug inspector dashboard with Chrome DevTools-like interface.
///
/// This widget provides a tabbed interface for debugging different aspects
/// of the app including network requests, actions, and state management.
class InspectorDashboard extends StatefulWidget {
  const InspectorDashboard({
    required this.controller,
    super.key,
    this.onClose,
    this.initialTab = 0,
    this.isFullScreen = true,
  });

  /// The inspector controller managing log data.
  final InspectorController controller;

  /// Callback when the dashboard should be closed.
  final VoidCallback? onClose;

  /// Initial tab to display (0=Network, 1=Actions, 2=State).
  final int initialTab;

  /// Whether to show as full screen or overlay.
  final bool isFullScreen;

  @override
  State<InspectorDashboard> createState() => _InspectorDashboardState();
}

class _InspectorDashboardState extends State<InspectorDashboard> {
  @override
  Widget build(BuildContext context) {
    // Use the new mobile-first design
    return InspectorMobileView(
      controller: widget.controller,
      onClose: widget.onClose,
      initialTabIndex: widget.initialTab,
    );
  }
}
