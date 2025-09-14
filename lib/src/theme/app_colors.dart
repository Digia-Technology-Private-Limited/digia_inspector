import 'package:flutter/material.dart';

/// Color constants for DigiaInspector
abstract class AppColors {
  // Background Colors
  /// Main background
  static const backgroundPrimary = Color(0xFFF9F9F9);

  /// Card backgrounds
  static const backgroundSecondary = Color(0xFFFFFFFF);

  /// Background tertiary
  static const backgroundTertiary = Color(0xFFF5F5F5);

  /// Modal overlay (with opacity)
  static const backgroundOverlay = Color(0xFF000000);

  // Surface Colors
  /// Elevated cards/modals
  static const surfaceElevated = Color(0xFFFFFFFF);

  /// Pressed states
  static const surfacePressed = Color(0xFFF0F0F0);

  /// Default borders
  static const surfaceBorder = Color(0xFFE5E5E5);

  /// Border default
  static const borderDefault = Color(0x3D000000);

  // Content Colors
  /// Primary text
  static const contentPrimary = Color(0xFF1C1C1E);

  /// Secondary text
  static const contentSecondary = Color(0xFF4A4A4A);

  /// Tertiary text/icons
  static const contentTertiary = Color(0xFFC7C7CC);

  /// Placeholder text
  static const contentPlaceholder = Color(0xFF999999);

  // Status Colors
  /// 2xx status codes
  static const statusSuccess = Color(0xFF34C759);

  /// 3xx status codes
  static const statusWarning = Color(0xFFFF9500);

  /// 4xx/5xx status codes
  static const statusError = Color(0xFFFF3B30);

  /// Info/pending states
  static const statusInfo = Color(0xFF007AFF);

  // Method Colors
  /// GET requests
  static const methodGet = Color(0xFF34C759);

  /// POST requests
  static const methodPost = Color(0xFF007AFF);

  /// PUT requests
  static const methodPut = Color(0xFFFF9500);

  /// DELETE requests
  static const methodDelete = Color(0xFFFF3B30);

  /// PATCH requests
  static const methodPatch = Color(0xFF5856D6);

  /// HEAD requests
  static const methodHead = Color(0xFF8E8E93);

  /// OPTIONS requests
  static const methodOptions = Color(0xFF8E8E93);

  // Interactive Colors
  /// Primary accent/selection
  static const accent = Color(0xFF007AFF);

  /// Pressed accent state
  static const accentPressed = Color(0xFF0056CC);

  // Utility Colors
  /// List separators
  static const separator = Color(0xFFE5E5E5);

  /// Drop shadows
  static const shadow = Color(0x1A000000);

  // Special Colors
  /// Search field background
  static const searchBackground = Color(0xFFF2F2F7);

  /// Chevron arrows
  static const chevronColor = Color(0xFFC7C7CC);
}
