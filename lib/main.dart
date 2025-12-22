import 'dart:math';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart'; // For Key handling

void main() {
  runApp(const PhotoOrganizerApp());
}

// --- DATA MODELS ---

enum NodeType { folder, album }

class Photo {
  final String id;
  final String name;
  final String url; // In a real app, this would be a file path
  final DateTime date;
  final String type; // 'RAW', 'JPG'
  final String status; // 'picked', 'rejected', 'untagged'
  final String colorLabel; // 'red', 'blue', 'none'
  final Map<String, String> exif;

  Photo({
    required this.id,
    required this.name,
    required this.url,
    required this.date,
    required this.type,
    this.status = 'untagged',
    this.colorLabel = 'none',
    required this.exif,
  });
}

class HierarchyNode {
  final String id;
  final String name;
  final NodeType type;
  final String? parentId;
  final List<HierarchyNode> children;
  final List<Photo> photos;

  HierarchyNode({
    required this.id,
    required this.name,
    required this.type,
    this.parentId,
    this.children = const [],
    this.photos = const [],
  });

  // Helper for immutability updates (simplified for prototype)
  HierarchyNode copyWith({
    String? name,
    List<HierarchyNode>? children,
    List<Photo>? photos,
  }) {
    return HierarchyNode(
      id: id,
      name: name ?? this.name,
      type: type,
      parentId: parentId,
      children: children ?? this.children,
      photos: photos ?? this.photos,
    );
  }
}

// --- MOCK DATA GENERATOR ---

List<Photo> generatePhotos(int count, String prefix) {
  final random = Random();
  final cameras = ['Sony A7IV', 'Canon R5', 'Nikon Z6'];
  final lenses = ['24-70mm f/2.8', '85mm f/1.4', '16-35mm f/4'];

  return List.generate(count, (index) {
    final date = DateTime.now().subtract(Duration(days: random.nextInt(30)));
    return Photo(
      id: '${prefix}_$index',
      name: 'DSC_${1000 + index}.${index % 3 == 0 ? "RAW" : "JPG"}',
      url: 'https://via.placeholder.com/300?text=Photo+${index + 1}',
      date: date,
      type: index % 3 == 0 ? 'RAW' : 'JPG',
      status: ['untagged', 'picked', 'untagged', 'rejected'][random.nextInt(4)],
      colorLabel: ['none', 'red', 'blue', 'none'][random.nextInt(4)],
      exif: {
        'Camera': cameras[index % 3],
        'Lens': lenses[index % 3],
        'ISO': '${(index + 1) * 100}',
        'Aperture': 'f/${(random.nextDouble() * 5 + 1.4).toStringAsFixed(1)}',
        'Shutter': '1/${random.nextInt(2000)}s',
        'Dimensions': '6000 x 4000',
        'Size': '24.5 MB',
      },
    );
  });
}

final initialData = HierarchyNode(
  id: 'root',
  name: 'Bibliotheek',
  type: NodeType.folder,
  children: [
    HierarchyNode(
      id: 'us',
      name: 'The United States',
      type: NodeType.folder,
      parentId: 'root',
      children: [
        HierarchyNode(
          id: 'ca',
          name: 'California',
          type: NodeType.folder,
          parentId: 'us',
          children: [
            HierarchyNode(
              id: 'la',
              name: 'Los Angeles Shoot',
              type: NodeType.album,
              parentId: 'ca',
              photos: generatePhotos(12, 'la'),
            ),
            HierarchyNode(
              id: 'sf',
              name: 'San Francisco Trip',
              type: NodeType.album,
              parentId: 'ca',
              photos: generatePhotos(8, 'sf'),
            ),
          ],
        ),
        HierarchyNode(
          id: 'ny',
          name: 'New York',
          type: NodeType.folder,
          parentId: 'us',
          children: [],
        ),
      ],
    ),
    HierarchyNode(
      id: 'be',
      name: 'Belgium',
      type: NodeType.folder,
      parentId: 'root',
      children: [],
    ),
  ],
);

// --- MAIN APP ---

