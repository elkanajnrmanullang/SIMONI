import 'package:flutter/material.dart';
import 'package:simoni/splash_screen.dart';
import 'package:simoni/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async { // <-- Ubah jadi 'async'
  // --- TAMBAHKAN 2 BARIS INI ---
  WidgetsFlutterBinding.ensureInitialized();
  // Inisialisasi manual untuk Android (karena kita tidak pakai FlutterFire CLI)
  await Firebase.initializeApp(); 
  // ---------------------------


  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SIMONI App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
