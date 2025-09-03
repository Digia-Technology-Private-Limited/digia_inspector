import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Extension methods for [String] providing debugging and formatting utilities.
extension StringExtensions on String {
  /// Copies the string to the system clipboard and shows a toast notification.
  ///
  /// This method provides user feedback through a [SnackBar] and includes
  /// haptic feedback for better user experience. It handles errors gracefully
  /// and provides appropriate feedback if the clipboard operation fails.
  ///
  /// Parameters:
  /// - [context]: The [BuildContext] used to show the snackbar notification
  /// - [successMessage]: Custom success message (defaults to "Copied to clipboard!")
  /// - [label]: Optional label to describe what was copied (e.g., "cURL command")
  ///
  /// Example usage:
  /// ```dart
  /// final curlCommand = "curl -X GET https://api.example.com/users";
  /// await curlCommand.copyToClipboard(
  ///   context,
  ///   label: "cURL command",
  /// );
  /// ```
  Future<void> copyToClipboard(
    BuildContext context, {
    String? successMessage,
    String? label,
  }) async {
    try {
      await Clipboard.setData(ClipboardData(text: this));

      // Provide haptic feedback
      await HapticFeedback.lightImpact();

      // Show success notification
      if (context.mounted) {
        final message =
            successMessage ??
            (label != null
                ? '$label copied to clipboard!'
                : 'Copied to clipboard!');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Dismiss',
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
      }
    } catch (e) {
      // Handle clipboard errors gracefully
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to copy to clipboard: ${e.toString()}'),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  /// Formats a string as a human-readable byte size based on its UTF-8 byte count.
  ///
  /// Computes the actual UTF-8 byte size of the string content and converts
  /// to appropriate units (B, KB, MB) with proper decimal formatting for
  /// better readability in debugging interfaces.
  ///
  /// Example outputs:
  /// - "Hello" → "5B"
  /// - Long string → "1.2KB"
  /// - Very long string → "2.5MB"
  String get asReadableSize {
    final bytes = utf8.encode(this).length;
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  /// Pretty-prints a JSON string with proper indentation and formatting.
  ///
  /// Attempts to parse the string as JSON and format it with 2-space
  /// indentation for better readability. Returns the original string
  /// if it cannot be parsed as valid JSON.
  ///
  /// This is useful for displaying JSON responses and request bodies
  /// in debugging interfaces with proper formatting.
  ///
  /// Example:
  /// ```dart
  /// final jsonString = '{"name":"John","age":30}';
  /// final formatted = jsonString.prettyJson;
  /// // Returns:
  /// // {
  /// //   "name": "John",
  /// //   "age": 30
  /// // }
  /// ```
  String get prettyJson {
    try {
      final parsed = jsonDecode(this);
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(parsed);
    } catch (e) {
      // Return original string if not valid JSON
      return this;
    }
  }

  /// Truncates the string to a maximum length with ellipsis.
  ///
  /// Useful for displaying long strings in constrained UI spaces
  /// while indicating that content has been truncated.
  ///
  /// Parameters:
  /// - [maxLength]: Maximum length before truncation
  /// - [ellipsis]: String to append when truncated (defaults to '...')
  ///
  /// Example:
  /// ```dart
  /// final longText = "This is a very long string that needs truncation";
  /// final truncated = longText.truncate(20); // "This is a very lo..."
  /// ```
  String truncate(int maxLength, {String ellipsis = '...'}) {
    if (length <= maxLength) return this;

    final truncateLength = maxLength - ellipsis.length;
    if (truncateLength < 0) return ellipsis;

    return substring(0, truncateLength) + ellipsis;
  }

  /// Capitalizes the first letter of the string.
  ///
  /// Useful for displaying enum values and other identifiers in
  /// user-friendly formats in debugging interfaces.
  ///
  /// Example:
  /// ```dart
  /// 'httpRequest'.capitalize(); // 'HttpRequest'
  /// 'error'.capitalize();       // 'Error'
  /// ```
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }

  /// Converts camelCase and PascalCase strings to space-separated words.
  ///
  /// Useful for displaying programmatic names in user-friendly formats
  /// in debugging interfaces.
  ///
  /// Example:
  /// ```dart
  /// 'httpRequest'.toDisplayName();    // 'Http Request'
  /// 'XMLHttpRequest'.toDisplayName(); // 'XML Http Request'
  /// ```
  String toDisplayName() {
    if (isEmpty) return this;

    // Insert spaces before uppercase letters (except the first character)
    final result = replaceAllMapped(
      RegExp('([a-z])([A-Z])'),
      (match) => '${match.group(1)} ${match.group(2)}',
    );

    return result.capitalize();
  }

  /// Checks if the string is a valid URL.
  ///
  /// Attempts to parse the string as a URI and validates common URL schemes.
  /// Useful for validating network request URLs in debugging interfaces.
  ///
  /// Returns `true` if the string can be parsed as a valid HTTP/HTTPS URL.
  bool get isValidUrl {
    try {
      final uri = Uri.parse(this);
      return uri.hasScheme &&
          (uri.scheme == 'http' || uri.scheme == 'https') &&
          uri.hasAuthority;
    } catch (e) {
      return false;
    }
  }

  /// Extracts the domain from a URL string.
  ///
  /// Returns the host portion of a URL, or null if the string
  /// is not a valid URL. Useful for grouping network requests
  /// by domain in debugging interfaces.
  ///
  /// Example:
  /// ```dart
  /// 'https://api.example.com/users'.extractDomain(); // 'api.example.com'
  /// 'invalid-url'.extractDomain();                   // null
  /// ```
  String? extractDomain() {
    try {
      return Uri.parse(this).host;
    } catch (e) {
      return null;
    }
  }

  /// Highlights search terms within the string using HTML-like markup.
  ///
  /// Wraps matching search terms with `<mark>` tags for highlighting
  /// in debugging interfaces. Case-insensitive matching.
  ///
  /// Parameters:
  /// - [searchTerm]: The term to highlight
  /// - [caseSensitive]: Whether matching should be case-sensitive (default: false)
  ///
  /// Example:
  /// ```dart
  /// final text = "This is a sample text";
  /// final highlighted = text.highlightSearchTerm("sample");
  /// // Returns: "This is a <mark>sample</mark> text"
  /// ```
  String highlightSearchTerm(String searchTerm, {bool caseSensitive = false}) {
    if (searchTerm.isEmpty) return this;

    final flags = caseSensitive ? '' : 'i';
    final pattern = RegExp(
      RegExp.escape(searchTerm),
      caseSensitive: caseSensitive,
    );

    return replaceAllMapped(pattern, (match) {
      return '<mark>${match.group(0)}</mark>';
    });
  }

  /// Removes HTML tags from the string.
  ///
  /// Useful for cleaning up HTML content for display in plain text
  /// contexts or for search indexing.
  ///
  /// Example:
  /// ```dart
  /// final html = "This is <mark>highlighted</mark> text";
  /// final clean = html.stripHtmlTags(); // "This is highlighted text"
  /// ```
  String stripHtmlTags() {
    return replaceAll(RegExp('<[^>]*>'), '');
  }

  /// Checks if the string contains any of the given search terms.
  ///
  /// Performs case-insensitive matching against multiple search terms.
  /// Useful for filtering log entries in debugging interfaces.
  ///
  /// Parameters:
  /// - [searchTerms]: List of terms to search for
  /// - [caseSensitive]: Whether matching should be case-sensitive (default: false)
  ///
  /// Returns `true` if any of the search terms are found in the string.
  bool containsAny(List<String> searchTerms, {bool caseSensitive = false}) {
    if (searchTerms.isEmpty) return true;

    final text = caseSensitive ? this : toLowerCase();

    for (final term in searchTerms) {
      final searchTerm = caseSensitive ? term : term.toLowerCase();
      if (text.contains(searchTerm)) {
        return true;
      }
    }

    return false;
  }
}
