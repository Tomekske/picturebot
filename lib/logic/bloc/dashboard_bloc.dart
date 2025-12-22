import 'package:flutter/foundation.dart';
import '../../data/models/hierarchy_node.dart';
import '../../data/models/photo.dart';
import '../../data/repositories/mock_repository.dart';

class DashboardBloc extends ChangeNotifier {
  late HierarchyNode _rootNode;
  HierarchyNode? _selectedNode;
  Photo? _selectedPhoto;

  DashboardBloc() {
    _rootNode = MockRepository.getInitialData();
    _selectedNode = _rootNode;
  }

  // Getters
  HierarchyNode get rootNode => _rootNode;
  HierarchyNode? get selectedNode => _selectedNode;
  Photo? get selectedPhoto => _selectedPhoto;

  // Events/Methods
  void selectNode(HierarchyNode node) {
    _selectedNode = node;
    _selectedPhoto = null;
    notifyListeners();
  }

  void selectPhoto(Photo? photo) {
    _selectedPhoto = photo;
    notifyListeners();
  }

  void addNode(String name, String type, int parentId) {
    // Note: In a real app, you would need to rebuild the tree structure here
    // since HierarchyNode is immutable-ish.
    // For this prototype, we'll just print to console as per original code.
    if (kDebugMode) {
      print(
        "Adding $name ($type) to $parentId (Logic needs immutable update implementation)",
      );
    }
    notifyListeners();
  }

  HierarchyNode? findNode(HierarchyNode root, String id) {
    if (root.id == id) return root;
    for (final child in root.children) {
      final found = findNode(child, id);
      if (found != null) return found;
    }
    return null;
  }
}
