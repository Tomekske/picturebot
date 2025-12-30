import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:picturebot/presentation/dialogs/carousel_dialog.dart';
import '../../data/models/picture.dart';
import 'section_header.dart';
import 'info_row.dart';

class InspectorPanel extends StatefulWidget {
  final Picture picture;
  final List<Picture> siblingPictures;
  final VoidCallback onClose;

  const InspectorPanel({
    super.key,
    required this.picture,
    required this.siblingPictures,
    required this.onClose,
  });

  @override
  State<InspectorPanel> createState() => _InspectorPanelState();
}

class _InspectorPanelState extends State<InspectorPanel> {
  void _openFullScreenCarousel(BuildContext context) {
    final initialIndex = widget.siblingPictures.indexOf(widget.picture);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Focus(
          autofocus: true,
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: Colors.black.withValues(alpha: 0.9),
            child: CarouselDialog(
              pictures: widget.siblingPictures,
              initialIndex: initialIndex != -1 ? initialIndex : 0,
            ),
          ),
        );
      },
    );
  }

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
          _buildHeader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildPreviewImage(),
                const SizedBox(height: 12),
                _buildFileTitle(),
                const SizedBox(height: 24),

                FilledButton(
                  onPressed: () => _openFullScreenCarousel(context),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(FluentIcons.full_screen, size: 16),
                      SizedBox(width: 8),
                      Text("Full Screen"),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                const SectionHeader(title: "File Details"),
                InfoRow(label: "Index", value: widget.picture.index),
                InfoRow(label: "Type", value: widget.picture.type.name),

                const SizedBox(height: 16),
                const SectionHeader(title: "Location"),
                Text(
                  widget.picture.location,
                  style: FluentTheme.of(context).typography.caption,
                ),
              ],
            ),
          ),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: FluentTheme.of(context).resources.dividerStrokeColorDefault,
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
            onPressed: widget.onClose,
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewImage() {
    return Container(
      height: 180,
      color: Colors.black,
      child: Center(
        child: Image.file(
          File(widget.picture.location),
          fit: BoxFit.contain,
          errorBuilder: (ctx, err, stack) => const Icon(FluentIcons.error),
        ),
      ),
    );
  }

  Widget _buildFileTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.picture.fileName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(
          "${widget.picture.type} • ${widget.picture.extension}",
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: FluentTheme.of(context).resources.dividerStrokeColorDefault,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Button(child: const Text("Edit"), onPressed: () {}),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Button(
              child: Text("Delete", style: TextStyle(color: Colors.red)),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}
