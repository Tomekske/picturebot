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
  ///
  /// Emits [SettingsLoading] before starting the fetch and [SettingsLoaded]
  /// upon success. If the fetch fails, [SettingsError] is emitted, but the
  /// previous settings are retained in the state.
  Future<void> loadSettings() async {
    emit(SettingsLoading(state.settings));
    try {
      final settings = await _backendService.loadSettings();
      emit(SettingsLoaded(settings));
    } catch (e) {
      emit(SettingsError(state.settings, "Failed to load settings"));
    }
  }

  /// Updates the application theme and persists the change.
  ///
  /// This method performs an **optimistic update**: it immediately emits the
  /// new [ThemeMode] to the UI (via [SettingsLoaded]) so the app reacts instantly.
  /// It then asynchronously calls [BackendService.saveSettings] to persist the
  /// change to the backend.
  ///
  /// If persistence fails, an error is logged (in debug mode) and a
  /// [SettingsError] state is emitted.
  Future<void> updateTheme(ThemeMode mode) async {
    try {
      final newSettings = state.settings.copyWith(themeMode: mode);
      emit(SettingsLoaded(newSettings));

      await _backendService.saveSettings(newSettings);
    } catch (e) {
      if (kDebugMode) {
        print("Error updating theme: $e");
      }
      emit(SettingsError(state.settings, "Failed to update theme"));
    }
  }

  /// Updates the library file path and persists the change.
  ///
  /// Similar to [updateTheme], this performs an **optimistic update** by
  /// emitting the new path immediately. The backend is then notified to save
  /// this new configuration.
  ///
  /// [path] should be a valid absolute directory path on the user's HDD.
  Future<void> updateLibraryLocation(String path) async {
    try {
      final newSettings = state.settings.copyWith(libraryPath: path);
      emit(SettingsLoaded(newSettings));

      await _backendService.saveSettings(newSettings);
    } catch (e) {
      if (kDebugMode) {
        print("Error updating library: $e");
      }
      emit(SettingsError(state.settings, "Failed to update library"));
    }
  }
}
