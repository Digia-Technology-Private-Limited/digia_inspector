import 'package:flutter/material.dart';

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
    dynamic parsed = content;
    try {
    } catch (_) {}
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text("dadad"),
      ),
    );
  }
}