import '../enums/node_type.dart';
import 'picture.dart';

class HierarchyNode {
  final int id;
  final String name;
  final NodeType type;
  final int? parentId;
  final List<HierarchyNode> children;
  final List<Picture> pictures;

  HierarchyNode({
    required this.id,
    required this.name,
    required this.type,
    this.parentId,
    this.children = const [],
    this.pictures = const [],
  });

  HierarchyNode copyWith({
    String? name,
    List<HierarchyNode>? children,
    List<Picture>? pictures,
  }) {
    return HierarchyNode(
      id: id,
      name: name ?? this.name,
      type: type,
      parentId: parentId,
      children: children ?? this.children,
      pictures: pictures ?? this.pictures,
    );
  }
}
