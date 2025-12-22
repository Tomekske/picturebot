import 'package:fluent_ui/fluent_ui.dart';
import 'package:intl/intl.dart';
import '../../data/models/picture.dart';
import 'section_header.dart';
import 'info_row.dart';

class InspectorPanel extends StatelessWidget {
  final Picture picture;
  final VoidCallback onClose;

  const InspectorPanel({
    super.key,
    required this.picture,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: FluentTheme.of(context).navigationPaneTheme.backgroundColor,
        border: Border(
          left: BorderSide(
            color: FluentTheme.of(context).resources.dividerStrokeColorDefault,
          ),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: FluentTheme.of(
                    context,
                  ).resources.dividerStrokeColorDefault,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Information",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(FluentIcons.chrome_close),
                  onPressed: onClose,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  height: 180,
                  color: Colors.black,
                  child: const Center(
                    child: Icon(
                      FluentIcons.photo2,
                      size: 48,
                      color: Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  picture.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  "${picture.type} • ${picture.exif.size}",
                  style: const TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 24),

                FilledButton(
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(FluentIcons.full_screen, size: 16),
                      SizedBox(width: 8),
                      Text("Full Screen"),
                    ],
                  ),
                  onPressed: () {
                    // Launch lightbox logic
                  },
                ),

                const SizedBox(height: 24),

                // EXIF
                const SectionHeader(title: "Information"),
                InfoRow(
                  label: "Date",
                  value: DateFormat('yyyy-MM-dd').format(picture.date),
                ),

                InfoRow(
                  label: "Time",
                  value: DateFormat('HH:mm').format(picture.date),
                ),

                const SizedBox(height: 16),
                const SectionHeader(title: "CAMERA"),
                InfoRow(label: "Model", value: picture.exif.camera ?? '-'),
                InfoRow(label: "Lens", value: picture.exif.lens ?? '-'),

                const SizedBox(height: 16),
                const SectionHeader(title: "SETTINGS"),
                Row(
                  children: [
                    Expanded(
                      child: InfoRow(
                        label: "ISO",
                        value: picture.exif.iso ?? '-',
                      ),
                    ),
                    Expanded(
                      child: InfoRow(
                        label: "Aperture",
                        value: picture.exif.aperture ?? '-',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: InfoRow(
                        label: "Shutter",
                        value: picture.exif.shutter ?? '-',
                      ),
                    ),
                    Expanded(
                      child: InfoRow(
                        label: "Dimensions",
                        value: picture.exif.dimensions ?? '-',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: FluentTheme.of(
                    context,
                  ).resources.dividerStrokeColorDefault,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Button(
                    child: const Text("Edit"),
                    onPressed: () {},
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Button(
                    child: Text(
                      "Delete",
                      style: TextStyle(color: Colors.red),
                    ),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
