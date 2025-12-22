import 'package:fluent_ui/fluent_ui.dart';

class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  
  const InfoRow({super.key, required this.label, required this.value});
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}