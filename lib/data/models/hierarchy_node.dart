import 'package:equatable/equatable.dart';
import '../enums/node_type.dart';
import 'sub_folder.dart';

class HierarchyNode extends Equatable {
  final int id;
  final int? parentId;
  final NodeType type;
  final String name;
  final String? uuid;
  final List<HierarchyNode> children;
  final List<SubFolder> subFolders;

  const HierarchyNode({
    required this.id,
    this.parentId,
    required this.type,
    required this.name,
    this.uuid,
    this.children = const [],
    this.subFolders = const [],
  });

  HierarchyNode copyWith({
    int? id,
    int? parentId,
    NodeType? type,
    String? name,
    String? uuid,
    List<HierarchyNode>? children,
    List<SubFolder>? subFolders,
  }) {
    return HierarchyNode(
      id: id ?? this.id,
      parentId: parentId ?? this.parentId,
      type: type ?? this.type,
      name: name ?? this.name,
      uuid: uuid ?? this.uuid,
      children: children ?? this.children,
      subFolders: subFolders ?? this.subFolders,
    );
  }

  factory HierarchyNode.fromJson(Map<String, dynamic> json) {
    return HierarchyNode(
      id: json['id'] as int,
      parentId: json['parent_id'] as int?,
      type: NodeType.values.byName(json['type'] as String),
      name: json['name'] as String,
      uuid: json['uuid'] as String?,
      children:
          (json['children'] as List<dynamic>?)
              ?.map((e) => HierarchyNode.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      subFolders:
          (json['sub_folders'] as List<dynamic>?)
              ?.map((e) => SubFolder.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'parent_id': parentId,
      'type': type.name,
      'name': name,
      'uuid': uuid,
      'children': children.map((node) => node.toJson()).toList(),
      'sub_folders': subFolders.map((sf) => sf.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    parentId,
    type,
    name,
    uuid,
    children,
    subFolders,
  ];
}
