import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';

class Gallery extends StatelessWidget {
  Gallery({super.key, required this.pictures});

  final List<String> pictures;

  @override
  Widget build(BuildContext context) {
    final scrollController = ScrollController(initialScrollOffset: 0);

    return Column(
      children: [
        Expanded(
          child: GridView.builder(
            controller: scrollController,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 3 / 2,
              crossAxisSpacing: 3,
              mainAxisSpacing: 2,
            ),
            itemCount: pictures.length,
            itemBuilder: (context, index) {
              final picture = pictures[index];

              return Image.file(
                File(picture),
                isAntiAlias: true,
                filterQuality: FilterQuality.high,
              );
            },
          ),
        ),
      ],
    );
  }
}
