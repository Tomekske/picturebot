import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // 1. Add this import
import 'package:picturebot/data/services/backend_service.dart';
import 'data/repositories/mock_repository.dart';
import 'presentation/pages/dashboard_page.dart';

void main() {
  final mockRepository = MockRepository();
  final service = BackendService(mockRepository);

  runApp(PhotoOrganizerApp(backendService: service));
}

class PhotoOrganizerApp extends StatefulWidget {
  final BackendService _backendService;

  const PhotoOrganizerApp({
    super.key,
    required BackendService backendService,
  }) : _backendService = backendService;

  @override
  State<PhotoOrganizerApp> createState() => _PhotoOrganizerAppState();
}

class _PhotoOrganizerAppState extends State<PhotoOrganizerApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: widget._backendService,
      child: FluentApp(
        title: 'Picturebot',
        themeMode: _themeMode,
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
        home: DashboardPage(
          toggleTheme: toggleTheme,
          currentMode: _themeMode,
        ),
      ),
    );
  }
}
