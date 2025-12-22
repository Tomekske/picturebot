import 'dart:math';
import '../models/photo.dart';
import '../models/hierarchy_node.dart';
import '../enums/node_type.dart';

class MockRepository {
  static List<Photo> generatePhotos(int count, String prefix) {
    final random = Random();
    final cameras = ['Sony A7IV', 'Canon R5', 'Nikon Z6'];
    final lenses = ['24-70mm f/2.8', '85mm f/1.4', '16-35mm f/4'];

    return List.generate(count, (index) {
      final date = DateTime.now().subtract(Duration(days: random.nextInt(30)));
      return Photo(
        id: '${prefix}_$index',
        name: 'DSC_${1000 + index}.${index % 3 == 0 ? "RAW" : "JPG"}',
        url: 'https://via.placeholder.com/300?text=Photo+${index + 1}',
        date: date,
        type: index % 3 == 0 ? 'RAW' : 'JPG',
        status: ['untagged', 'picked', 'untagged', 'rejected'][random.nextInt(4)],
        colorLabel: ['none', 'red', 'blue', 'none'][random.nextInt(4)],
        exif: {
          'Camera': cameras[index % 3],
          'Lens': lenses[index % 3],
          'ISO': '${(index + 1) * 100}',
          'Aperture': 'f/${(random.nextDouble() * 5 + 1.4).toStringAsFixed(1)}',
          'Shutter': '1/${random.nextInt(2000)}s',
          'Dimensions': '6000 x 4000',
          'Size': '24.5 MB',
        },
      );
    });
  }

  static HierarchyNode getInitialData() {
    return HierarchyNode(
      id: 'root',
      name: 'Bibliotheek',
      type: NodeType.folder,
      children: [
        HierarchyNode(
          id: 'us',
          name: 'The United States',
          type: NodeType.folder,
          parentId: 'root',
          children: [
            HierarchyNode(
              id: 'ca',
              name: 'California',
              type: NodeType.folder,
              parentId: 'us',
              children: [
                HierarchyNode(
                  id: 'la',
                  name: 'Los Angeles Shoot',
                  type: NodeType.album,
                  parentId: 'ca',
                  photos: generatePhotos(12, 'la'),
                ),
                HierarchyNode(
                  id: 'sf',
                  name: 'San Francisco Trip',
                  type: NodeType.album,
                  parentId: 'ca',
                  photos: generatePhotos(8, 'sf'),
                ),
              ],
            ),
            HierarchyNode(
              id: 'ny',
              name: 'New York',
              type: NodeType.folder,
              parentId: 'us',
              children: [],
            ),
          ],
        ),
        HierarchyNode(
          id: 'be',
          name: 'Belgium',
          type: NodeType.folder,
          parentId: 'root',
          children: [],
        ),
      ],
    );
  }
}