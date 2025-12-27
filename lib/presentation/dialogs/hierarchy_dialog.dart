import 'package:fluent_ui/fluent_ui.dart';
import 'package:picturebot/data/enums/node_type.dart';

class HierarchyDialog extends StatefulWidget {
  final Function(String name, String type) onAdd;

  const HierarchyDialog({
    super.key,
    required this.onAdd,
  });

  @override
  State<HierarchyDialog> createState() => _HierarchyDialogState();
}

class _HierarchyDialogState extends State<HierarchyDialog> {
  late TextEditingController _nameController;
  String _selectedType = 'ALBUM';
  String _selectedLocation = 'California';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: const Text('Nieuw Item Toevoegen'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- TYPE SECTION ---
          const Text(
            "TYPE",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildTypeButton(
                  context: context,
                  label: 'Album',
                  icon: FluentIcons.photo_collection,
                  value: NodeType.album.name,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTypeButton(
                  context: context,
                  label: 'Folder',
                  icon: FluentIcons.folder_horizontal,
                  value: NodeType.folder.name,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            "Name",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          TextBox(
            controller: _nameController,
            placeholder: 'Example: Los Angeles',
          ),
          const SizedBox(height: 16),

          const Text(
            "Parent",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          ComboBox<String>(
            value: _selectedLocation,
            isExpanded: true,
            items: [
              _buildComboItem("Library", 0),
              _buildComboItem("The United States", 1),
              _buildComboItem("California", 2),
              _buildComboItem("New York", 2),
              _buildComboItem("Belgium", 1),
            ],
            onChanged: (v) {
              if (v != null) {
                setState(() => _selectedLocation = v);
              }
            },
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
            widget.onAdd(_nameController.text, _selectedType);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  Widget _buildTypeButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required String value,
  }) {
    final theme = FluentTheme.of(context);
    final isSelected = _selectedType == value;

    return GestureDetector(
      onTap: () => setState(() => _selectedType = value),
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          color: isSelected
              ? theme.resources.subtleFillColorSecondary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected
                ? theme.accentColor
                : theme.resources.dividerStrokeColorDefault,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? theme.accentColor
                  : theme.typography.body?.color,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? theme.accentColor
                    : theme.typography.body?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  ComboBoxItem<String> _buildComboItem(String text, int depth) {
    return ComboBoxItem(
      value: text,
      child: Padding(
        padding: EdgeInsets.only(left: depth * 12.0),
        child: Text(text),
      ),
    );
  }
}
