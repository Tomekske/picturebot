import '../enums/node_type.dart';
import 'photo.dart';

class HierarchyNode {
  final String id;
  final String name;
  final NodeType type;
  final int? parentId;
  final List<HierarchyNode> children;
  final List<Photo> photos;

  HierarchyNode({
    required this.id,
    required this.name,
    required this.type,
    this.parentId,
    this.children = const [],
    this.photos = const [],
  });

  HierarchyNode copyWith({
    String? name,
    List<HierarchyNode>? children,
    List<Photo>? photos,
  }) {
    return HierarchyNode(
      id: id,
      name: name ?? this.name,
      type: type,
      parentId: parentId,
      children: children ?? this.children,
      photos: photos ?? this.photos,
    );
  }
}
