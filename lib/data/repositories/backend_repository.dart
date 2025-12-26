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
  /// * If the response is a [Map], it parses it directly into a [HierarchyNode].
  ///
  /// Returns a root [HierarchyNode]. If an error occurs during fetching or parsing,
  /// it returns a placeholder "Error" node to prevent UI crashes.
  Future<HierarchyNode> getInitialData() async {
    try {
      final dynamic response = await BackendApi.getLibraryData();

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

  /// Fetches and deserializes application settings.
  ///
  /// Retrieves raw JSON from [BackendApi.getSettings] and converts it into
  /// a [Settings] model.
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
