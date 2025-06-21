import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';

import '../widget/gallery.dart';

class HomePage extends StatelessWidget {
  HomePage() : super();

  final pictures = [
    "M:\\Pictures\\Taiwan\\Taipei\\Longshan Temple 09-11-2023\\Longshan_Temple_00001.jpg",
    "M:\\Pictures\\Taiwan\\Taipei\\Longshan Temple 09-11-2023\\Longshan_Temple_00017.jpg",
    "M:\\Pictures\\Taiwan\\Taipei\\Longshan Temple 09-11-2023\\Longshan_Temple_00025.jpg",
    "M:\\Pictures\\Taiwan\\Taipei\\Longshan Temple 09-11-2023\\Longshan_Temple_00051.jpg",
    "M:\\Pictures\\Taiwan\\Taipei\\Longshan Temple 09-11-2023\\Longshan_Temple_00103.jpg",
    "M:\\Pictures\\Taiwan\\Taipei\\Longshan Temple 09-11-2023\\Longshan_Temple_00112.jpg",
    "M:\\Pictures\\Taiwan\\Taipei\\Longshan Temple 09-11-2023\\Longshan_Temple_00129.jpg",
    "M:\\Pictures\\Taiwan\\Taipei\\Longshan Temple 09-11-2023\\Longshan_Temple_00130.jpg",
    "M:\\Pictures\\Taiwan\\Taipei\\Longshan Temple 09-11-2023\\Longshan_Temple_00164.jpg",
    "M:\\Pictures\\Taiwan\\Taipei\\Longshan Temple 09-11-2023\\Longshan_Temple_00170.jpg",
    "M:\\Pictures\\Taiwan\\Taipei\\Longshan Temple 09-11-2023\\Longshan_Temple_00175.jpg",
    "M:\\Pictures\\Taiwan\\Taipei\\Longshan Temple 09-11-2023\\Longshan_Temple_00178.jpg",
  ];

  @override
  Widget build(BuildContext context) {
    return Gallery(pictures: pictures);
  }
}
