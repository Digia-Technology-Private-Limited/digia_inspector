import 'package:flutter/material.dart';

/// Stub fallback when neither web nor mobile implementation is available.
/// Useful for tests or unsupported platforms.
class MonacoJsonViewer extends StatelessWidget {
  /// Constructor
  const MonacoJsonViewer({
    required this.content,
    super.key,
    this.height,
    this.width,
    this.showCopyButton = true,
  });

  /// The JSON content to display
  final String content;

  /// The height of the widget
  final double? height;

  /// The width of the widget
  final double? width;

  /// Whether to show a copy button
  final bool showCopyButton;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SingleChildScrollView(
        child: Text(
          content,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
        ),
      ),
    );
  }
}
