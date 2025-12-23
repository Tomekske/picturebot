import 'package:equatable/equatable.dart';

import '../enums/node_type.dart';
import 'picture.dart';

class HierarchyNode extends Equatable {
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

  factory HierarchyNode.fromJson(Map<String, dynamic> json) {
    return HierarchyNode(
      id: json['id'] as int,
      name: json['name'] as String,
      type: NodeType.values.byName(json['type'] as String),
      parentId: json['parent_id'] as int?,
      children:
          (json['children'] as List<dynamic>?)
              ?.map((e) => HierarchyNode.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      pictures:
          (json['pictures'] as List<dynamic>?)
              ?.map((e) => Picture.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'parent_id': parentId,
      'children': children.map((node) => node.toJson()).toList(),
      'pictures': pictures.map((pic) => pic.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    name,
    type,
    parentId,
    children,
    pictures,
  ];
}
