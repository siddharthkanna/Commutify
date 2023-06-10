import 'package:flutter/material.dart';
import './screens/auth/login.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MLRITPOOL',
      theme: ThemeData(fontFamily: 'Outfit'),
      home: const Scaffold(body: Login()),
    );
  }
}
