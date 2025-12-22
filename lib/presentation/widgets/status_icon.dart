import 'package:fluent_ui/fluent_ui.dart';

class StatusIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  
  const StatusIcon({super.key, required this.icon, required this.color});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.black, blurRadius: 4)],
      ),
      child: Icon(icon, size: 12, color: color),
    );
  }
}