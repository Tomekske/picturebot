import 'package:flutter/foundation.dart';

import '../api/backend_api.dart';
import '../enums/node_type.dart';
import '../models/hierarchy_node.dart';
import '../models/settings.dart';

/// A repository that mediates between the domain layer and the [BackendApi].
///
/// This class is responsible for transforming raw JSON data received from the
/// backend into strong-typed domain models ([HierarchyNode], [Settings]).
/// It also handles basic error recovery, such as returning default objects on failure.
class BackendRepository {
  /// Retrieves and structures the library hierarchy.
  ///
  /// Calls [BackendApi.getLibraryData] to get the raw data.
  /// * If the response is a [List], it wraps the items in a synthetic root
  ///     [HierarchyNode] named "Library".
  ///
  /// Returns a root [HierarchyNode]. If an error occurs during fetching or parsing,
  /// it returns a placeholder "Error" node to prevent UI crashes.
  Future<HierarchyNode?> getInitialData() async {
    try {
      final response = await BackendApi.getLibraryData();

      if (response == null) {
        return null;
      }

      final List<HierarchyNode> children = response
          .map((json) => HierarchyNode.fromJson(json))
          .toList();

      return HierarchyNode(
        id: 0,
        name: "Library",
        type: NodeType.folder,
        children: children,
        subFolders: const [],
      );
    } catch (e) {
      if (kDebugMode) {
        print("Error loading library data: $e");
      }

      return null;
    }
  }

  /// Persists a new hierarchy node to the backend.
  ///
  /// Converts the [HierarchyNode] domain model into a JSON-compatible [Map]
  /// and delegates the API call to [BackendApi.createNode].
  ///
  /// Rethrows any exceptions (e.g., network errors) to be handled by the caller.
  Future<void> createNode(HierarchyNode node) async {
    try {
      await BackendApi.createNode(node.toJson());
    } catch (e) {
      if (kDebugMode) {
        print("Error updating settings: $e");
      }
      rethrow;
    }
  }

  /// Persists a new album node and initiates the picture import process.
  ///
  /// Takes a [HierarchyNode] representing the album and a [sourcePath] string
  /// pointing to the directory on the disk where the original pictures are located.
  ///
  /// It merges the node's JSON representation with the `source_path` field
  /// before sending it to the backend via [BackendApi.createNode].
  Future<void> createAlbum(HierarchyNode node, String sourcePath) async {
    try {
      // Create JSON from node and inject the source_path
      final Map<String, dynamic> payload = node.toJson();
      payload['source_path'] = sourcePath;

      await BackendApi.createNode(payload);
    } catch (e) {
      if (kDebugMode) {
        print("Error creating album with import: $e");
      }
      rethrow;
    }
  }

  /// Fetches and deserializes application settings.
  ///
  /// Retrieves raw JSON from [BackendApi.getSettings] and converts it into
  /// A [Settings] model.
  ///
  /// Returns [Settings.initial] (default values) if the API call fails or
  /// the data is malformed, ensuring the app continues to function.
  Future<Settings> getSettings() async {
    try {
      final response = await BackendApi.getSettings();
      return Settings.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print("Error processing settings data: $e");
      }
      return Settings.initial();
    }
  }

  /// Persists modified settings to the backend.
  ///
  /// Serializes the provided [settings] model to JSON and delegates the
  /// transmission to [BackendApi.updateSettings].
  ///
  /// Rethrows any exceptions (such as network failures) to be handled by the caller.
  Future<void> updateSettings(Settings settings) async {
    try {
      await BackendApi.updateSettings(settings.toJson());
    } catch (e) {
      if (kDebugMode) {
        print("Error updating settings: $e");
      }
      rethrow;
    }
  }
}
