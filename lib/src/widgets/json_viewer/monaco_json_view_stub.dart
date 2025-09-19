import 'package:flutter/material.dart';

/// Stub fallback when neither web nor mobile implementation is available.
/// Useful for tests or unsupported platforms.
class MonacoJsonViewer extends StatelessWidget {
  final String content;
  final double? height;
  final double? width;
  final bool showCopyButton;

  const MonacoJsonViewer({
    super.key,
    required this.content,
    this.height,
    this.width,
    this.showCopyButton = true,
  });

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
