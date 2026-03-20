import 'dart:convert';

import 'package:flutter_quill/flutter_quill.dart';

/// Utility functions for working with Delta JSON content.
class DeltaUtils {
  DeltaUtils._();

  /// Extracts plain text from a Delta JSON string.
  ///
  /// If the input is null or empty, returns an empty string.
  /// If parsing fails, returns the original string (assuming it's already plain text).
  static String extractPlainText(String? deltaJson) {
    if (deltaJson == null || deltaJson.isEmpty) return '';
    try {
      final decoded = jsonDecode(deltaJson);
      if (decoded is List) {
        final doc = Document.fromJson(decoded);
        return doc.toPlainText().trim();
      }
      // If decoded but not a List, treat as plain text
      return decoded.toString().trim();
    } catch (_) {
      // If parsing fails, assume it's already plain text
      return deltaJson;
    }
  }
}
