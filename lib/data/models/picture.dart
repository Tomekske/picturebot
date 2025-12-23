import 'package:equatable/equatable.dart';
import 'package:picturebot/data/enums/color_label.dart';
import 'package:picturebot/data/enums/picture_status.dart';

import '../enums/picture_type.dart';
import 'exif.dart';

class Picture extends Equatable {
  final String id;
  final String name;
  final String url;
  final DateTime date;
  final PictureType type;
  final PictureStatus status;
  final ColorLabel colorLabel;
  final Exif exif;

  const Picture({
    required this.id,
    required this.name,
    required this.url,
    required this.date,
    required this.type,
    this.status = PictureStatus.untagged,
    this.colorLabel = ColorLabel.none,
    required this.exif,
  });

  Picture copyWith({
    String? id,
    String? name,
    String? url,
    DateTime? date,
    PictureType? type,
    PictureStatus? status,
    ColorLabel? colorLabel,
    Exif? exif,
  }) {
    return Picture(
      id: id ?? this.id,
      name: name ?? this.name,
      url: url ?? this.url,
      date: date ?? this.date,
      type: type ?? this.type,
      status: status ?? this.status,
      colorLabel: colorLabel ?? this.colorLabel,
      exif: exif ?? this.exif,
    );
  }

  factory Picture.fromJson(Map<String, dynamic> json) {
    return Picture(
      id: json['id'] as String,
      name: json['name'] as String,
      url: json['url'] as String,
      date: DateTime.parse(json['date'] as String),
      type: PictureType.values.byName(json['type'] as String),
      status: json['status'] != null
          ? PictureStatus.values.byName(json['status'] as String)
          : PictureStatus.untagged,
      colorLabel: json['color_label'] != null
          ? ColorLabel.values.byName(json['color_label'] as String)
          : ColorLabel.none,
      exif: Exif.fromJson(json['exif'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'date': date.toIso8601String(),
      'type': type.name,
      'status': status.name,
      'color_label': colorLabel.name,
      'exif': exif.toJson(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    name,
    url,
    date,
    type,
    status,
    colorLabel,
    exif,
  ];
}
