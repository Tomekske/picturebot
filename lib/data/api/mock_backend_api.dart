import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

/// A simulated backend server that generates dummy data and mimics network behavior.
///
/// This class is responsible for creating a realistic development environment
/// by injecting artificial latency and generating random content for testing UI states.
class MockBackendApi {
  /// Simulates an asynchronous network request to fetch the library tree.
  ///
  /// Returns a hardcoded tree structure containing Folders and Albums.
  static Future<List<Map<String, dynamic>>> getLibraryData() async {
    try {
      final String baseUrl = 'http://localhost:8080';

      final Uri uri = Uri.parse('$baseUrl/hierarchy');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> decodedList = jsonDecode(response.body);

        return decodedList.cast<Map<String, dynamic>>();
      } else {
        throw Exception(
          'Failed to load hierarchy. Status Code: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error loading the hierarchy: $e");
      }

      return [];
    }
  }

  /// Simulates fetching the user configuration file from the server.
  ///
  /// Returns a [Map] representing the JSON configuration.
  static Future<Map<String, dynamic>> getSettings() async {
    try {
      final Uri uri = Uri.parse('http://localhost:8080/settings');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception(
          'Failed to load settings. Status Code: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error loading mock settings: $e");
      }
      rethrow;
    }
  }

  /// Sends updated settings to the local backend server.
  ///
  /// Performs an HTTP POST request to `http://localhost:8080/settings` with
  /// the [newSettings] encoded as a JSON body.
  ///
  /// Expects a 200 OK or 201 Created status code upon success.
  static Future<void> updateSettings(Map<String, dynamic> newSettings) async {
    try {
      final Uri uri = Uri.parse('http://localhost:8080/settings');
      final response = await http.post(
        uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(newSettings),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (kDebugMode) {
          print("BackendApi: Settings successfully updated -> $newSettings");
        }
      } else {
        throw Exception(
          'Failed to update settings. Status Code: ${response.statusCode}, Body: ${response.body}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error updating settings: $e");
      }
      rethrow;
    }
  }
}
