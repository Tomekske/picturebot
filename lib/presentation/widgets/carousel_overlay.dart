import 'package:fluent_ui/fluent_ui.dart';

/// Slideshow overlay which displays the total images
class CarouselOverlay extends StatelessWidget {
  /// Property which displays the text in the overlay
  final String text;

  /// Property which displays the [sharpness] in the overlay.
  int? sharpness;

  /// Property which displays the [isLiked] in the overlay.
  bool isLiked;

  /// Slideshow overlay which displays the total images
  CarouselOverlay({
    required this.text,
    this.sharpness,
    required this.isLiked,
  }) : super();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 50.0),
            child: isLiked
                ? Icon(FluentIcons.heart_fill)
                : Icon(FluentIcons.heart),
          ),
          Padding(
            padding: EdgeInsets.only(right: 50.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  text,
                  style: TextStyle(
                    color: Colors.white,
                    decoration: TextDecoration.none,
                    fontSize: 30.0,
                  ),
                ),
                if (sharpness != null) ...[
                  Text(
                    "$sharpness",
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.none,
                      fontSize: 20.0,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
