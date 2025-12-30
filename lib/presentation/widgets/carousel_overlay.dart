import 'package:fluent_ui/fluent_ui.dart';

class CarouselOverlay extends StatelessWidget {
  final String text;
  final VoidCallback onClose;

  const CarouselOverlay({
    super.key,
    required this.text,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black.withValues(alpha: 0.7), Colors.transparent],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HoverButton(
            onPressed: onClose,
            builder: (context, states) {
              return Row(
                children: [
                  Icon(
                    FluentIcons.chrome_close,
                    color: Colors.white,
                    size: states.isHovered ? 18 : 16,
                  ),
                ],
              );
            },
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Text(
                    text,
                    style: const TextStyle(color: Colors.white, fontSize: 28.0),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
