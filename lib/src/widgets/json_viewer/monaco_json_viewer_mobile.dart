import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_monaco/flutter_monaco.dart';

class MonacoJsonViewer extends StatefulWidget {
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
  State<MonacoJsonViewer> createState() => _MonacoJsonViewerState();
}

class _MonacoJsonViewerState extends State<MonacoJsonViewer> {
  MonacoController? _controller;

  @override
  void initState() {
    super.initState();
    _initEditor();
  }

  Future<void> _initEditor() async {
    String pretty = widget.content;
    try {
      final decoded = jsonDecode(widget.content);
      pretty = const JsonEncoder.withIndent('  ').convert(decoded);
    } catch (_) {
    }

    final controller = await MonacoController.create(
      options: const EditorOptions(
        language: MonacoLanguage.json,
        theme: MonacoTheme.vs,
        readOnly: true,
        minimap: false,
        fontSize: 12,
        lineNumbers: false,
        automaticLayout: true,
        scrollBeyondLastLine: false,  
        wordWrap: false,  
        smoothScrolling: true,  
        insertSpaces: false,
        lineHeight: 1.3,   
        padding: {'top': 8, 'bottom': 8},  
        contextMenu: false     
      ),
    );

    await controller.setValue(pretty);

    setState(() {
      _controller = controller;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      height: widget.height ?? 450,
      width: widget.width ?? double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: _controller!.webViewWidget,
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
