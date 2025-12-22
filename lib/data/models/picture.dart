import 'package:picturebot/data/enums/color_label.dart';
import 'package:picturebot/data/enums/picture_status.dart';
import 'package:equatable/equatable.dart';
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
