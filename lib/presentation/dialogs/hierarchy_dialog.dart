import 'package:fluent_ui/fluent_ui.dart';
import 'package:picturebot/data/enums/node_type.dart';
import '../../data/models/hierarchy_node.dart';

class HierarchyDialog extends StatefulWidget {
  final Function(String name, NodeType type, int parentId) onAdd;
  final List<HierarchyNode> folders;

  const HierarchyDialog({
    super.key,
    required this.onAdd,
    required this.folders,
  });

  @override
  State<HierarchyDialog> createState() => _HierarchyDialogState();
}

class _HierarchyDialogState extends State<HierarchyDialog> {
  late TextEditingController _nameController;
  NodeType _selectedType = NodeType.album;
  int? _selectedParentId;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    // Default to the first folder if available, or root
    if (widget.folders.isNotEmpty) {
      _selectedParentId = widget.folders.first.id;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: const Text('Add a new item'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                  value: NodeType.album,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTypeButton(
                  context: context,
                  label: 'Folder',
                  icon: FluentIcons.folder_horizontal,
                  value: NodeType.folder,
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
          ComboBox<int>(
            value: _selectedParentId,
            isExpanded: true,
            items: widget.folders.map((node) {
              return ComboBoxItem<int>(
                value: node.id,
                child: Text(node.name),
              );
            }).toList(),
            onChanged: (v) {
              if (v != null) {
                setState(() => _selectedParentId = v);
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
            if (_selectedParentId != null) {
              widget.onAdd(
                _nameController.text,
                _selectedType,
                _selectedParentId!,
              );
              Navigator.pop(context);
            }
          },
        ),
      ],
    );
  }

  Widget _buildTypeButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required NodeType value,
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
}
