import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // <-- Import GoogleFonts
import 'package:cloud_firestore/cloud_firestore.dart'; // <-- Import Firestore
// (Anda mungkin perlu import UserModel jika Anda mengopernya, tapi untuk sekarang kita tidak membutuhkannya di sini)

class AddParticipantsScreen extends StatefulWidget {
  final List<Map<String, dynamic>> selectedParticipants;
  // Opsional: Anda bisa mengirim user yang login untuk memfilter dirinya sendiri
  // final UserModel currentUser; 

  const AddParticipantsScreen({
    Key? key, 
    required this.selectedParticipants,
    // this.currentUser,
  }) : super(key: key);

  @override
  State<AddParticipantsScreen> createState() => _AddParticipantsScreenState();
}

class _AddParticipantsScreenState extends State<AddParticipantsScreen> {
  late List<Map<String, dynamic>> _selectedParticipants;
  final TextEditingController _searchController = TextEditingController();

  // --- State untuk data dari Firestore ---
  List<Map<String, dynamic>> _allParticipantsCache = []; // Cache data asli
  List<Map<String, dynamic>> _filteredParticipants = []; // Untuk list yg tampil
  bool _isLoading = true; // Status loading
  // ------------------------------------

  // HAPUS data dummy:
  // final List<Map<String, dynamic>> _allParticipants = [ ... ];

  @override
  void initState() {
    super.initState();
    _selectedParticipants = List.from(widget.selectedParticipants);
    _filteredParticipants = []; // Mulai kosong saat loading
    _searchController.addListener(_onSearchChanged);
    _fetchParticipants(); // Panggil fungsi fetch data
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --- FUNGSI BARU: Ambil data 'users' dari Firestore ---
  Future<void> _fetchParticipants() async {
    try {
      QuerySnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          // Opsional: Filter hanya 'pegawai' jika 'admin' tidak boleh jadi peserta
          // .where('role', isEqualTo: 'pegawai') 
          .get();

      List<Map<String, dynamic>> users = [];
      for (var doc in userSnapshot.docs) {
        // Opsional: Jangan tambahkan diri sendiri ke daftar (jika currentUser di-pass)
        // if (widget.currentUser != null && doc.id == widget.currentUser.uid) {
        //   continue; 
        // }
        
        final data = doc.data() as Map<String, dynamic>;
        users.add({
          'id': doc.id, // Gunakan Doc ID dari Firestore
          'name': data['nama'] ?? 'Tanpa Nama',
          'role': data['jabatan'] ?? 'Tanpa Jabatan', // Gunakan 'jabatan' dari Firestore
          'avatar': data['avatarURL'] ?? 'https://i.pravatar.cc/150?img=1', // Gunakan 'avatarURL' (fallback ke default)
          'color': Colors.grey[400]!, // Anda bisa hapus 'color' jika tidak dipakai
        });
      }

      if (mounted) {
        setState(() {
          _allParticipantsCache = users; // Simpan di cache
          _filteredParticipants = users; // Tampilkan semua di awal
          _isLoading = false; // Selesai loading
        });
      }
    } catch (e) {
      if (mounted) {
         setState(() { _isLoading = false; }); // Selesai loading (gagal)
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Gagal memuat pegawai: $e'), backgroundColor: Colors.red),
         );
      }
    }
  }
  // --- AKHIR FUNGSI FETCH ---

  void _onSearchChanged() {
    setState(() {
      if (_searchController.text.isEmpty) {
        _filteredParticipants = _allParticipantsCache; // Gunakan cache
      } else {
        _filteredParticipants = _allParticipantsCache.where((participant) {
          // Cari berdasarkan nama
          return participant['name'].toString().toLowerCase().contains(
            _searchController.text.toLowerCase(),
          );
        }).toList();
      }
    });
  }

  bool _isSelected(Map<String, dynamic> participant) {
    return _selectedParticipants.any((p) => p['id'] == participant['id']);
  }

  void _toggleSelection(Map<String, dynamic> participant) {
    setState(() {
      if (_isSelected(participant)) {
        _selectedParticipants.removeWhere((p) => p['id'] == participant['id']);
      } else {
        _selectedParticipants.add(participant);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Semua Pegawai',
          style: GoogleFonts.poppins( // Terapkan GoogleFonts
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                style: GoogleFonts.poppins(), // Terapkan GoogleFonts
                decoration: InputDecoration(
                  hintText: 'Cari Pegawai',
                  hintStyle: GoogleFonts.poppins( // Terapkan GoogleFonts
                    color: Colors.grey.shade400,
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey.shade400,
                    size: 22,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),

          // --- GANTI ListView DENGAN LOGIKA LOADING ---
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF4DB6AC))) // Tampilkan loading
                : _filteredParticipants.isEmpty
                    ? Center( // Tampilkan jika hasil filter kosong
                        child: Text(
                          'Tidak ada pegawai ditemukan',
                          style: GoogleFonts.poppins( // Terapkan GoogleFonts
                            color: Colors.grey.shade500,
                            fontSize: 14,
                          ),
                        ),
                      )
                    : ListView.builder( // Tampilkan list jika data ada
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredParticipants.length,
                        itemBuilder: (context, index) {
                          final participant = _filteredParticipants[index];
                          final isSelected = _isSelected(participant);

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: InkWell(
                              onTap: () => _toggleSelection(participant),
                              borderRadius: BorderRadius.circular(12),
                              child: Row(
                                children: [
                                  // Avatar
                                  Stack(
                                    children: [
                                      CircleAvatar(
                                        radius: 24, // Sesuaikan ukuran
                                        backgroundImage: NetworkImage(
                                          participant['avatar'], // Gunakan URL dari data
                                        ),
                                        backgroundColor: Colors.grey.shade200,
                                      ),
                                      // ... (Logika online indicator Anda bisa tetap di sini) ...
                                      // if (index % 3 == 0) 
                                      //   Positioned(...)
                                    ],
                                  ),
                                  const SizedBox(width: 12),

                                  // Name and Role
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          participant['name'],
                                          style: GoogleFonts.poppins( // Terapkan GoogleFonts
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          participant['role'],
                                          style: GoogleFonts.poppins( // Terapkan GoogleFonts
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Checkbox (tetap sama)
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isSelected
                                          ? const Color(0xFF4DB6AC)
                                          : Colors.transparent,
                                      border: Border.all(
                                        color: isSelected
                                            ? const Color(0xFF4DB6AC)
                                            : Colors.grey.shade400,
                                        width: 2,
                                      ),
                                    ),
                                    child: isSelected
                                        ? const Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 16,
                                          )
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
          // --- AKHIR PERUBAHAN LISTVIEW ---

          // Bottom Button (tetap sama)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Selected count text
                if (_selectedParticipants.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      '${_selectedParticipants.length} peserta terpilih',
                      style: GoogleFonts.poppins( // Terapkan GoogleFonts
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ),

                // Simpan Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, _selectedParticipants);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4DB6AC),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Simpan',
                      style: GoogleFonts.poppins( // Terapkan GoogleFonts
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}