import 'package:flutter/material.dart';
import 'package:simoni/add_participants.dart';
import 'package:simoni/add_reports.dart';
import 'package:simoni/add_task.dart';
import 'package:simoni/splash_screen.dart';
import 'package:simoni/home_screen.dart';
import 'package:simoni/task_list.dart';
import 'package:firebase_core/firebase_core.dart';

// Gunakan HANYA SATU fungsi main yang menginisialisasi Firebase
void main() async { // <-- Pastikan async
  // Pastikan binding siap
  WidgetsFlutterBinding.ensureInitialized();
  // Inisialisasi Firebase
  await Firebase.initializeApp();
  // Jalankan aplikasi
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
      // Pastikan HANYA SATU argumen home dan menunjuk ke SplashScreen
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}