class PhotoOrganizerApp extends StatefulWidget {
  const PhotoOrganizerApp({super.key});

  @override
  State<PhotoOrganizerApp> createState() => _PhotoOrganizerAppState();
}

class _PhotoOrganizerAppState extends State<PhotoOrganizerApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void toggleTheme() {
    setState(() {
      _themeMode =
      _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FluentApp(
      title: 'FotoPro v3.0',
      themeMode: _themeMode,
      theme: FluentThemeData(
        accentColor: Colors.blue,
        brightness: Brightness.light,
        visualDensity: VisualDensity.standard,
        scaffoldBackgroundColor: const Color(0xFFF3F3F3),
      ),
      darkTheme: FluentThemeData(
        accentColor: Colors.blue,
        brightness: Brightness.dark,
        visualDensity: VisualDensity.standard,
        scaffoldBackgroundColor: const Color(0xFF202020),
      ),
      home: DashboardPage(toggleTheme: toggleTheme, currentMode: _themeMode),
    );
  }
}

// --- DASHBOARD PAGE ---

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
  HierarchyNode rootNode = initialData;
  HierarchyNode? selectedNode;
  Photo? selectedPhoto; // For Inspector
  int topIndex = 0; // State for NavigationPane

  // Breadcrumb / Navigation Helper
  List<String> currentPath = ['root'];

  @override
  void initState() {
    super.initState();
    selectedNode = rootNode;
  }

  // --- LOGIC HELPERS ---

  HierarchyNode? findNode(HierarchyNode root, String id) {
    if (root.id == id) return root;
    for (final child in root.children) {
      final found = findNode(child, id);
      if (found != null) return found;
    }
    return null;
  }

  void selectNode(HierarchyNode node) {
    setState(() {
      selectedNode = node;
      selectedPhoto = null; // Deselect photo when changing folders
    });
  }

  void _addNode(String name, String type, String parentId) {
    // Note: In a real app, you would need to rebuild the tree structure here
    // since HierarchyNode is immutable-ish in this example.
    // For this prototype, we'll just print to console.
    print("Adding $name to $parentId (Logic needs immutable update implementation)");
  }

  // --- WIDGETS ---

