import 'package:fluent_ui/fluent_ui.dart';
import '../../data/models/photo.dart';
import 'section_header.dart';
import 'info_row.dart';

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
                const SectionHeader(title: "GEGEVENS"),
                InfoRow(
                    label: "Datum",
                    value:
                    "${photo.date.day}/${photo.date.month}/${photo.date.year}"),

                const SizedBox(height: 16),
                const SectionHeader(title: "CAMERA"),
                InfoRow(label: "Toestel", value: photo.exif['Camera'] ?? '-'),
                InfoRow(label: "Lens", value: photo.exif['Lens'] ?? '-'),

                const SizedBox(height: 16),
                const SectionHeader(title: "INSTELLINGEN"),
                Row(
                  children: [
                    Expanded(
                        child: InfoRow(
                            label: "ISO", value: photo.exif['ISO'] ?? '-')),
                    Expanded(
                        child: InfoRow(
                            label: "Diafragma",
                            value: photo.exif['Aperture'] ?? '-')),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                        child: InfoRow(
                            label: "Sluitertijd",
                            value: photo.exif['Shutter'] ?? '-')),
                    Expanded(
                        child: InfoRow(
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