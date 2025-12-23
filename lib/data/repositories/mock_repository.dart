import 'package:flutter/foundation.dart';

import '../api/mock_backend_api.dart';
import '../models/hierarchy_node.dart';

/// A repository implementation that acts as a bridge to the [MockBackendApi].
///
/// This class abstracts the source of the data, allowing the service layer to
/// remain unaware of whether data comes from a mock class, a local DB, or a real REST API.
class MockRepository {
  /// Fetches the initial folder and album structure for the library.
  ///
  /// Delegates the call to [MockBackendApi.getLibraryData].
  /// Returns a [Future] that resolves to the root [HierarchyNode].
  static Future<HierarchyNode> getInitialData() async {
    final payload = await MockBackendApi.getLibraryData();

    try {
      return HierarchyNode.fromJson(payload);
    } catch (e) {
      if (kDebugMode) {
        print("Error converting data: $e");
      }

      rethrow;
    }
  }
}
