import 'dart:math';
import 'package:picturebot/data/enums/picture_status.dart';
import 'package:picturebot/data/models/exif.dart';

import '../enums/color_label.dart';
import '../enums/picture_type.dart';
import '../models/picture.dart';
import '../models/hierarchy_node.dart';
import '../enums/node_type.dart';

class MockRepository {
  static List<Picture> generatePhotos(int count, String prefix) {
    final random = Random();

    return List.generate(count, (index) {
      final date = DateTime.now().subtract(Duration(days: random.nextInt(30)));
      return Picture(
        id: '${prefix}_$index',
        name: 'DSC_${1000 + index}.JPG',
        url: 'https://via.placeholder.com/300?text=Photo+${index + 1}',
        date: date,
        type: PictureType.jpg,
        status: PictureStatus.untagged,
        colorLabel: ColorLabel.none,
        exif: Exif(
          camera: 'Sony A6600',
          lens: 'Sony E 16-50mm F/3.5-5.6 PZ OSS II',
          iso: '100',
          aperture: 'f/2.8',
          shutter: '1/250',
          dimensions: '6000 x 4000',
          size: '24.5 MB',
        ),
      );
    });
  }

  static HierarchyNode getInitialData() {
    return HierarchyNode(
      id: 1,
      name: 'Library',
      type: NodeType.folder,
      children: [
        HierarchyNode(
          id: 2,
          name: 'The United States',
          type: NodeType.folder,
          parentId: 1,
          children: [
            HierarchyNode(
              id: 3,
              name: 'California',
              type: NodeType.folder,
              parentId: 2,
              children: [
                HierarchyNode(
                  id: 4,
                  name: 'Los Angeles',
                  type: NodeType.album,
                  parentId: 3,
                  pictures: generatePhotos(12, 'la'),
                ),
                HierarchyNode(
                  id: 5,
                  name: 'San Francisco',
                  type: NodeType.album,
                  parentId: 3,
                  pictures: generatePhotos(8, 'sf'),
                ),
              ],
            ),
            HierarchyNode(
              id: 6,
              name: 'Florida',
              type: NodeType.folder,
              parentId: 2,
              children: [],
            ),
          ],
        ),
        HierarchyNode(
          id: 7,
          name: 'Belgium',
          type: NodeType.folder,
          parentId: 1,
          children: [],
        ),
      ],
    );
  }
}
