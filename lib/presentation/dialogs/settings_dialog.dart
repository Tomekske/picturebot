import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';

class SettingsDialog extends StatefulWidget {
  final ThemeMode currentMode;
  final Function(ThemeMode) onThemeChanged;
  final String currentLibraryPath;
  final Function(String) onLibraryPathChanged;

  const SettingsDialog({
    super.key,
    required this.currentMode,
    required this.onThemeChanged,
    required this.currentLibraryPath,
    required this.onLibraryPathChanged,
  });

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late String _libraryPath;
  late TextEditingController _libraryPathController;

  @override
  void initState() {
    super.initState();
    _libraryPath = widget.currentLibraryPath;
    _libraryPathController = TextEditingController(text: _libraryPath);
  }

  @override
  void dispose() {
    _libraryPathController.dispose();
    super.dispose();
  }

  Future<void> _pickLibraryPath() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      setState(() {
        _libraryPath = selectedDirectory;
        _libraryPathController.text = selectedDirectory;
      });
      widget.onLibraryPathChanged(selectedDirectory);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Settings"),
          IconButton(
            icon: const Icon(FluentIcons.chrome_close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "THEME",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildThemeCard(
                context: context,
                mode: ThemeMode.light,
                title: "Light",
                icon: FluentIcons.sunny,
              ),
              const SizedBox(width: 16),
              _buildThemeCard(
                context: context,
                mode: ThemeMode.dark,
                title: "Dark",
                icon: FluentIcons.clear_night,
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            "LIBRARY LOCATION",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextBox(
                  readOnly: true,
                  placeholder: "Select a folder on your HDD...",
                  controller: _libraryPathController,
                ),
              ),
              const SizedBox(width: 8),
              Button(
                onPressed: _pickLibraryPath,
                child: const Text("Browse"),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "This folder will be used to store your albums.",
            style: FluentTheme.of(context).typography.caption,
          ),
        ],
      ),
      actions: [
        Button(
          child: const Text('Close'),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildThemeCard({
    required BuildContext context,
    required ThemeMode mode,
    required String title,
    required IconData icon,
  }) {
    final bool isSelected = widget.currentMode == mode;
    final theme = FluentTheme.of(context);

    return Expanded(
      child: GestureDetector(
        onTap: () => widget.onThemeChanged(mode),
        child: Container(
          height: 70,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.resources.cardBackgroundFillColorDefault,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isSelected
                  ? theme.accentColor
                  : theme.resources.dividerStrokeColorDefault,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.resources.solidBackgroundFillColorBase,
                ),
                child: Icon(icon, size: 18),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  if (isSelected)
                    Text(
                      "Active",
                      style: TextStyle(
                        fontSize: 10,
                        color: theme.accentColor,
                      ),
                    ),
                ],
              ),
              const Spacer(),
              if (isSelected)
                Icon(
                  FluentIcons.check_mark,
                  color: theme.accentColor,
                  size: 16,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
