import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../data/models/settings.dart';
import '../../data/services/backend_service.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final BackendService _backendService;

  SettingsCubit(this._backendService) : super(SettingsInitial());

  /// Loads settings from the repository.
  Future<void> loadSettings() async {
    emit(SettingsLoading(state.settings));
    try {
      final settings = await _backendService.loadSettings();
      emit(SettingsLoaded(settings));
    } catch (e) {
      emit(SettingsError(state.settings, "Failed to load settings"));
    }
  }

  /// Updates the theme mode and emits a new state.
  Future<void> updateTheme(ThemeMode mode) async {
    try {
      final newSettings = state.settings.copyWith(themeMode: mode);
      emit(SettingsLoaded(newSettings));

      // TODO: Call _backendService.saveSettings(newSettings) to persist
    } catch (e) {
      if (kDebugMode) {
        print("Error updating theme: $e");
      }
      emit(SettingsError(state.settings, "Failed to update theme"));
    }
  }

  /// Updates the library path and emits a new state.
  void updateLibraryLocation(String path) {
    try {
      final newSettings = state.settings.copyWith(libraryPath: path);
      emit(SettingsLoaded(newSettings));

      // TODO: Call _backendService.saveSettings(newSettings) to persist
    } catch (e) {
      if (kDebugMode) {
        print("Error updating library: $e");
      }
      emit(SettingsError(state.settings, "Failed to update library"));
    }
  }
}
