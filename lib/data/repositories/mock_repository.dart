import 'package:flutter/foundation.dart';

import '../api/mock_backend_api.dart';
import '../enums/node_type.dart';
import '../models/hierarchy_node.dart';
import '../models/settings.dart';

/// A repository implementation that acts as a bridge to the [MockBackendApi].
///
/// This class abstracts the source of the data, allowing the service layer to
/// remain unaware of whether data comes from a mock class, a local DB, or a real REST API.
class MockRepository {
  /// Fetches the initial folder and album structure for the library.
  ///
  /// Delegates the call to [MockBackendApi.getLibraryData].
  /// Returns a [Future] that resolves to the root [HierarchyNode].
  Future<HierarchyNode> getInitialData() async {
    try {
      final dynamic response = await MockBackendApi.getLibraryData();

      List<HierarchyNode> children = [];

      if (response is List) {
        children = response
            .map((json) => HierarchyNode.fromJson(json as Map<String, dynamic>))
            .toList();
      } else if (response is Map) {
        return HierarchyNode.fromJson(response as Map<String, dynamic>);
      }

      return HierarchyNode(
        id: -1,
        name: "Library",
        type: NodeType.folder,
        children: children,
        pictures: const [],
      );
    } catch (e) {
      if (kDebugMode) {
        print("Error loading library data: $e");
      }

      return HierarchyNode(
        id: -1,
        name: "Error",
        type: NodeType.folder,
      );
    }
  }

  /// Fetches the application settings from the backend source.
  ///
  /// Delegates the raw data retrieval to [MockBackendApi.getSettings] and
  /// transforms the JSON response into a strong-typed [Settings] model.
  ///
  /// Returns default [Settings.initial] if the fetch fails to prevent app crashes.
  Future<Settings> getSettings() async {
    try {
      final response = await MockBackendApi.getSettings();
      return Settings.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print("Error processing settings data: $e");
      }
      return Settings.initial();
    }
  }

  /// Persists the provided [settings] to the backend.
  ///
  /// Converts the domain [Settings] model into JSON and delegates the
  /// transmission to [MockBackendApi.updateSettings].
  Future<void> updateSettings(Settings settings) async {
    try {
      await MockBackendApi.updateSettings(settings.toJson());
    } catch (e) {
      if (kDebugMode) {
        print("Error updating settings: $e");
      }
      rethrow;
    }
  }
}
