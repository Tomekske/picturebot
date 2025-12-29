import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/enums/node_type.dart';
import '../../data/models/hierarchy_node.dart';
import '../../data/models/picture.dart';
import '../../data/services/backend_service.dart';
import 'hierarchy_state.dart';

class HierarchyCubit extends Cubit<HierarchyState> {
  final BackendService _backendService;

  HierarchyCubit(this._backendService) : super(const HierarchyState()) {
    loadData();
  }

  Future<void> loadData() async {
    emit(state.copyWith(status: HierarchyStatus.loading));

    try {
      final newData = await _backendService.getLibraryData();

      if (newData == null) {
        emit(
          state.copyWith(
            status: HierarchyStatus.success,
            rootNode: null,
            selectedNode: null,
          ),
        );
        return;
      }

      HierarchyNode? nextSelectedNode;

      if (state.selectedNode != null) {
        final found = _findNode(newData, state.selectedNode!.id);
        nextSelectedNode = found ?? newData;
      } else {
        nextSelectedNode = newData;
      }

      emit(
        state.copyWith(
          status: HierarchyStatus.success,
          rootNode: newData,
          selectedNode: nextSelectedNode,
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print("Error loading hierarchy: $e");
      }
      emit(
        state.copyWith(
          status: HierarchyStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void selectNode(HierarchyNode node) {
    emit(
      state.copyWithUpdates(
        selectedNode: node,
        selectedPicture: () => null,
      ),
    );
  }

  void selectPicture(Picture? picture) {
    emit(
      state.copyWithUpdates(
        selectedPicture: () => picture,
      ),
    );
  }

  Future<void> addNode(
    String name,
    NodeType type,
    int parentId, {
    String? sourcePath,
  }) async {
    final newNode = HierarchyNode(
      id: 0,
      parentId: parentId,
      name: name,
      type: type,
      children: const [],
      subFolders: const [],
    );

    try {
      // Use createAlbum if it's an album AND a source path is provided
      if (type == NodeType.album &&
          sourcePath != null &&
          sourcePath.isNotEmpty) {
        await _backendService.createAlbum(newNode, sourcePath);
      } else {
        await _backendService.createNode(newNode);
      }
      await loadData();
    } catch (e) {
      if (kDebugMode) {
        print("Error creating node: $e");
      }
    }
  }

  /// Helper recursive find
  HierarchyNode? _findNode(HierarchyNode root, int id) {
    if (root.id == id) return root;
    for (final child in root.children) {
      final found = _findNode(child, id);
      if (found != null) return found;
    }
    return null;
  }
}
