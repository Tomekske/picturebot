import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
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
                  child: Center(
                    // UPDATED: Use Image.file
                    child: Image.file(
                      File(picture.location),
                      fit: BoxFit.contain,
                      errorBuilder: (ctx, err, stack) =>
                          const Icon(FluentIcons.error),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  picture.fileName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  "${picture.type} • ${picture.extension}",
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
                    // TODO: Implement Fullscreen with Image.file
                  },
                ),

                const SizedBox(height: 24),

                const SectionHeader(title: "File Details"),
                InfoRow(
                  label: "Index",
                  value: picture.index,
                ),

                InfoRow(
                  label: "Type",
                  value: picture.type.name,
                ),

                const SizedBox(height: 16),
                const SectionHeader(title: "Location"),
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    picture.location,
                    style: FluentTheme.of(context).typography.caption,
                  ),
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
                    onPressed: () {
                      // TODO
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Button(
                    child: Text(
                      "Delete",
                      style: TextStyle(color: Colors.red),
                    ),
                    onPressed: () {
                      // TODO
                    },
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
