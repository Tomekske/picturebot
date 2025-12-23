import 'package:equatable/equatable.dart';

class Exif extends Equatable {
  final String? camera;
  final String? lens;
  final String? iso;
  final String? aperture;
  final String? shutter;
  final String? dimensions;
  final String? size;

  const Exif({
    required this.camera,
    required this.lens,
    required this.iso,
    required this.aperture,
    required this.shutter,
    required this.dimensions,
    required this.size,
  });

  Exif copyWith({
    String? camera,
    String? lens,
    String? iso,
    String? aperture,
    String? shutter,
    String? dimensions,
    String? size,
  }) {
    return Exif(
      camera: camera ?? this.camera,
      lens: lens ?? this.lens,
      iso: iso ?? this.iso,
      aperture: aperture ?? this.aperture,
      shutter: shutter ?? this.shutter,
      dimensions: dimensions ?? this.dimensions,
      size: size ?? this.size,
    );
  }

  @override
  List<Object?> get props => [
    camera,
    lens,
    iso,
    aperture,
    shutter,
    dimensions,
    size,
  ];

  factory Exif.fromJson(Map<String, dynamic> json) {
    return Exif(
      camera: json['camera'] as String?,
      lens: json['lens'] as String?,
      iso: json['iso'] as String?,
      aperture: json['aperture'] as String?,
      shutter: json['shutter'] as String?,
      dimensions: json['dimensions'] as String?,
      size: json['size'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'camera': camera,
      'lens': lens,
      'iso': iso,
      'aperture': aperture,
      'shutter': shutter,
      'dimensions': dimensions,
      'size': size,
    };
  }
}
