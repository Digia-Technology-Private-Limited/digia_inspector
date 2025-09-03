import 'dart:convert';

/// Extension methods for [Object] providing JSON formatting utilities.
extension ObjectExtensions on Object? {
  /// Converts the object to a pretty-printed JSON string.
  ///
  /// Attempts to serialize the object to JSON with 2-space indentation
  /// for better readability in debugging interfaces. Handles various
  /// object types and provides fallback formatting for non-serializable objects.
  ///
  /// Returns a formatted JSON string, or a string representation of the
  /// object if JSON serialization fails.
  ///
  /// Example output:
  /// ```json
  /// {
  ///   "name": "John Doe",
  ///   "age": 30,
  ///   "preferences": {
  ///     "theme": "dark",
  ///     "notifications": true
  ///   }
  /// }
  /// ```
  String get prettyJson {
    if (this == null) return 'null';

    try {
      // Try to encode with pretty printing
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(this);
    } catch (e) {
      // Fallback to string representation if not JSON serializable
      return toString();
    }
  }

  /// Converts the object to a compact JSON string.
  ///
  /// Attempts to serialize the object to JSON without formatting
  /// or indentation. Useful for logging, storage, or transmission
  /// where space efficiency is important.
  ///
  /// Returns a compact JSON string, or a string representation of the
  /// object if JSON serialization fails.
  ///
  /// Example output:
  /// ```json
  /// {"name":"John Doe","age":30,"preferences":{"theme":"dark"}}
  /// ```
  String toJsonString() {
    if (this == null) return 'null';

    try {
      return jsonEncode(this);
    } catch (e) {
      // Fallback to string representation if not JSON serializable
      return toString();
    }
  }

  /// Checks if the object can be serialized to JSON.
  ///
  /// Attempts to perform JSON serialization to determine if the object
  /// contains only JSON-compatible types. Useful for validation before
  /// attempting to display objects in JSON format.
  ///
  /// Returns `true` if the object can be successfully serialized to JSON,
  /// `false` otherwise.
  bool get isJsonSerializable {
    if (this == null) return true;

    try {
      jsonEncode(this);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Gets the type name of the object as a string.
  ///
  /// Returns a human-readable type name for the object, useful for
  /// debugging interfaces to show what type of data is being displayed.
  ///
  /// For null values, returns 'null'. For other objects, returns the
  /// runtime type name.
  ///
  /// Example outputs:
  /// - `Map<String, dynamic>` for maps
  /// - `List<String>` for lists
  /// - `String` for strings
  /// - `null` for null values
  String get typeName {
    if (this == null) return 'null';
    return runtimeType.toString();
  }

  /// Gets a truncated string representation of the object.
  ///
  /// Creates a string representation of the object and truncates it
  /// to the specified maximum length if necessary. Useful for displaying
  /// object previews in constrained UI spaces.
  ///
  /// Parameters:
  /// - [maxLength]: Maximum length before truncation (default: 100)
  /// - [ellipsis]: String to append when truncated (default: '...')
  ///
  /// Example:
  /// ```dart
  /// final longObject = {'data': 'A very long string...'};
  /// final preview = longObject.toPreviewString(50);
  /// // Returns: "{data: A very long string that gets trun..."
  /// ```
  String toPreviewString({int maxLength = 100, String ellipsis = '...'}) {
    final str = toString();

    if (str.length <= maxLength) {
      return str;
    }

    final truncateLength = maxLength - ellipsis.length;
    if (truncateLength < 0) return ellipsis;

    return str.substring(0, truncateLength) + ellipsis;
  }

  /// Safely converts the object to a string.
  ///
  /// Provides a safe way to convert any object to a string representation,
  /// handling null values and potential exceptions from toString() methods.
  ///
  /// Returns 'null' for null values, or the string representation of the
  /// object. If toString() throws an exception, returns a fallback string
  /// with type information.
  String toSafeString() {
    if (this == null) return 'null';

    try {
      return toString();
    } catch (e) {
      return '<${runtimeType.toString()} toString() failed: $e>';
    }
  }
}
