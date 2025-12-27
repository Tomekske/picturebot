import 'package:equatable/equatable.dart';
import '../../data/models/hierarchy_node.dart';
import '../../data/models/picture.dart';

enum HierarchyStatus { initial, loading, success, failure }

class HierarchyState extends Equatable {
  final HierarchyStatus status;
  final HierarchyNode? rootNode;
  final HierarchyNode? selectedNode;
  final Picture? selectedPicture;
  final String? errorMessage;

  const HierarchyState({
    this.status = HierarchyStatus.initial,
    this.rootNode,
    this.selectedNode,
    this.selectedPicture,
    this.errorMessage,
  });

  HierarchyState copyWith({
    HierarchyStatus? status,
    HierarchyNode? rootNode,
    HierarchyNode? selectedNode,
    Picture? selectedPicture,
    String? errorMessage,
  }) {
    return HierarchyState(
      status: status ?? this.status,
      rootNode: rootNode ?? this.rootNode,
      selectedNode: selectedNode ?? this.selectedNode,
      selectedPicture: selectedPicture ?? this.selectedPicture,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  HierarchyState copyWithUpdates({
    HierarchyStatus? status,
    HierarchyNode? rootNode,
    HierarchyNode? selectedNode,
    Picture? Function()? selectedPicture,
    String? errorMessage,
  }) {
    return HierarchyState(
      status: status ?? this.status,
      rootNode: rootNode ?? this.rootNode,
      selectedNode: selectedNode ?? this.selectedNode,
      selectedPicture: selectedPicture != null
          ? selectedPicture()
          : this.selectedPicture,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    rootNode,
    selectedNode,
    selectedPicture,
    errorMessage,
  ];
}
