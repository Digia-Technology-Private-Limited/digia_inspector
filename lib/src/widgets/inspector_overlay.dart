import 'package:digia_inspector/src/state/inspector_controller.dart';
import 'package:digia_inspector/src/widgets/inspector_dashboard.dart';
import 'package:flutter/material.dart';

/// A draggable floating overlay that provides access to the debugging inspector.
///
/// This widget displays a floating action button that can be dragged around
/// the screen and tapped to show/hide the debug console.
class InspectorOverlay extends StatefulWidget {
  /// Creates a new inspector overlay.
  const InspectorOverlay({
    required this.controller,
    super.key,
    this.initialPosition,
    this.buttonSize = 56.0,
  });

  /// The inspector controller to use.
  final InspectorController controller;

  /// The initial position of the overlay button.
  final Offset? initialPosition;

  /// The size of the overlay button.
  final double buttonSize;

  @override
  State<InspectorOverlay> createState() => _InspectorOverlayState();
}

class _InspectorOverlayState extends State<InspectorOverlay> {
  late Offset _position;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _position = widget.initialPosition ?? const Offset(20, 100);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Debug console overlay
        if (widget.controller.isVisible)
          Positioned.fill(
            child: InspectorDashboard(
              controller: widget.controller,
              onClose: () => widget.controller.hide(),
            ),
          ),

        // Floating debug button
        Positioned(
          left: _position.dx,
          top: _position.dy,
          child: GestureDetector(
            onPanStart: (details) {
              _isDragging = false;
            },
            onPanUpdate: (details) {
              setState(() {
                _isDragging = true;
                _position = Offset(
                  (_position.dx + details.delta.dx).clamp(
                    0,
                    MediaQuery.of(context).size.width - widget.buttonSize,
                  ),
                  (_position.dy + details.delta.dy).clamp(
                    0,
                    MediaQuery.of(context).size.height - widget.buttonSize,
                  ),
                );
              });
            },
            onTap: () {
              if (!_isDragging) {
                widget.controller.toggle();
              }
            },
            child: AnimatedBuilder(
              animation: widget.controller,
              builder: (context, child) {
                return Container(
                  width: widget.buttonSize,
                  height: widget.buttonSize,
                  decoration: BoxDecoration(
                    color: _getButtonColor(),
                    borderRadius: BorderRadius.circular(widget.buttonSize / 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Icon(
                          widget.controller.isVisible
                              ? Icons.close
                              : Icons.bug_report,
                          color: Colors.white,
                          size: widget.buttonSize * 0.6,
                        ),
                      ),
                      if (widget.controller.errorCount > 0)
                        Positioned(
                          right: 4,
                          top: 4,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              '${widget.controller.errorCount > 99 ? '99+' : widget.controller.errorCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  /// Gets the button color based on the current state.
  Color _getButtonColor() {
    if (widget.controller.errorCount > 0) {
      return Colors.red.shade600;
    } else if (widget.controller.warningCount > 0) {
      return Colors.orange.shade600;
    } else {
      return Colors.blue.shade600;
    }
  }
}
