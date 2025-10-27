import 'package:flutter/material.dart';
import 'package:simoni/splash_screen.dart';
import 'package:simoni/home_screen.dart';
<<<<<<< HEAD
=======
import 'package:firebase_core/firebase_core.dart';

void main() async { // <-- Ubah jadi 'async'
  // --- TAMBAHKAN 2 BARIS INI ---
  WidgetsFlutterBinding.ensureInitialized();
  // Inisialisasi manual untuk Android (karena kita tidak pakai FlutterFire CLI)
  await Firebase.initializeApp(); 
  // ---------------------------
>>>>>>> d03e3472e82d79bf4acad355e7d17fc5aa6a78d8

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SIMONI App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
