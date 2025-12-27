import 'package:flutter/foundation.dart';

import '../../data/enums/node_type.dart';
import '../../data/models/hierarchy_node.dart';
import '../../data/models/picture.dart';
import '../../data/services/backend_service.dart';

class DashboardBloc extends ChangeNotifier {
  final BackendService _backendService;
  HierarchyNode? _rootNode;
  HierarchyNode? _selectedNode;
  Picture? _selectedPicture;

  DashboardBloc(this._backendService) {
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final newData = await _backendService.getLibraryData();
    _rootNode = newData;

    // Try to preserve the current selection after reload
    if (_selectedNode != null && _rootNode != null) {
      final found = findNode(_rootNode!, _selectedNode!.id);
      _selectedNode = found ?? _rootNode;
    } else {
      _selectedNode = _rootNode;
    }

    notifyListeners();
  }

  // Getters
  HierarchyNode? get rootNode => _rootNode;
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

  Future<void> addNode(String name, NodeType type, int parentId) async {
    final newNode = HierarchyNode(
      id: 0,
      parentId: parentId,
      name: name,
      type: type,
      children: [],
      pictures: [],
    );

    try {
      await _backendService.createNode(newNode);
      await _loadInitialData();
    } catch (e) {
      if (kDebugMode) {
        print("Error creating node: $e");
      }

      rethrow;
    }
  }

  HierarchyNode? findNode(HierarchyNode root, int id) {
    if (root.id == id) return root;
    for (final child in root.children) {
      final found = findNode(child, id);
      if (found != null) return found;
    }
    return null;
  }
}
