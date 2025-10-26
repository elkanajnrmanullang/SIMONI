import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String nama;
  final String email;
  final String jabatan;
  final String role;

  UserModel({
    required this.uid,
    required this.nama,
    required this.email,
    required this.jabatan,
    required this.role,
  });

  // Factory constructor untuk membuat UserModel dari DocumentSnapshot
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      nama: data['nama'] ?? 'Tanpa Nama',
      email: data['email'] ?? '',
      jabatan: data['jabatan'] ?? 'Tanpa Jabatan',
      role: data['role'] ?? 'pegawai', // Default role 'pegawai'
    );
  }
}