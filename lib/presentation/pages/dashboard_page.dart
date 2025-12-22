import 'package:fluent_ui/fluent_ui.dart';
import '../../data/models/hierarchy_node.dart';
import '../../logic/bloc/dashboard_bloc.dart';
import '../../data/models/photo.dart';
import '../../data/enums/node_type.dart';
import '../widgets/inspector_panel.dart';
import '../widgets/status_icon.dart';
import '../dialogs/app_dialogs.dart';

class DashboardPage extends StatefulWidget {
  final VoidCallback toggleTheme;
  final ThemeMode currentMode;

  const DashboardPage({
    super.key,
    required this.toggleTheme,
    required this.currentMode,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final DashboardBloc _bloc = DashboardBloc();
  int topIndex = 0;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bloc,
      builder: (context, _) {
        final selectedNode = _bloc.selectedNode;
        final selectedPhoto = _bloc.selectedPhoto;

        // 1. Generate a FLAT list of Navigation Items with visual indentation
        final List<NavigationPaneItem> navItems = [
          PaneItemHeader(header: const Text("LIBRARY")),
          ..._buildFlatPaneItems(_bloc.rootNode),
        ];

        // 2. Calculate the index for the NavigationPane to update the highlight
        final int selectedIndex = _calculateSelectedIndex(
          navItems,
          selectedNode?.id,
        );

        return NavigationView(
          appBar: NavigationAppBar(
            automaticallyImplyLeading: false,
            title: const Text(
              'Picturebot',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            actions: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(
                    widget.currentMode == ThemeMode.light
                        ? FluentIcons.sunny
                        : FluentIcons.clear_night,
                  ),
                  onPressed: widget.toggleTheme,
                ),
                const SizedBox(width: 16),
              ],
            ),
          ),
          pane: NavigationPane(
            selected: selectedIndex,
            onChanged: (index) {
              setState(() => topIndex = index);
            },
            displayMode: PaneDisplayMode.open,
            size: const NavigationPaneSize(openWidth: 260),
            items: navItems,
            footerItems: [
              PaneItemSeparator(),
              PaneItem(
                icon: const Icon(FluentIcons.settings),
                title: const Text("Settings"),
                body: const Center(child: Text("Settings Page")),
                onTap: () => AppDialogs.showSettingsDialog(context),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- Helper to Recursive Build Flat Items with Indentation ---
  List<NavigationPaneItem> _buildFlatPaneItems(
    HierarchyNode node, {
    int depth = 0,
  }) {
    List<NavigationPaneItem> items = [];

    // 1. Create the item for the current node
    items.add(
      PaneItem(
        key: ValueKey(node.id),
        // Simulate tree depth by indenting the icon
        icon: Padding(
          padding: EdgeInsets.only(left: 16.0 * depth),
          child: Icon(
            node.type == NodeType.folder
                ? FluentIcons.folder_horizontal
                : FluentIcons.photo_collection,
            color: node.type == NodeType.folder ? Colors.yellow : Colors.blue,
          ),
        ),
        title: Text(
          node.name,
          style: const TextStyle(fontWeight: FontWeight.w500),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        // Pass the specific node to the body builder so the view is correct when clicked
        body: _buildMainContent(node, _bloc.selectedPhoto),
        onTap: () {
          // Important: Sync the BLoC state when an item is clicked
          _bloc.selectNode(node);
        },
      ),
    );

    // 2. Recursively add children to the same flat list
    for (var child in node.children) {
      items.addAll(_buildFlatPaneItems(child, depth: depth + 1));
    }

    return items;
  }

  // --- Helper to Find Index for Selection ---
  int _calculateSelectedIndex(
    List<NavigationPaneItem> items,
    String? targetId,
  ) {
    if (targetId == null) return 0;

    int index = 0;
    for (final item in items) {
      // We only care about selectable PaneItems, ignoring Headers/Separators for index count
      // BUT NavigationView counts Headers/Separators in the 'items' list index usually?
      // Actually, FluentUI 'selected' index usually corresponds to the visual order of *selectable* items
      // or the raw index in the 'items' array.
      // Safe approach: Check the key.
      if (item is PaneItem && item.key == ValueKey(targetId)) {
        return index;
      }
      index++;
    }
    return 0; // Default to first item if not found
  }

  // --- MAIN CONTENT BUILDER ---
  Widget _buildMainContent(HierarchyNode? nodeToRender, Photo? selectedPhoto) {
    // Use the passed node, fallback to BLoC if null (though it shouldn't be)
    final node = nodeToRender;

    if (node == null) return const SizedBox.shrink();

    Widget content;

    // CASE: FOLDER VIEW
    if (node.type == NodeType.folder) {
      if (node.children.isEmpty) {
        content = _buildEmptyState(
          icon: FluentIcons.folder_horizontal,
          text: "Empty Folder",
          actionLabel: "New Item",
          onAction: () => AppDialogs.showAddDialog(context, (name, type) {
            _bloc.addNode(name, type, int.parse(node.id));
          }),
        );
      } else {
        content = GridView.builder(
          itemCount: node.children.length + 1,
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
            mainAxisExtent: 180,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (ctx, index) {
            if (index == node.children.length) {
              return _buildAddItemCard(node);
            }
            final child = node.children[index];
            return HoverButton(
              onPressed: () => _bloc.selectNode(child),
              builder: (p0, states) {
                return Card(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        child.type == NodeType.folder
                            ? FluentIcons.folder_horizontal
                            : FluentIcons.photo_collection,
                        size: 48,
                        color: child.type == NodeType.folder
                            ? Colors.yellow
                            : Colors.blue,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        child.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        child.type == NodeType.folder
                            ? "${child.children.length} items"
                            : "${child.photos.length} Pictures",
                        style: FluentTheme.of(context).typography.caption,
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      }
    } else {
      // CASE: ALBUM VIEW
      final Map<String, List<Photo>> grouped = {};
      for (var p in node.photos) {
        final key = "${p.date.day}-${p.date.month}-${p.date.year}";
        if (!grouped.containsKey(key)) grouped[key] = [];
        grouped[key]!.add(p);
      }

      if (node.photos.isEmpty) {
        content = _buildEmptyState(
          icon: FluentIcons.photo2,
          text: "Albums has no pictures",
          actionLabel: "Import pictures",
          onAction: () {},
        );
      } else {
        content = ListView.builder(
          itemCount: grouped.keys.length,
          itemBuilder: (context, index) {
            final dateKey = grouped.keys.elementAt(index);
            final photos = grouped[dateKey]!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    children: [
                      Icon(FluentIcons.calendar, size: 16, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        dateKey,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "(${photos.length})",
                        style: TextStyle(
                          color: FluentTheme.of(
                            context,
                          ).resources.textFillColorSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 150,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 1,
                  ),
                  itemCount: photos.length,
                  itemBuilder: (c, i) {
                    final photo = photos[i];
                    final isSelected = selectedPhoto?.id == photo.id;
                    return GestureDetector(
                      onTap: () => _bloc.selectPhoto(photo),
                      child: Container(
                        decoration: BoxDecoration(
                          color: FluentTheme.of(
                            context,
                          ).resources.cardBackgroundFillColorDefault,
                          border: isSelected
                              ? Border.all(
                                  color: FluentTheme.of(context).accentColor,
                                  width: 2,
                                )
                              : Border.all(color: Colors.transparent),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: Icon(
                                FluentIcons.photo2,
                                size: 32,
                                color: Colors.grey.withOpacity(0.5),
                              ),
                            ),
                            if (photo.status == 'picked')
                              Positioned(
                                top: 4,
                                left: 4,
                                child: StatusIcon(
                                  icon: FluentIcons.heart_fill,
                                  color: Colors.red,
                                ),
                              ),
                            if (photo.status == 'rejected')
                              const Positioned(
                                top: 4,
                                left: 4,
                                child: StatusIcon(
                                  icon: FluentIcons.cancel,
                                  color: Colors.grey,
                                ),
                              ),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                color: Colors.black.withOpacity(0.5),
                                padding: const EdgeInsets.all(4),
                                child: Text(
                                  photo.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        );
      }
    }

    // Wrap the content in the Scaffold with Inspector
    return ScaffoldPage(
      header: PageHeader(
        title: Text(node.name),
        commandBar: CommandBar(
          primaryItems: [
            CommandBarButton(
              icon: const Icon(FluentIcons.add),
              label: const Text('New'),
              onPressed: () => AppDialogs.showAddDialog(context, (name, type) {
                _bloc.addNode(name, type, int.parse(node.id));
              }),
            ),
            CommandBarButton(
              icon: const Icon(FluentIcons.filter),
              label: const Text('Filters'),
              onPressed: () {},
            ),
            CommandBarButton(
              icon: const Icon(FluentIcons.delete),
              label: const Text('Delete'),
              onPressed: () => AppDialogs.showDeleteDialog(
                context,
                node.name,
                () {}, // Delete logic
              ),
            ),
          ],
        ),
      ),
      content: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: content,
            ),
          ),
          if (node.type == NodeType.album && selectedPhoto != null)
            InspectorPanel(
              photo: selectedPhoto,
              onClose: () => _bloc.selectPhoto(null),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String text,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: Colors.grey.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(text, style: const TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 16),
          FilledButton(onPressed: onAction, child: Text(actionLabel)),
        ],
      ),
    );
  }

  Widget _buildAddItemCard(HierarchyNode parentNode) {
    return HoverButton(
      onPressed: () => AppDialogs.showAddDialog(context, (name, type) {
        _bloc.addNode(name, type, int.parse(parentNode.id));
      }),
      builder: (p0, states) {
        return Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: FluentTheme.of(
                context,
              ).resources.dividerStrokeColorDefault,
              style: BorderStyle.solid,
            ),
            borderRadius: BorderRadius.circular(4),
            color: states.isHovering
                ? FluentTheme.of(context).resources.subtleFillColorSecondary
                : Colors.transparent,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: FluentTheme.of(
                    context,
                  ).resources.solidBackgroundFillColorBase,
                ),
                child: const Icon(FluentIcons.add),
              ),
              const SizedBox(height: 8),
              const Text("New Item"),
            ],
          ),
        );
      },
    );
  }
}
