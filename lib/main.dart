import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:picturebot/data/services/backend_service.dart';
import 'data/repositories/backend_repository.dart';
import 'logic/settings/settings_cubit.dart';
import 'presentation/pages/dashboard_page.dart';

void main() {
  final repository = BackendRepository();
  final service = BackendService(repository);

  runApp(PhotoOrganizerApp(backendService: service));
}

class PhotoOrganizerApp extends StatelessWidget {
  final BackendService _backendService;

  const PhotoOrganizerApp({
    super.key,
    required BackendService backendService,
  }) : _backendService = backendService;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: _backendService),
      ],
      child: BlocProvider(
        create: (context) => SettingsCubit(_backendService)..loadSettings(),
        child: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, state) {
            return FluentApp(
              title: 'Picturebot',
              themeMode: state.settings.themeMode,
              debugShowCheckedModeBanner: false,
              theme: FluentThemeData(
                accentColor: Colors.blue,
                brightness: Brightness.light,
                visualDensity: VisualDensity.standard,
                scaffoldBackgroundColor: const Color(0xFFF3F3F3),
              ),
              darkTheme: FluentThemeData(
                accentColor: Colors.blue,
                brightness: Brightness.dark,
                visualDensity: VisualDensity.standard,
                scaffoldBackgroundColor: const Color(0xFF202020),
              ),
              home: DashboardPage(),
            );
          },
        ),
      ),
    );
  }
}
