import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// A simulated backend server that generates dummy data and mimics network behavior.
///
/// This class is responsible for creating a realistic development environment
/// by injecting artificial latency and generating random content for testing UI states.
class MockBackendApi {
  /// Simulates an asynchronous network request to fetch the library tree.
  ///
  /// Includes a 1.5-second artificial delay to test loading states (e.g., [ProgressRing]).
  /// Returns a hardcoded tree structure containing Folders and Albums.
  static Future<Map<String, dynamic>> getLibraryData() async {
    // Simulate network latency
    await Future.delayed(const Duration(milliseconds: 1500));

    try {
      final jsonString = await rootBundle.loadString(
        'assets/mock_library_data.json',
      );

      return jsonDecode(jsonString);
    } catch (e) {
      if (kDebugMode) {
        print("Error loading mock data: $e");
      }
      // Return an empty node or rethrow depending on your needs
      rethrow;
    }
  }
}
