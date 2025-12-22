import 'package:fluent_ui/fluent_ui.dart';

class AppDialogs {
  static Future<void> showAddDialog(
    BuildContext context, 
    Function(String name, String type) onAdd
  ) async {
    final nameController = TextEditingController();
    String type = 'ALBUM';
    await showDialog(
      context: context,
      builder: (context) {
        return ContentDialog(
          title: const Text('Nieuw Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Naam:"),
              const SizedBox(height: 8),
              TextBox(
                controller: nameController,
                placeholder: 'Bijv. Vakantie 2024',
              ),
              const SizedBox(height: 16),
              const Text("Type:"),
              const SizedBox(height: 8),
              ComboBox<String>(
                value: type,
                items: const [
                  ComboBoxItem(value: 'ALBUM', child: Text("Album")),
                  ComboBoxItem(value: 'FOLDER', child: Text("Map")),
                ],
                onChanged: (v) => type = v ?? 'ALBUM',
              ),
            ],
          ),
          actions: [
            Button(
                child: const Text('Annuleren'),
                onPressed: () => Navigator.pop(context)),
            FilledButton(
              child: const Text('Aanmaken'),
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

  static Future<void> showDeleteDialog(BuildContext context, String nodeName, VoidCallback onConfirm) async {
    await showDialog(
      context: context,
      builder: (context) {
        return ContentDialog(
          title: const Text('Verwijderen'),
          content: Text(
              'Weet je zeker dat je "$nodeName" wilt verwijderen?'),
          actions: [
            Button(
                child: const Text('Annuleren'),
                onPressed: () => Navigator.pop(context)),
            FilledButton(
              style: ButtonStyle(backgroundColor: ButtonState.all(Colors.red)),
              child: const Text('Verwijderen'),
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
          title: const Text('Instellingen'),
          content: const Text('Hier komen instellingen...'),
          actions: [
            Button(
                child: const Text('Sluiten'),
                onPressed: () => Navigator.pop(context)),
          ],
        );
      },
    );
  }
}