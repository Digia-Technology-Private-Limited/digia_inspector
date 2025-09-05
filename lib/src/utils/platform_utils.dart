import 'package:flutter/foundation.dart';

/// Platform detection utilities for inspector UI
class PlatformUtils {
  /// Whether the current platform is web
  static bool get isWeb => kIsWeb;

  /// Whether the current platform is mobile (iOS/Android)
  static bool get isMobile => !kIsWeb;

  /// Whether the current platform is desktop (Windows/macOS/Linux)
  static bool get isDesktop =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.linux);

  /// Whether the current platform is iOS
  static bool get isIOS =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  /// Whether the current platform is Android
  static bool get isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
}
