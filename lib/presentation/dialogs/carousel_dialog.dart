import 'dart:io';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import '../../data/models/picture.dart';
import '../widgets/carousel_overlay.dart';

class CarouselDialog extends StatefulWidget {
  final List<Picture> pictures;
  final int initialIndex;

  const CarouselDialog({
    super.key,
    required this.pictures,
    this.initialIndex = 0,
  });

  @override
  State<CarouselDialog> createState() => _CarouselDialogState();
}

class _CarouselDialogState extends State<CarouselDialog> {
  late PageController _controller;
  late int _currentIndex;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _controller = PageController(initialPage: _currentIndex);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _navigate(int direction) {
    int nextIndex = _currentIndex + direction;

    if (nextIndex >= widget.pictures.length) {
      nextIndex = 0;
    } else if (nextIndex < 0) {
      nextIndex = widget.pictures.length - 1;
    }

    _controller.animateToPage(
      nextIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      final key = event.logicalKey;

      if (key == LogicalKeyboardKey.arrowLeft ||
          key == LogicalKeyboardKey.keyA) {
        _navigate(-1);
      } else if (key == LogicalKeyboardKey.arrowRight ||
          key == LogicalKeyboardKey.keyD) {
        _navigate(1);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Stack(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(color: Colors.transparent),
          ),

          PageView.builder(
            controller: _controller,
            itemCount: widget.pictures.length,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemBuilder: (context, index) {
              return InteractiveViewer(
                child: GestureDetector(
                  onTap: () {},
                  child: Image.file(
                    File(widget.pictures[index].location),
                    fit: BoxFit.contain,
                  ),
                ),
              );
            },
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: CarouselOverlay(
              text: "${_currentIndex + 1}/${widget.pictures.length}",
              isLiked: false,
            ),
          ),

          _buildNavArrows(),
        ],
      ),
    );
  }

  Widget _buildNavArrows() {
    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _navButton(FluentIcons.chevron_left, () => _navigate(-1)),
            _navButton(FluentIcons.chevron_right, () => _navigate(1)),
          ],
        ),
      ),
    );
  }

  Widget _navButton(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, size: 24, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }
}
