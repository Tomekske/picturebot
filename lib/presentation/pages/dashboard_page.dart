import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:picturebot/data/enums/picture_status.dart';

import '../../data/enums/node_type.dart';
import '../../data/models/hierarchy_node.dart';
import '../../data/models/picture.dart';
import '../../data/services/backend_service.dart';
import '../../logic/bloc/dashboard_bloc.dart';
import '../../logic/settings/settings_cubit.dart';
import '../dialogs/app_dialogs.dart';
import '../widgets/inspector_panel.dart';
import '../widgets/status_icon.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late final DashboardBloc _bloc;
  int topIndex = 0;

  @override
  void initState() {
    super.initState();
    final backendService = context.read<BackendService>();
    _bloc = DashboardBloc(backendService);
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  // Helper to flatten the tree into a list of folders
  List<HierarchyNode> _getAllFolders(HierarchyNode root) {
    List<HierarchyNode> folders = [];
    if (root.type == NodeType.folder) {
      folders.add(root);
    }
    for (var child in root.children) {
      folders.addAll(_getAllFolders(child));
    }
    return folders;
  }

  void _openAddDialog(HierarchyNode? parentNode) {
    if (_bloc.rootNode == null) return;

    // Get all folders for the dropdown
    final allFolders = _getAllFolders(_bloc.rootNode!);

    AppDialogs.showHierarchyDialog(context, allFolders, (name, type, parentId) {
      // Use the selected parentId from the dialog
      _bloc.addNode(name, type.name, parentId);
    });
  }

  @override
  Widget build(BuildContext context) {
    context.watch<SettingsCubit>();

    return AnimatedBuilder(
      animation: _bloc,
      builder: (context, _) {
        if (_bloc.rootNode == null) {
          return const ScaffoldPage(
            content: Center(child: ProgressRing()),
          );
        }

        final selectedNode = _bloc.selectedNode;

        // Generate a FLAT list of Navigation Items with visual indentation
        final List<NavigationPaneItem> navItems = [
          PaneItemHeader(header: const Text("LIBRARY")),
          ..._buildFlatPaneItems(_bloc.rootNode!),
        ];

        final int selectedIndex = _calculateSelectedIndex(
          navItems,
          selectedNode?.id,
        );

        return NavigationView(
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
                body: const SizedBox.shrink(),
                onTap: () {
                  AppDialogs.showSettingsDialog(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ... (Rest of the file remains similar, just updating the _openAddDialog calls)

  List<NavigationPaneItem> _buildFlatPaneItems(
    HierarchyNode node, {
    int depth = 0,
  }) {
    List<NavigationPaneItem> items = [];

    items.add(
      PaneItem(
        key: ValueKey(node.id),
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
        body: _buildMainContent(node, _bloc.selectedPicture),
        onTap: () {
          _bloc.selectNode(node);
        },
      ),
    );

    for (var child in node.children) {
      items.addAll(_buildFlatPaneItems(child, depth: depth + 1));
    }

    return items;
  }

  int _calculateSelectedIndex(
    List<NavigationPaneItem> items,
    int? targetId,
  ) {
    if (targetId == null) return 0;

    int index = 0;
    for (final item in items) {
      if (item is PaneItem) {
        if (item.key == ValueKey(targetId)) {
          return index;
        }
        index++;
      }
    }
    return 0;
  }

  Widget _buildMainContent(
    HierarchyNode? nodeToRender,
    Picture? selectedPicture,
  ) {
    final node = nodeToRender;

    if (node == null) return const SizedBox.shrink();

    Widget content;

    if (node.type == NodeType.folder) {
      if (node.children.isEmpty) {
        content = _buildEmptyState(
          icon: FluentIcons.folder_horizontal,
          text: "Empty Folder",
          actionLabel: "New Item",
          onAction: () => _openAddDialog(node),
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
                            : "${child.pictures.length} Pictures",
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
      final Map<String, List<Picture>> grouped = {};
      for (var p in node.pictures) {
        final key = DateFormat('yyyy-MM-dd').format(p.date);
        if (!grouped.containsKey(key)) grouped[key] = [];
        grouped[key]!.add(p);
      }

      final sortedKeys = grouped.keys.toList()..sort();

      if (node.pictures.isEmpty) {
        content = _buildEmptyState(
          icon: FluentIcons.photo2,
          text: "Album has no pictures",
          actionLabel: "Import pictures",
          onAction: () {},
        );
      } else {
        content = ListView.builder(
          itemCount: sortedKeys.length,
          itemBuilder: (context, index) {
            final dateKey = sortedKeys.elementAt(index);
            final pictures = grouped[dateKey]!;

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
                        "(${pictures.length})",
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
                  itemCount: pictures.length,
                  itemBuilder: (c, i) {
                    final picture = pictures[i];
                    final isSelected = selectedPicture?.id == picture.id;
                    return GestureDetector(
                      onTap: () => _bloc.selectPicture(picture),
                      child: Container(
                        clipBehavior: Clip.antiAlias,
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
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              picture.url,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Icon(
                                    FluentIcons.error,
                                    color: Colors.red,
                                  ),
                                );
                              },
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return const Center(child: ProgressRing());
                                  },
                            ),
                            if (picture.status == PictureStatus.picked)
                              Positioned(
                                top: 4,
                                left: 4,
                                child: StatusIcon(
                                  icon: FluentIcons.heart_fill,
                                  color: Colors.red,
                                ),
                              ),
                            if (picture.status == PictureStatus.rejected)
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
                                color: Colors.black.withValues(alpha: 0.6),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 2,
                                ),
                                child: Text(
                                  picture.name,
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
    return ScaffoldPage(
      header: PageHeader(
        title: Text(node.name),
        commandBar: CommandBar(
          primaryItems: [
            CommandBarButton(
              icon: const Icon(FluentIcons.add),
              label: const Text('New'),
              onPressed: () => _openAddDialog(node),
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
          if (node.type == NodeType.album && selectedPicture != null)
            InspectorPanel(
              picture: selectedPicture,
              onClose: () => _bloc.selectPicture(null),
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
          Icon(icon, size: 64, color: Colors.grey.withValues(alpha: 0.3)),
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
      onPressed: () => _openAddDialog(parentNode),
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
            color: states.isHovered
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
