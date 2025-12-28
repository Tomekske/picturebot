import 'package:equatable/equatable.dart';
import 'package:picturebot/data/enums/picture_type.dart';

class Picture extends Equatable {
  final int id;
  final String fileName;
  final String index;
  final String extension;
  final PictureType type;
  final String location;
  final int subFolderId;

  const Picture({
    required this.id,
    required this.fileName,
    required this.index,
    required this.extension,
    required this.type,
    required this.location,
    required this.subFolderId,
  });

  Picture copyWith({
    int? id,
    String? fileName,
    String? index,
    String? extension,
    PictureType? type,
    String? location,
    int? subFolderId,
  }) {
    return Picture(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      index: index ?? this.index,
      extension: extension ?? this.extension,
      type: type ?? this.type,
      location: location ?? this.location,
      subFolderId: subFolderId ?? this.subFolderId,
    );
  }

  factory Picture.fromJson(Map<String, dynamic> json) {
    return Picture(
      id: json['id'] as int,
      fileName: json['file_name'] as String,
      index: json['index'] as String,
      extension: json['extension'] as String,
      type: PictureType.values.byName(json['type'] as String),
      location: json['location'] as String,
      subFolderId: json['sub_folder_id'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'file_name': fileName,
      'index': index,
      'extension': extension,
      'type': type.name,
      'location': location,
      'sub_folder_id': subFolderId,
    };
  }

  @override
  List<Object?> get props => [
    id,
    fileName,
    index,
    extension,
    type,
    location,
    subFolderId,
  ];
}
