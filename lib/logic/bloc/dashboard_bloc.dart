import 'package:flutter/foundation.dart';
import '../../data/models/hierarchy_node.dart';
import '../../data/models/picture.dart';
import '../../data/repositories/mock_repository.dart';

class DashboardBloc extends ChangeNotifier {
  HierarchyNode _rootNode;
  HierarchyNode? _selectedNode;
  Picture? _selectedPicture;

  DashboardBloc() : _rootNode = MockRepository.getInitialData() {
    _rootNode = MockRepository.getInitialData();
    _selectedNode = _rootNode;
  }

  // Getters
  HierarchyNode get rootNode => _rootNode;
  HierarchyNode? get selectedNode => _selectedNode;
  Picture? get selectedPicture => _selectedPicture;

  // Events/Methods
  void selectNode(HierarchyNode node) {
    _selectedNode = node;
    _selectedPicture = null;
    notifyListeners();
  }

  void selectPicture(Picture? picture) {
    _selectedPicture = picture;
    notifyListeners();
  }

  void addNode(String name, String type, int parentId) {
    // Note: In a real app, you would need to rebuild the tree structure here
    // since HierarchyNode is immutable-ish.
    // For this prototype, we'll just print to console as per original code.
    if (kDebugMode) {
      print(
        "Adding $name ($type) to $parentId",
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
