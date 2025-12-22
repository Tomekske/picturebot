import 'package:fluent_ui/fluent_ui.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  
  const SectionHeader({super.key, required this.title});
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
            fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
      ),
    );
  }
}