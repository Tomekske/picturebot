import 'package:fluent_ui/fluent_ui.dart';
import '../../data/models/hierarchy_node.dart';
import '../../data/enums/node_type.dart';

class AlbumTreeView extends StatelessWidget {
  final HierarchyNode root;
  final Function(HierarchyNode) onSelect;
  final int? selectedId;

  const AlbumTreeView({
    super.key,
    required this.root,
    required this.onSelect,
    this.selectedId,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...root.children.map((child) => _buildNode(child, 0, context, {})),
      ],
    );
  }

  Widget _buildNode(
    HierarchyNode node,
    int depth,
    BuildContext context,
    Set<int> visited,
  ) {
    // Prevent circular references
    if (visited.contains(node.id)) {
      return const SizedBox.shrink();
    }

    final isSelected = node.id == selectedId;
    final newVisited = {...visited, node.id};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 2.0),
          child: ListTile(
            leading: Padding(
              padding: EdgeInsets.only(left: depth * 16.0),
              child: Icon(
                node.type == NodeType.folder
                    ? FluentIcons.folder_horizontal
                    : FluentIcons.photo_collection,
                color: node.type == NodeType.folder
                    ? Colors.yellow
                    : Colors.purple,
              ),
            ),
            title: Text(
              node.name,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? FluentTheme.of(context).accentColor : null,
              ),
            ),
            onPressed: () => onSelect(node),
          ),
        ),
        if (node.children.isNotEmpty)
          ...node.children.map(
            (child) => _buildNode(child, depth + 1, context, newVisited),
          ),
      ],
    );
  }
}
