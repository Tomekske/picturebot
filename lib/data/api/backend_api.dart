import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// A client service for communicating with the local backend server.
///
/// This class handles HTTP requests to `http://localhost:8080` to fetch
/// library hierarchy data, retrieve user settings, and persist configuration changes.
class BackendApi {
  /// Fetches the library hierarchy tree from the backend.
  ///
  /// Performs a GET request to the `/hierarchy` endpoint.
  ///
  /// Returns a [List] of [Map] objects representing the folder and album structure.
  /// If the request fails or an exception occurs, it logs the error in debug mode
  /// and returns an empty list.
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

  /// Fetches the current user configuration from the server.
  ///
  /// Performs a GET request to the `/settings` endpoint.
  ///
  /// Returns a [Map] containing the JSON configuration data.
  /// Throws an [Exception] if the network request fails or the status code is not 200.
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

  /// Persists updated settings to the backend server.
  ///
  /// Performs an HTTP POST request to `/settings` with the [newSettings]
  /// encoded as a JSON body.
  ///
  /// Throws an [Exception] if the server does not return a 200 OK or 201 Created status.
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
