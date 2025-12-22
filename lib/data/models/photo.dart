class Photo {
  final String id;
  final String name;
  final String url; // In a real app, this would be a file path
  final DateTime date;
  final String type; // 'RAW', 'JPG'
  final String status; // 'picked', 'rejected', 'untagged'
  final String colorLabel; // 'red', 'blue', 'none'
  final Map<String, String> exif;

  Photo({
    required this.id,
    required this.name,
    required this.url,
    required this.date,
    required this.type,
    this.status = 'untagged',
    this.colorLabel = 'none',
    required this.exif,
  });
}