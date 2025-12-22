import 'package:fluent_ui/fluent_ui.dart';
import '../../data/models/hierarchy_node.dart';
import '../../logic/bloc/dashboard_bloc.dart';
import '../../data/models/photo.dart';
import '../../data/enums/node_type.dart';
import '../widgets/album_tree_view.dart';
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

        final Widget libraryContent = Row(
          children: [
            Container(
              width: 300,
              decoration: BoxDecoration(
                color: FluentTheme.of(
                  context,
                ).navigationPaneTheme.backgroundColor,
                border: Border(
                  right: BorderSide(
                    color: FluentTheme.of(
                      context,
                    ).resources.dividerStrokeColorDefault,
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Text(
                      "MAPPEN",
                      style: FluentTheme.of(context).typography.caption
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: FluentTheme.of(
                              context,
                            ).resources.textFillColorSecondary,
                          ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: AlbumTreeView(
                        root: _bloc.rootNode,
                        onSelect: _bloc.selectNode,
                        selectedId: selectedNode?.id,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // MAIN CONTENT AREA
            Expanded(
              child: ScaffoldPage(
                header: PageHeader(
                  title: Text(selectedNode?.name ?? "Library"),
                  commandBar: CommandBar(
                    primaryItems: [
                      CommandBarButton(
                        icon: const Icon(FluentIcons.add),
                        label: const Text('New'),
                        onPressed: () => AppDialogs.showAddDialog(context, (
                          name,
                          type,
                        ) {
                          _bloc.addNode(name, type, selectedNode?.id ?? 'root');
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
                          selectedNode?.name ?? "Item",
                          () {}, // Delete logic
                        ),
                      ),
                    ],
                  ),
                ),
                content: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // THE GRID
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: _buildMainContent(selectedNode, selectedPhoto),
                      ),
                    ),
                    // INSPECTOR PANEL
                    if (selectedNode?.type == NodeType.album &&
                        selectedPhoto != null)
                      InspectorPanel(
                        photo: selectedPhoto,
                        onClose: () => _bloc.selectPhoto(null),
                      ),
                  ],
                ),
              ),
            ),
          ],
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
            selected: topIndex,
            onChanged: (index) => setState(() => topIndex = index),
            displayMode: PaneDisplayMode.open,
            size: const NavigationPaneSize(openWidth: 200),
            items: [
              PaneItem(
                icon: const Icon(FluentIcons.library),
                title: const Text("Library"),
                body: libraryContent,
              ),
            ],
            footerItems: [
              PaneItem(
                icon: const Icon(FluentIcons.settings),
                title: const Text("Settings"),
                body: const Center(child: Text("TODO")),
                onTap: () => AppDialogs.showSettingsDialog(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMainContent(HierarchyNode? selectedNode, Photo? selectedPhoto) {
    if (selectedNode == null) return const SizedBox.shrink();

    // CASE: FOLDER VIEW
    if (selectedNode.type == NodeType.folder) {
      if (selectedNode.children.isEmpty) {
        return _buildEmptyState(
          icon: FluentIcons.folder_horizontal,
          text: "Empty Folder",
          actionLabel: "New Item",
          onAction: () => AppDialogs.showAddDialog(context, (name, type) {
            _bloc.addNode(name, type, selectedNode.id);
          }),
        );
      }

      return GridView.builder(
        itemCount: selectedNode.children.length + 1, // +1 for Add button
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200,
          mainAxisExtent: 180,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemBuilder: (ctx, index) {
          if (index == selectedNode.children.length) {
            return _buildAddItemCard();
          }
          final child = selectedNode.children[index];
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

    // CASE: ALBUM VIEW (Grouped by Date)
    final Map<String, List<Photo>> grouped = {};
    for (var p in selectedNode.photos) {
      final key = "${p.date.day}-${p.date.month}-${p.date.year}";
      if (!grouped.containsKey(key)) grouped[key] = [];
      grouped[key]!.add(p);
    }

    if (selectedNode.photos.isEmpty) {
      return _buildEmptyState(
        icon: FluentIcons.photo2,
        text: "Albums has no pictures",
        actionLabel: "Import pictures",
        onAction: () {},
      );
    }

    return ListView.builder(
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

  Widget _buildAddItemCard() {
    return HoverButton(
      onPressed: () => AppDialogs.showAddDialog(context, (name, type) {
        final selectedNode = _bloc.selectedNode;
        _bloc.addNode(name, type, selectedNode?.id ?? 'root');
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
