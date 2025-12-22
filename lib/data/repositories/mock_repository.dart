import 'dart:math';
import '../models/photo.dart';
import '../models/hierarchy_node.dart';
import '../enums/node_type.dart';

class MockRepository {
  static List<Photo> generatePhotos(int count, String prefix) {
    final random = Random();

    return List.generate(count, (index) {
      final date = DateTime.now().subtract(Duration(days: random.nextInt(30)));
      return Photo(
        id: '${prefix}_$index',
        name: 'DSC_${1000 + index}.${"JPG"}',
        url: 'https://via.placeholder.com/300?text=Photo+${index + 1}',
        date: date,
        type: 'JPG',
        status: [
          'untagged',
          'picked',
          'untagged',
          'rejected',
        ][random.nextInt(4)],
        colorLabel: ['none', 'red', 'blue', 'none'][random.nextInt(4)],
        exif: {
          'Camera': 'Sony A6600',
          'Lens': 'Sony E 16-50mm F/3.5-5.6 PZ OSS II',
          'ISO': '100',
          'Aperture': 'f/2.8',
          'Shutter': '1/250',
          'Dimensions': '6000 x 4000',
          'Size': '24.5 MB',
        },
      );
    });
  }

  static HierarchyNode getInitialData() {
    return HierarchyNode(
      id: '1',
      name: 'Library',
      type: NodeType.folder,
      children: [
        HierarchyNode(
          id: '2',
          name: 'The United States',
          type: NodeType.folder,
          parentId: 1,
          children: [
            HierarchyNode(
              id: '3',
              name: 'California',
              type: NodeType.folder,
              parentId: 2,
              children: [
                HierarchyNode(
                  id: '4',
                  name: 'Los Angeles',
                  type: NodeType.album,
                  parentId: 3,
                  photos: generatePhotos(12, 'la'),
                ),
                HierarchyNode(
                  id: '5',
                  name: 'San Francisco',
                  type: NodeType.album,
                  parentId: 3,
                  photos: generatePhotos(8, 'sf'),
                ),
              ],
            ),
            HierarchyNode(
              id: '6',
              name: 'Florida',
              type: NodeType.folder,
              parentId: 2,
              children: [],
            ),
          ],
        ),
        HierarchyNode(
          id: '7',
          name: 'Belgium',
          type: NodeType.folder,
          parentId: 1,
          children: [],
        ),
      ],
    );
  }
}
