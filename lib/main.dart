import 'package:bltool/config.dart';
import 'package:bltool/homeView.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> requestPermissions() async {
  await [Permission.storage, Permission.manageExternalStorage].request();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Config.instance.init();
  await requestPermissions();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'bilitool',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: HomeView(), //
    );
  }
}
