import 'package:equatable/equatable.dart';
import 'picture.dart';

class SubFolder extends Equatable {
  final int id;
  final String name;
  final String location;
  final int hierarchyId;
  final List<Picture> pictures;

  const SubFolder({
    required this.id,
    required this.name,
    required this.location,
    required this.hierarchyId,
    this.pictures = const [],
  });

  SubFolder copyWith({
    int? id,
    String? name,
    String? location,
    int? hierarchyId,
    List<Picture>? pictures,
  }) {
    return SubFolder(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      hierarchyId: hierarchyId ?? this.hierarchyId,
      pictures: pictures ?? this.pictures,
    );
  }

  factory SubFolder.fromJson(Map<String, dynamic> json) {
    return SubFolder(
      id: json['id'] as int,
      name: json['name'] as String,
      location: json['location'] as String,
      hierarchyId: json['hierarchy_id'] as int,
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
      'location': location,
      'hierarchy_id': hierarchyId,
      'pictures': pictures.map((pic) => pic.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [id, name, location, hierarchyId, pictures];
}
