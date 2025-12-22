import 'package:fluent_ui/fluent_ui.dart';

class AppDialogs {
  static Future<void> showAddDialog(
    BuildContext context,
    Function(String name, String type) onAdd,
  ) async {
    final nameController = TextEditingController();
    String type = 'ALBUM';
    await showDialog(
      context: context,
      builder: (context) {
        return ContentDialog(
          title: const Text('New Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Name:"),
              const SizedBox(height: 8),
              TextBox(
                controller: nameController,
                placeholder: 'Example. Vacation 2024',
              ),
              const SizedBox(height: 16),
              const Text("Type:"),
              const SizedBox(height: 8),
              ComboBox<String>(
                value: type,
                items: const [
                  ComboBoxItem(value: 'ALBUM', child: Text("Album")),
                  ComboBoxItem(value: 'FOLDER', child: Text("Folder")),
                ],
                onChanged: (v) => type = v ?? 'ALBUM',
              ),
            ],
          ),
          actions: [
            Button(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            FilledButton(
              child: const Text('Create'),
              onPressed: () {
                onAdd(nameController.text, type);
                Navigator.pop(context);
              },
            ),
          ],
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

  static Future<void> showSettingsDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) {
        return ContentDialog(
          title: const Text('Settings'),
          content: const Text('Todo'),
          actions: [
            Button(
              child: const Text('Close'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }
}
