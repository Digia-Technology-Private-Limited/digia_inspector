import 'package:flutter/material.dart';

/// Color constants for DigiaInspector - following the mobile-first design system
abstract class InspectorColors {
  // Background Colors
  static const backgroundPrimary = Color(0xFFF9F9F9); // Main background
  static const backgroundSecondary = Color(0xFFFFFFFF); // Card backgrounds
  static const backgroundOverlay = Color(
    0xFF000000,
  ); // Modal overlay (with opacity)

  // Surface Colors
  static const surfaceElevated = Color(0xFFFFFFFF); // Elevated cards/modals
  static const surfacePressed = Color(0xFFF0F0F0); // Pressed states
  static const surfaceBorder = Color(0xFFE5E5E5); // Default borders

  // Content Colors
  static const contentPrimary = Color(0xFF1C1C1E); // Primary text
  static const contentSecondary = Color(0xFF8E8E93); // Secondary text
  static const contentTertiary = Color(0xFFC7C7CC); // Tertiary text/icons
  static const contentPlaceholder = Color(0xFF999999); // Placeholder text

  // Status Colors
  static const statusSuccess = Color(0xFF34C759); // 2xx status codes
  static const statusWarning = Color(0xFFFF9500); // 3xx status codes
  static const statusError = Color(0xFFFF3B30); // 4xx/5xx status codes
  static const statusInfo = Color(0xFF007AFF); // Info/pending states

  // Method Colors
  static const methodGet = Color(0xFF34C759); // GET requests
  static const methodPost = Color(0xFF007AFF); // POST requests
  static const methodPut = Color(0xFFFF9500); // PUT requests
  static const methodDelete = Color(0xFFFF3B30); // DELETE requests
  static const methodPatch = Color(0xFF5856D6); // PATCH requests
  static const methodHead = Color(0xFF8E8E93); // HEAD requests
  static const methodOptions = Color(0xFF8E8E93); // OPTIONS requests

  // Interactive Colors
  static const accent = Color(0xFF007AFF); // Primary accent/selection
  static const accentPressed = Color(0xFF0056CC); // Pressed accent state

  // Utility Colors
  static const separator = Color(0xFFE5E5E5); // List separators
  static const shadow = Color(0x1A000000); // Drop shadows

  // Special Colors
  static const searchBackground = Color(0xFFF2F2F7); // Search field background
  static const chevronColor = Color(0xFFC7C7CC); // Chevron arrows
}
