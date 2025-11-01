import 'package:flutter/material.dart';
import 'package:simoni/splash_screen.dart';
import 'package:simoni/home_screen.dart';
import 'package:simoni/task_list.dart';
import 'package:firebase_core/firebase_core.dart';

// Gunakan HANYA SATU fungsi main
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

// HANYA SATU definisi class MyApp
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SIMONI App',
      theme: ThemeData(primarySwatch: Colors.blue),

      home: const SplashScreen(),

      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
