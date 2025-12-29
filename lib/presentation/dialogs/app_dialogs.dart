import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:picturebot/data/enums/node_type.dart';
import 'package:picturebot/presentation/dialogs/settings_dialog.dart';

import '../../data/models/hierarchy_node.dart';
import 'hierarchy_dialog.dart';
import '../../logic/settings/settings_cubit.dart';

class AppDialogs {
  static Future<void> showHierarchyDialog(
    BuildContext context,
    List<HierarchyNode>? folders,
    Function(String name, NodeType type, int parentId) onAdd,
  ) async {
    await showDialog(
      context: context,
      builder: (context) {
        return HierarchyDialog(
          folders: folders,
          onAdd: onAdd,
        );
      },
    );
  }

  static Future<void> showSettingsDialog(BuildContext context) async {
    final settingsCubit = context.read<SettingsCubit>();
    await showDialog(
      context: context,
      dismissWithEsc: true,
      builder: (dialogContext) {
        return BlocBuilder<SettingsCubit, SettingsState>(
          bloc: settingsCubit,
          builder: (context, state) {
            return SettingsDialog(
              currentMode: state.settings.themeMode,
              onThemeChanged: (mode) {
                settingsCubit.updateTheme(mode);
              },
              currentLibraryPath: state.settings.libraryPath,
              onLibraryPathChanged: (newPath) {
                settingsCubit.updateLibraryLocation(newPath);
              },
            );
          },
        );
      },
    );
  }

  static Future<void> showDeleteDialog(
    BuildContext context,
    String nodeName,
    VoidCallback onConfirm,
  ) async {
    await showDialog(
      context: context,
      builder: (context) {
        return ContentDialog(
          title: const Text('Delete'),
          content: Text('Are you sure that you want to delete "$nodeName" ?'),
          actions: [
            Button(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            FilledButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.red),
              ),
              child: const Text('Delete'),
              onPressed: () {
                onConfirm();
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