  @override
  Widget build(BuildContext context) {
    // We define the custom layout here to pass it to the PaneItem body
    final Widget libraryContent = Row(
      children: [
        // CUSTOM SIDEBAR TREE
        Container(
          width: 300,
          decoration: BoxDecoration(
            color: FluentTheme.of(context).navigationPaneTheme.backgroundColor,
            border: Border(
              right: BorderSide(
                color:
                FluentTheme.of(context).resources.dividerStrokeColorDefault,
                width: 1,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text(
                  "MAPPEN",
                  style: FluentTheme.of(context).typography.caption?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: FluentTheme.of(context)
                        .resources
                        .textFillColorSecondary,
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: TreeView(
                      root: rootNode,
                      onSelect: selectNode,
                      selectedId: selectedNode?.id),
                ),
              ),
              // Storage indicator
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                      top: BorderSide(
                          color: FluentTheme.of(context)
                              .resources
                              .dividerStrokeColorDefault)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Opslag: 24% Vrij",
                        style: TextStyle(fontSize: 12)),
                    const SizedBox(height: 8),
                    ProgressBar(value: 76.0),
                  ],
                ),
              )
            ],
          ),
        ),

        // MAIN CONTENT AREA
        Expanded(
          child: ScaffoldPage(
            header: PageHeader(
              title: Text(selectedNode?.name ?? "Bibliotheek"),
              commandBar: CommandBar(
                primaryItems: [
                  CommandBarButton(
                    icon: const Icon(FluentIcons.add),
                    label: const Text('Nieuw'),
                    onPressed: () => showAddDialog(context),
                  ),
                  CommandBarButton(
                    icon: const Icon(FluentIcons.filter),
                    label: const Text('Filters'),
                    onPressed: () {},
                  ),
                  CommandBarButton(
                    icon: const Icon(FluentIcons.delete),
                    label: const Text('Verwijderen'),
                    onPressed: () => showDeleteDialog(context),
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
                    child: _buildMainContent(),
                  ),
                ),
                // INSPECTOR PANEL
                if (selectedNode?.type == NodeType.album &&
                    selectedPhoto != null)
                  InspectorPanel(
                    photo: selectedPhoto!,
                    onClose: () => setState(() => selectedPhoto = null),
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
          'FotoPro v3.0',
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
        size: const NavigationPaneSize(openWidth: 200), // Adjusted size since we have a second sidebar
        items: [
          PaneItem(
            icon: const Icon(FluentIcons.library),
            title: const Text("Bibliotheek"),
            body: libraryContent, // <--- Correct placement
          ),
        ],
        footerItems: [
          PaneItem(
            icon: const Icon(FluentIcons.settings),
            title: const Text("Instellingen"),
            body: const Center(child: Text("Instellingen Pagina")),
            onTap: () => showSettingsDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    if (selectedNode == null) return const SizedBox.shrink();

    // CASE: FOLDER VIEW
    if (selectedNode!.type == NodeType.folder) {
      if (selectedNode!.children.isEmpty) {
        return _buildEmptyState(
          icon: FluentIcons.folder_horizontal,
          text: "Deze map is leeg",
          actionLabel: "Nieuw Item",
          onAction: () => showAddDialog(context),
        );
      }

      return GridView.builder(
        itemCount: selectedNode!.children.length + 1, // +1 for Add button
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200,
          mainAxisExtent: 180,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemBuilder: (ctx, index) {
          if (index == selectedNode!.children.length) {
            return _buildAddItemCard();
          }
          final child = selectedNode!.children[index];
          return HoverButton(
            onPressed: () => selectNode(child),
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
                          : "${child.photos.length} foto's",
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
    for (var p in selectedNode!.photos) {
      final key = "${p.date.day}-${p.date.month}-${p.date.year}";
      if (!grouped.containsKey(key)) grouped[key] = [];
      grouped[key]!.add(p);
    }

    if (selectedNode!.photos.isEmpty) {
      return _buildEmptyState(
        icon: FluentIcons.photo2,
        text: "Geen foto's in dit album",
        actionLabel: "Foto's importeren",
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
                        color: FluentTheme.of(context)
                            .resources
                            .textFillColorSecondary),
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
                  onTap: () {
                    setState(() {
                      selectedPhoto = photo;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: FluentTheme.of(context)
                          .resources
                          .cardBackgroundFillColorDefault,
                      border: isSelected
                          ? Border.all(
                          color: FluentTheme.of(context).accentColor,
                          width: 2)
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
                              child: _StatusIcon(
                                  icon: FluentIcons.heart_fill,
                                  color: Colors.red)),
                        if (photo.status == 'rejected')
                          const Positioned(
                              top: 4,
                              left: 4,
                              child: _StatusIcon(
                                  icon: FluentIcons.cancel,
                                  color: Colors.grey)),
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
                                  color: Colors.white, fontSize: 10),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            )
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(
      {required IconData icon,
        required String text,
        required String actionLabel,
        required VoidCallback onAction}) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: Colors.grey.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(text, style: const TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 16),
          FilledButton(onPressed: onAction, child: Text(actionLabel))
        ],
      ),
    );
  }

  Widget _buildAddItemCard() {
    return HoverButton(
      onPressed: () => showAddDialog(context),
      builder: (p0, states) {
        return Container(
          decoration: BoxDecoration(
            border: Border.all(
              color:
              FluentTheme.of(context).resources.dividerStrokeColorDefault,
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
                  color: FluentTheme.of(context)
                      .resources
                      .solidBackgroundFillColorBase,
                ),
                child: const Icon(FluentIcons.add),
              ),
              const SizedBox(height: 8),
              const Text("Nieuw Item"),
            ],
          ),
        );
      },
    );
  }

  // --- DIALOGS ---

  void showAddDialog(BuildContext context) async {
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
                _addNode(nameController.text, type, selectedNode?.id ?? 'root');
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void showDeleteDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) {
        return ContentDialog(
          title: const Text('Verwijderen'),
          content: Text(
              'Weet je zeker dat je "${selectedNode?.name}" wilt verwijderen?'),
          actions: [
            Button(
                child: const Text('Annuleren'),
                onPressed: () => Navigator.pop(context)),
            FilledButton(
              style: ButtonStyle(backgroundColor: ButtonState.all(Colors.red)),
              child: const Text('Verwijderen'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  void showSettingsDialog(BuildContext context) async {
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

// --- SUB-WIDGETS ---

class TreeView extends StatelessWidget {
  final HierarchyNode root;
  final Function(HierarchyNode) onSelect;
  final String? selectedId;

  const TreeView(
      {super.key,
        required this.root,
        required this.onSelect,
        this.selectedId});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...root.children.map((child) => _buildNode(child, 0, context)),
      ],
    );
  }

  Widget _buildNode(HierarchyNode node, int depth, BuildContext context) {
    final isSelected = node.id == selectedId;
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
          ...node.children
              .map((child) => _buildNode(child, depth + 1, context)),
      ],
    );
  }
}

class InspectorPanel extends StatelessWidget {
  final Photo photo;
  final VoidCallback onClose;

  const InspectorPanel({super.key, required this.photo, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: FluentTheme.of(context).navigationPaneTheme.backgroundColor,
        border: Border(
            left: BorderSide(
                color: FluentTheme.of(context).resources.dividerStrokeColorDefault)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(
                      color: FluentTheme.of(context)
                          .resources
                          .dividerStrokeColorDefault)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Informatie",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                IconButton(
                    icon: const Icon(FluentIcons.chrome_close),
                    onPressed: onClose),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Preview
                Container(
                  height: 180,
                  color: Colors.black,
                  child: const Center(
                    child:
                    Icon(FluentIcons.photo2, size: 48, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 12),
                Text(photo.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                Text("${photo.type} • ${photo.exif['Size']}",
                    style: const TextStyle(color: Colors.grey)),

                const SizedBox(height: 24),

                FilledButton(
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(FluentIcons.full_screen, size: 16),
                      SizedBox(width: 8),
                      Text("Volledig Scherm"),
                    ],
                  ),
                  onPressed: () {
                    // Launch lightbox logic
                  },
                ),

                const SizedBox(height: 24),

                // EXIF
                const _SectionHeader(title: "GEGEVENS"),
                _InfoRow(
                    label: "Datum",
                    value:
                    "${photo.date.day}/${photo.date.month}/${photo.date.year}"),

                const SizedBox(height: 16),
                const _SectionHeader(title: "CAMERA"),
                _InfoRow(label: "Toestel", value: photo.exif['Camera'] ?? '-'),
                _InfoRow(label: "Lens", value: photo.exif['Lens'] ?? '-'),

                const SizedBox(height: 16),
                const _SectionHeader(title: "INSTELLINGEN"),
                Row(
                  children: [
                    Expanded(
                        child: _InfoRow(
                            label: "ISO", value: photo.exif['ISO'] ?? '-')),
                    Expanded(
                        child: _InfoRow(
                            label: "Diafragma",
                            value: photo.exif['Aperture'] ?? '-')),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                        child: _InfoRow(
                            label: "Sluitertijd",
                            value: photo.exif['Shutter'] ?? '-')),
                    Expanded(
                        child: _InfoRow(
                            label: "Resolutie",
                            value: photo.exif['Dimensions'] ?? '-')),
                  ],
                ),
              ],
            ),
          ),
          // Footer Actions
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border(
                  top: BorderSide(
                      color: FluentTheme.of(context)
                          .resources
                          .dividerStrokeColorDefault)),
            ),
            child: Row(
              children: [
                Expanded(
                    child: Button(
                        child: const Text("Bewerken"), onPressed: () {})),
                const SizedBox(width: 8),
                Expanded(
                    child: Button(
                        child:  Text("Verwijderen",
                            style: TextStyle(color: Colors.red)),
                        onPressed: () {})),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
            fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _StatusIcon({required this.icon, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.black, blurRadius: 4)],
      ),
      child: Icon(icon, size: 12, color: color),
    );
  }
}