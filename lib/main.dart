import 'package:flutter/material.dart';
import 'package:simoni/add_participants.dart';
import 'package:simoni/add_reports.dart';
import 'package:simoni/add_task.dart';
import 'package:simoni/splash_screen.dart';
import 'package:simoni/home_screen.dart';
import 'package:simoni/task_list.dart';
import 'package:firebase_core/firebase_core.dart';

<<<<<<< HEAD
// Gunakan HANYA SATU fungsi main
void main() async { 
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
=======
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Firebase.initializeApp();
>>>>>>> ec23a19a2f70effda018e3c5e7462bb7b36d4843
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
<<<<<<< HEAD
      // Pastikan HANYA SATU 'home' dan menunjuk ke SplashScreen
      home: const SplashScreen(), 
=======
      home: const SplashScreen(),
      home: const LihatTugasScreen(),
>>>>>>> ec23a19a2f70effda018e3c5e7462bb7b36d4843
      debugShowCheckedModeBanner: false,
    );
  }
}