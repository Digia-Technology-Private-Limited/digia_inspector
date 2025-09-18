import 'dart:async';
import 'dart:convert';
import 'dart:ui' show Brightness;
import 'dart:ui_web' as ui_web;
import 'dart:js_interop';
import 'package:digia_inspector/src/theme/theme_system.dart';
import 'package:digia_inspector/src/utils/extensions.dart';
import 'package:digia_inspector/src/widgets/common/json_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

class MonacoJsonViewer extends StatefulWidget {
  const MonacoJsonViewer({
    super.key,
    required this.content,
    this.height,
    this.width,
    this.showCopyButton = true,
  });

  final String content;
  final double? height;
  final double? width;
  final bool showCopyButton;

  @override
  State<MonacoJsonViewer> createState() => _MonacoJsonViewerState();
}

class _MonacoJsonViewerState extends State<MonacoJsonViewer> {
  late final String _instanceId;
  web.HTMLIFrameElement? _iframe;
  StreamSubscription<web.MessageEvent>? _sub;

  @override
  void initState() {
    super.initState();
    _instanceId =
        'monaco-json-${DateTime.now().microsecondsSinceEpoch}-$hashCode';
    if (kIsWeb) {
      _setupIframe();
      _listenMessages();
    }
  }

  void _setupIframe() {
    final iframe = web.HTMLIFrameElement()
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%'
      ..setAttribute('data-instance-id', _instanceId)
      ..src = 'json_viewer.html';

    iframe.onLoad.listen((_) {
      _postToIframe({
        'action': 'set_value',
        'value': widget.content,
        'instanceId': _instanceId,
      });
      _postToIframe({
        'action': 'set_theme',
        'instanceId': _instanceId,
      });
    });

    ui_web.platformViewRegistry.registerViewFactory(
      _instanceId,
      (int viewId) => iframe,
    );

    _iframe = iframe;
  }

  void _listenMessages() {
    _sub = web.window.onMessage.listen((event) {
      if (!mounted) return;
      final sourceElement = event.source as web.Window?;
      if (sourceElement?.frameElement?.getAttribute('data-instance-id') !=
          _instanceId) {
        return;
      }
      try {
        final data = jsonDecode(event.data.toString());
        if (data is Map && data['type'] == 'init') {
          _postToIframe({
            'action': 'set_value',
            'value': widget.content,
            'instanceId': _instanceId,
          });
          _postToIframe({
            'action': 'set_theme',
            'theme': _isDark(context) ? 'vs-dark' : 'vs',
            'instanceId': _instanceId,
          });
        }
      } catch (_) {
        // ignore non-JSON messages
      }
    });
  }

  void _postToIframe(Map<String, dynamic> message) {
    _iframe?.contentWindow?.postMessage(message.jsify(), '*'.toJS);
  }

  bool _isDark(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark;
  }

  @override
  void didUpdateWidget(covariant MonacoJsonViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!kIsWeb) return;
    if (oldWidget.content != widget.content) {
      _postToIframe({
        'action': 'set_value',
        'value': widget.content,
        'instanceId': _instanceId,
      });
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    _iframe?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final box = BoxDecoration(
      border: Border.all(color: AppColors.separator),
      borderRadius: AppBorderRadius.radiusMD,
    );

    if (!kIsWeb) {
      // Fallback to existing JsonView on non-web
      dynamic parsed = widget.content;
      try {
        parsed = jsonDecode(widget.content);
      } catch (_) {}
      return Container(
        decoration: box,
        child: Padding(
          padding: AppSpacing.paddingSM,
          child: JsonView(value: parsed, showCopyButton: widget.showCopyButton),
        ),
      );
    }

    final effectiveHeight = widget.height ?? 440;

    return Container(
      height: effectiveHeight,
      width: widget.width ?? double.infinity,
      decoration: box,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: AppSpacing.paddingSM,
            decoration: const BoxDecoration(
              color: AppColors.backgroundPrimary,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppBorderRadius.md),
                topRight: Radius.circular(AppBorderRadius.md),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.data_object,
                  size: AppIconSizes.sm,
                  color: AppColors.contentSecondary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'JSON',
                  style: InspectorTypography.footnoteBold.copyWith(
                    color: AppColors.contentPrimary,
                  ),
                ),
                const Spacer(),
                if (widget.showCopyButton)
                  IconButton(
                    onPressed: () async {
                      await ClipboardUtils.copyToClipboardWithToast(
                        context,
                        widget.content,
                        customMessage: 'JSON copied',
                      );
                    },
                    icon: const Icon(
                      Icons.copy,
                      size: AppIconSizes.sm,
                      color: AppColors.contentSecondary,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'Copy JSON',
                  ),
              ],
            ),
          ),
          Expanded(
            child: HtmlElementView(viewType: _instanceId),
          ),
        ],
      ),
    );
  }
}
