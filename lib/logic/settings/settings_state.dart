part of 'settings_cubit.dart';

sealed class SettingsState extends Equatable {
  final Settings settings;

  const SettingsState(this.settings);

  @override
  List<Object> get props => [settings];
}

final class SettingsInitial extends SettingsState {
  SettingsInitial() : super(Settings.initial());
}

final class SettingsLoading extends SettingsState {
  const SettingsLoading(super.settings);
}

final class SettingsLoaded extends SettingsState {
  const SettingsLoaded(super.settings);
}

final class SettingsError extends SettingsState {
  final String message;

  const SettingsError(super.settings, this.message);

  @override
  List<Object> get props => [settings, message];
}
