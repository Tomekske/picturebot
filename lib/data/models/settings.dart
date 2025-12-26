import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class Settings extends Equatable {
  final ThemeMode themeMode;
  final String libraryPath;

  const Settings({
    required this.themeMode,
    required this.libraryPath,
  });

  factory Settings.initial() {
    return const Settings(
      themeMode: ThemeMode.system,
      libraryPath: '',
    );
  }

  Settings copyWith({
    ThemeMode? themeMode,
    String? libraryPath,
  }) {
    return Settings(
      themeMode: themeMode ?? this.themeMode,
      libraryPath: libraryPath ?? this.libraryPath,
    );
  }

  factory Settings.fromJson(Map<String, dynamic> json) {
    return Settings(
      themeMode: _parseThemeMode(json['theme_mode']),
      libraryPath: json['library_path'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'theme_mode': themeMode.name,
      'library_path': libraryPath,
    };
  }

  static ThemeMode _parseThemeMode(String? mode) {
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  @override
  List<Object?> get props => [themeMode, libraryPath];
}
