import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:simoni/all_reports.dart';
import 'package:simoni/task_list.dart';
import 'package:simoni/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // <-- Import sudah ada

enum TaskStatus { completed, pending, cancelled, inProgress }

class HomeScreen extends StatelessWidget {
  final UserModel user;
  const HomeScreen({super.key, required this.user});

  final Color primaryColor = const Color(0xFF00D1C1);
  final Color darkBlue = const Color(0xFF1F2937);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 0,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24.0),
                    _Header(userName: user.nama),
                    const SizedBox(height: 24.0),
                    const _SearchBar(),
                    const SizedBox(height: 32.0),
                    const _TaskSummaryHeader(),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: _TaskSummaryCards(),
              ),
              const SizedBox(height: 32.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: _ActionButtons(
                  primaryColor: primaryColor,
                  darkBlue: darkBlue,
                  user: user,
                ),
              ),
              const SizedBox(height: 32.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: _PerformanceSimpleSection(darkBlue: darkBlue),
              ),
              const SizedBox(height: 32.0),
              const _BestEmployeesSection(), // <-- Argumen darkBlue/primaryColor sudah dihapus sebelumnya
              const SizedBox(height: 32.0),
              // PERBAIKAN 1: Panggil _AllTasksSection TANPA darkBlue
              const _AllTasksSection(), // <-- HAPUS argumen darkBlue dari sini
              const SizedBox(height: 24.0),
            ],
          ),
        ),
      ),
    );
  }
}

// ... Widget _Header, _SearchBar, _TaskSummaryHeader, _TaskSummaryCards ...
// ... Kode widget ini tetap sama ...
class _Header extends StatelessWidget {
  final String userName;
  const _Header({required this.userName});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF00D1C1);
    const Color darkBlue = Color(0xFF1F2937);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Halo!',
              style: GoogleFonts.poppins(
                fontSize: 16.0,
                color: Colors.grey[600],
              ),
            ),
            Text(
              userName,
              style: GoogleFonts.poppins(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: darkBlue,
              ),
            ),
          ],
        ),
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: primaryColor, width: 2.0),
            image: const DecorationImage(
              image: AssetImage('assets/images/profile_avatar.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Align(
            alignment: Alignment.topRight,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: primaryColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    const Color darkBlue = Color(0xFF1F2937);
    return Container(
      height: 56.0,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Cari',
          hintStyle: GoogleFonts.poppins(
            fontSize: 16.0,
            color: Colors.grey[500],
          ),
          prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16.0),
        ),
        style: GoogleFonts.poppins(fontSize: 16.0, color: darkBlue),
      ),
    );
  }
}

class _TaskSummaryHeader extends StatefulWidget {
  const _TaskSummaryHeader();

  @override
  State<_TaskSummaryHeader> createState() => _TaskSummaryHeaderState();
}

class _TaskSummaryHeaderState extends State<_TaskSummaryHeader> {
  String _formattedDate = '';

  @override
  void initState() {
    super.initState();
    _loadDate();
  }

  Future<void> _loadDate() async {
    await initializeDateFormatting('id_ID', null);
    if (mounted) {
      setState(() {
        _formattedDate = DateFormat(
          'd MMMM yyyy',
          'id_ID',
        ).format(DateTime.now());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color darkBlue = Color(0xFF1F2937);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Hari Ini',
          style: GoogleFonts.poppins(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            color: darkBlue,
          ),
        ),
        Row(
          children: [
            Icon(Icons.calendar_today, size: 16.0, color: Colors.grey[600]),
            const SizedBox(width: 8.0),
            Text(
              _formattedDate,
              style: GoogleFonts.poppins(
                fontSize: 14.0,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Di dalam home_screen.dart

// --- UBAH DARI StatelessWidget MENJADI StatefulWidget ---
class _TaskSummaryCards extends StatefulWidget {
  const _TaskSummaryCards({Key? key}) : super(key: key); // Tambahkan Key

  @override
  State<_TaskSummaryCards> createState() => _TaskSummaryCardsState();
}

class _TaskSummaryCardsState extends State<_TaskSummaryCards> {
  // Map untuk menyimpan jumlah tugas per status
  Map<String, int> taskCounts = {
    'berjalan': 0,
    'tertunda': 0,
    'selesai': 0,
    'dibatalkan': 0,
  };

  @override
  Widget build(BuildContext context) {
    // --- GUNAKAN STREAMBUILDER UNTUK MENGAMBIL SEMUA TUGAS ---
    return StreamBuilder<QuerySnapshot>(
      // Query: Ambil semua dokumen dari koleksi 'tugas'
      // PERHATIAN: Ini mengambil SEMUA tugas. Jika Anda ingin memfilter
      // hanya untuk user tertentu, tambahkan .where() di sini.
      // Contoh: .where('pembuatID', isEqualTo: widget.user.uid)
      //     atau .where('pesertaIDs', arrayContains: widget.user.uid)
      stream: FirebaseFirestore.instance.collection('tugas').snapshots(),
      builder: (context, snapshot) {
        // Handle Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Tampilkan kartu dengan loading indicator atau angka 0
          return _buildLoadingCards(); // Fungsi helper untuk loading state
        }
        // Handle Error
        if (snapshot.hasError) {
          // Tampilkan kartu dengan pesan error
          return _buildErrorCards(); // Fungsi helper untuk error state
        }
        // Handle No Data
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          // Tampilkan kartu dengan angka 0
          return _buildGridWithCounts(
            berjalan: 0,
            tertunda: 0,
            selesai: 0,
            dibatalkan: 0,
          );
        }

        // --- Data Tersedia -> Hitung Jumlah per Status ---
        final taskDocs = snapshot.data!.docs;
        // Reset hitungan sebelum menghitung ulang
        taskCounts = {
          'berjalan': 0,
          'tertunda': 0,
          'selesai': 0,
          'dibatalkan': 0,
        };

        for (var doc in taskDocs) {
          final data = doc.data() as Map<String, dynamic>;
          final status = (data['status'] as String?)?.toLowerCase(); // Ambil status, handle null

          // Tingkatkan hitungan berdasarkan status
          if (status == 'berjalan') {
            taskCounts['berjalan'] = (taskCounts['berjalan'] ?? 0) + 1;
          } else if (status == 'tertunda') {
            taskCounts['tertunda'] = (taskCounts['tertunda'] ?? 0) + 1;
          } else if (status == 'selesai') {
            taskCounts['selesai'] = (taskCounts['selesai'] ?? 0) + 1;
          } else if (status == 'dibatalkan') {
            taskCounts['dibatalkan'] = (taskCounts['dibatalkan'] ?? 0) + 1;
          }
          // Abaikan status lain jika ada
        }

        // --- Tampilkan GridView dengan hitungan yang sudah diupdate ---
        return _buildGridWithCounts(
          berjalan: taskCounts['berjalan'] ?? 0,
          tertunda: taskCounts['tertunda'] ?? 0,
          selesai: taskCounts['selesai'] ?? 0,
          dibatalkan: taskCounts['dibatalkan'] ?? 0,
        );
      },
    );
  }

  // --- Fungsi Helper untuk Membangun GridView ---
  Widget _buildGridWithCounts({
    required int berjalan,
    required int tertunda,
    required int selesai,
    required int dibatalkan,
  }) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16.0,
      mainAxisSpacing: 16.0,
      childAspectRatio: 1.7,
      children: [
        _buildSummaryCard(
          backgroundColor: const Color(0xFF01314A),
          icon: Icons.pending_actions_outlined,
          iconColor: Colors.white,
          title: 'Sedang Berjalan',
          count: berjalan, // <-- Gunakan data hitungan
          textColor: Colors.white,
        ),
        _buildSummaryCard(
          backgroundColor: const Color(0xFF95D925),
          icon: Icons.assignment_late_outlined,
          iconColor: Colors.black,
          title: 'Tertunda',
          count: tertunda, // <-- Gunakan data hitungan
          textColor: Colors.black,
        ),
        _buildSummaryCard(
          backgroundColor: const Color(0xFF8CC2FF),
          icon: Icons.history_toggle_off_outlined,
          iconColor: Colors.black,
          title: 'Selesai',
          count: selesai, // <-- Gunakan data hitungan
          textColor: Colors.black,
        ),
        _buildSummaryCard(
          backgroundColor: const Color(0xFFFE8180),
          icon: Icons.unpublished_outlined,
          iconColor: Colors.black,
          title: 'Dibatalkan',
          count: dibatalkan, // <-- Gunakan data hitungan
          textColor: Colors.black,
        ),
      ],
    );
  }

  // --- Fungsi Helper untuk Loading State (Opsional) ---
  Widget _buildLoadingCards() {
    // Tampilkan GridView dengan angka 0 atau indikator loading
    return _buildGridWithCounts(berjalan: 0, tertunda: 0, selesai: 0, dibatalkan: 0);
    // Atau bisa juga:
    // return const Center(child: CircularProgressIndicator());
  }

  // --- Fungsi Helper untuk Error State (Opsional) ---
   Widget _buildErrorCards() {
    // Tampilkan GridView dengan angka 0 atau pesan error
    return _buildGridWithCounts(berjalan: 0, tertunda: 0, selesai: 0, dibatalkan: 0);
    // Atau tampilkan pesan error:
    // return const Center(child: Text("Gagal memuat ringkasan tugas"));
  }


  // --- Fungsi _buildSummaryCard tetap sama ---
  Widget _buildSummaryCard({
    required Color backgroundColor,
    required IconData icon,
    required Color iconColor,
    required String title,
    required int count,
    required Color textColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16.0),
      ),
      padding: const EdgeInsets.all(14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Icon(icon, color: iconColor, size: 28.0),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14.0,
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$count Tugas', // <-- Angka akan dinamis
                style: GoogleFonts.poppins(fontSize: 12.0, color: textColor),
              ),
            ],
          ),
        ],
      ),
    );
  }
} // <-- Tutup class _TaskSummaryCardsState

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({required this.primaryColor, required this.darkBlue, required this.user});

  final UserModel user;
  final Color primaryColor;
  final Color darkBlue;

  @override
  Widget build(BuildContext context) {
    const Color iconColor = Color(0xFF43A895);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildActionButton(
          context: context,
          icon: Icons.task_alt_outlined,
          title: 'Tugas',
          iconColor: iconColor,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LihatTugasScreen(user: user)),
            );
          },
        ),
        const SizedBox(width: 16.0),
        _buildActionButton(
          context: context,
          icon: Icons.snippet_folder_outlined,
          title: 'Laporan',
          iconColor: iconColor,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AllReportsPage(user: user)),
            );
          },
        ),
        const SizedBox(width: 16.0),
        _buildActionButton(
          context: context,
          icon: Icons.assignment_outlined,
          title: 'Presensi',
          iconColor: iconColor,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(16.0),
          onTap: onTap,
          child: Container(
            height: 100.0,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(width: 1, color: const Color(0xFFD3D3D3)),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(134, 134, 134, 0.1),
                  spreadRadius: 0,
                  blurRadius: 19.83,
                  offset: Offset(0, 2.48),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: iconColor, size: 32.0),
                const SizedBox(height: 8.0),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    color: darkBlue,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PerformanceSimpleSection extends StatelessWidget {
  const _PerformanceSimpleSection({required this.darkBlue});

  final Color darkBlue;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 145,
      padding: const EdgeInsets.fromLTRB(25, 15, 25, 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13.0),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(
                Icons.star_rounded,
                color: Color(0xFF43A895),
                size: 24.0,
              ),
              const SizedBox(width: 8.0),
              Text(
                'Performa Terbaik',
                style: GoogleFonts.poppins(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: darkBlue,
                ),
              ),
            ],
          ),
          Text(
            '5',
            style: GoogleFonts.poppins(
              fontSize: 38.0,
              fontWeight: FontWeight.bold,
              color: darkBlue,
              height: 1.0,
            ),
          ),
          Text(
            'Diapresiasi atas kontribusi dan kinerja luar biasa bulan ini',
            style: GoogleFonts.poppins(fontSize: 14.0, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

class _BestEmployeesSection extends StatefulWidget {
  const _BestEmployeesSection({Key? key}) : super(key: key);

  @override
  State<_BestEmployeesSection> createState() => _BestEmployeesSectionState();
}

class _BestEmployeesSectionState extends State<_BestEmployeesSection> {
  final Color darkBlue = const Color(0xFF1F2937);
  final Color primaryColor = const Color(0xFF00D1C1);
  final Color titleColor = const Color(0xFF1F2937);
  final Color employeeNameColorTop = Colors.grey[600]!;
  final Color employeeNameColorRanked = const Color(0xFF1F2937);
  final Color scoreColor = const Color(0xFF1F2937);
  final Color roleColor = Colors.grey[600]!;

  Future<List<Map<String, dynamic>>> _fetchTopEmployees() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    final completedTasksSnapshot = await FirebaseFirestore.instance
        .collection('tugas')
        .where('status', isEqualTo: 'selesai')
        .where('tanggalSelesai', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .where('tanggalSelesai', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
        .get();

    final Map<String, int> taskCounts = {};
    for (var doc in completedTasksSnapshot.docs) {
      final data = doc.data();
      if (data.containsKey('pembuatID')) {
        final userId = data['pembuatID'] as String;
        taskCounts[userId] = (taskCounts[userId] ?? 0) + 1;
      }
    }

    final sortedUsers = taskCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topUserIds = sortedUsers.take(5).map((entry) => entry.key).toList();
    final topUserScores = sortedUsers.take(5).map((entry) => entry.value).toList();

    List<Map<String, dynamic>> topEmployeesData = [];
    for (int i = 0; i < topUserIds.length; i++) {
      final userId = topUserIds[i];
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data()!;
        topEmployeesData.add({
          'rank': i + 1,
          'name': userData['nama'] ?? 'Tanpa Nama',
          'role': userData['jabatan'] ?? 'Tanpa Jabatan',
          'avatarPath': userData['avatarURL'] ?? 'assets/images/profile_avatar.png',
          'score': topUserScores[i],
        });
      }
    }
    return topEmployeesData;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchTopEmployees(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Belum ada data pegawai terbaik bulan ini.'));
        }

        final topEmployees = snapshot.data!;
        final top3 = topEmployees.take(3).toList();
        final rank4 = topEmployees.length > 3 ? topEmployees[3] : null;
        final rank5 = topEmployees.length > 4 ? topEmployees[4] : null;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 25, 20, 25),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(17.0),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.1),
                spreadRadius: 0,
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding( // <-- PERBAIKAN 3 SUDAH DITERAPKAN DI SINI
                padding: const EdgeInsets.only(left: 5.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.leaderboard_outlined,
                      color: primaryColor,
                      size: 28.0,
                    ),
                    const SizedBox(width: 12.0),
                    Text(
                      'Pegawai Terbaik Bulan Ini',
                      style: GoogleFonts.poppins(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: titleColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (top3.length > 1)
                    _buildTopEmployee(
                      rank: top3[1]['rank'],
                      avatarPath: top3[1]['avatarPath'],
                      name: top3[1]['name'],
                      score: top3[1]['score'],
                      nameColor: employeeNameColorTop,
                      scoreColor: scoreColor,
                    ),
                  if (top3.isNotEmpty)
                    _buildTopEmployee(
                      rank: top3[0]['rank'],
                      avatarPath: top3[0]['avatarPath'],
                      name: top3[0]['name'],
                      score: top3[0]['score'],
                      isCenter: true,
                      nameColor: employeeNameColorTop,
                      scoreColor: scoreColor,
                    ),
                  if (top3.length > 2)
                    _buildTopEmployee(
                      rank: top3[2]['rank'],
                      avatarPath: top3[2]['avatarPath'],
                      name: top3[2]['name'],
                      score: top3[2]['score'],
                      nameColor: employeeNameColorTop,
                      scoreColor: scoreColor,
                    ),
                ],
              ),
              const SizedBox(height: 28.0),
              if (rank4 != null)
                _buildRankedEmployeeTile(
                  rank: rank4['rank'],
                  avatarPath: rank4['avatarPath'],
                  name: rank4['name'],
                  role: rank4['role'],
                  score: rank4['score'],
                  nameColor: employeeNameColorRanked,
                  roleColor: roleColor,
                  scoreColor: scoreColor,
                ),
              if (rank4 != null) const SizedBox(height: 12.0),
              if (rank5 != null)
                _buildRankedEmployeeTile(
                  rank: rank5['rank'],
                  avatarPath: rank5['avatarPath'],
                  name: rank5['name'],
                  role: rank5['role'],
                  score: rank5['score'],
                  nameColor: employeeNameColorRanked,
                  roleColor: roleColor,
                  scoreColor: scoreColor,
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopEmployee({
    required int rank,
    required String avatarPath,
    required String name,
    required int score,
    required Color nameColor,
    required Color scoreColor,
    bool isCenter = false,
  }) {
    final double avatarSize = isCenter ? 80.0 : 64.0;
    final bool isNetworkImage = avatarPath.startsWith('http');
    return Column(
      children: [
        SizedBox(
          width: avatarSize,
          height: avatarSize,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: avatarSize / 2,
                backgroundImage: isNetworkImage
                    ? NetworkImage(avatarPath) as ImageProvider
                    : AssetImage(avatarPath),
                backgroundColor: Colors.grey[200],
              ),
              Positioned(
                bottom: -8,
                left: 0,
                right: 0,
                child: _buildRankBadge(rank: rank, isTop: true),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16.0),
        Text(
          name,
          style: GoogleFonts.poppins(
            fontSize: 14.0,
            fontWeight: FontWeight.w600,
            color: nameColor,
          ),
        ),
        const SizedBox(height: 4.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.star, color: Color(0xFFFACC15), size: 16.0),
            const SizedBox(width: 4.0),
            Text(
              score.toString(),
              style: GoogleFonts.poppins(
                fontSize: 14.0,
                fontWeight: FontWeight.w600,
                color: scoreColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRankedEmployeeTile({
    required int rank,
    required String avatarPath,
    required String name,
    required String role,
    required int score,
    required Color nameColor,
    required Color roleColor,
    required Color scoreColor,
  }) {
    final bool isNetworkImage = avatarPath.startsWith('http');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 3,
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: isNetworkImage
                      ? NetworkImage(avatarPath) as ImageProvider
                      : AssetImage(avatarPath),
                  backgroundColor: Colors.grey[200],
                ),
                Positioned(
                  bottom: -4,
                  right: -4,
                  child: _buildRankBadge(rank: rank),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: GoogleFonts.poppins(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                  color: nameColor,
                ),
              ),
              Text(
                role,
                style: GoogleFonts.poppins(fontSize: 12.0, color: roleColor),
              ),
            ],
          ),
          const Spacer(),
          const Icon(Icons.star, color: Color(0xFFFACC15), size: 16.0),
          const SizedBox(width: 4.0),
          Text(
            score.toString(),
            style: GoogleFonts.poppins(
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
              color: scoreColor,
            ),
          ),
        ],
      ),
    );
  }

  // PERBAIKAN 4: return ditambahkan
  Widget _buildRankBadge({required int rank, bool isTop = false}) {
    Color badgeColor;
    Widget child;
    final Color darkBlue = const Color(0xFF1F2937);

    switch (rank) {
      case 1:
        badgeColor = const Color(0xFFFACC15);
        child = const Icon(
          Icons.workspace_premium_rounded,
          color: Colors.white,
          size: 16,
        );
        break;
      case 2:
        badgeColor = const Color(0xFF4ADE80);
        child = Text(
          '$rank',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        );
        break;
      case 3:
        badgeColor = const Color(0xFFF79090);
        child = Text(
          '$rank',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        );
        break;
      default:
        badgeColor = const Color(0xFF90D0F7);
        child = Text(
          '$rank',
          style: GoogleFonts.poppins(
            color: darkBlue,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        );
    }

    return Container(
      width: isTop ? 28 : 20,
      height: isTop ? 28 : 20,
      decoration: BoxDecoration(
        color: badgeColor,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2.0),
      ),
      child: Center(child: child),
    );
  }
} // <<-- Tutup class _BestEmployeesSectionState

// --- Widget _AllTasksSection DIREVISI ---
class _AllTasksSection extends StatefulWidget {
  const _AllTasksSection({Key? key}) : super(key: key);

  @override
  State<_AllTasksSection> createState() => _AllTasksSectionState();
}

class _AllTasksSectionState extends State<_AllTasksSection> {
  final Color darkBlue = const Color(0xFF1F2937);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(width: 0.5, color: Color(0xFFD3D3D3))),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          const SizedBox(height: 24.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Semua Tugas',
                style: GoogleFonts.poppins(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: darkBlue,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => const LihatTugasScreen()),
                  // );
                },
                child: Text(
                  'Lihat Semua',
                  style: GoogleFonts.poppins(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[500],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('tugas')
                .limit(4)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('Belum ada tugas.'));
              }

              final taskDocs = snapshot.data!.docs;

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: taskDocs.length,
                itemBuilder: (context, index) {
                  final taskData = taskDocs[index].data() as Map<String, dynamic>;
                  final taskId = taskDocs[index].id;

                  return _buildTaskTile(
                    statusString: taskData['status'] ?? 'pending',
                    title: taskData['judul'] ?? 'Tanpa Judul',
                    time: _formatTaskTime(taskData['tanggalTarget']),
                    participantIds: List<String>.from(taskData['pesertaIDs'] ?? []),
                  );
                },
                separatorBuilder: (context, index) => const SizedBox(height: 5.0),
              );
            },
          ),
          const SizedBox(height: 24.0),
        ],
      ),
    );
  }

  Widget _buildTaskTile({
    required String statusString,
    required String title,
    required String time,
    required List<String> participantIds,
  }) {
    TaskStatus status = TaskStatus.pending;
    switch (statusString.toLowerCase()) {
      case 'selesai': status = TaskStatus.completed; break;
      case 'tertunda': status = TaskStatus.pending; break;
      case 'dibatalkan': status = TaskStatus.cancelled; break;
      case 'berjalan': status = TaskStatus.inProgress; break;
    }

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Colors.grey[200]!),
         boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 3,
          ),
        ],
       ),
      child: Row(
        children: [
          _getTaskIcon(status),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                    color: darkBlue, // <-- Gunakan darkBlue dari State
                   ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  time,
                  style: GoogleFonts.poppins(
                     fontSize: 14.0,
                     color: Colors.grey[600],
                   ),
                ),
              ],
            ),
          ),
          _buildStackedAvatars(participantIds),
        ],
      ),
    );
  }

  String _formatTaskTime(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return DateFormat('dd MMM, HH:mm', 'id_ID').format(timestamp.toDate());
    }
    return '--:--';
  }

  // PERBAIKAN 2: Kembalikan logika switch ke _getTaskIcon
  Widget _getTaskIcon(TaskStatus status) {
    IconData icon;
    Color color;
    switch (status) {
      case TaskStatus.completed:
        icon = Icons.check_circle_rounded;
        color = const Color(0xFF4ADE80);
        break;
      case TaskStatus.pending:
        icon = Icons.refresh_rounded;
        color = const Color(0xFF90D0F7);
        break;
      case TaskStatus.cancelled:
        icon = Icons.cancel_rounded;
        color = const Color(0xFFF79090);
        break;
      case TaskStatus.inProgress:
        icon = Icons.access_time_filled_rounded;
        color = Colors.grey;
        break;
    }
    return Icon(icon, color: color, size: 28.0);
  }

  Widget _buildStackedAvatars(List<String> participantIds) {
    int count = participantIds.length;
    if (count == 0) return const SizedBox.shrink();

    return Container(
       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
       decoration: BoxDecoration(
         color: Colors.grey[200],
         borderRadius: BorderRadius.circular(12),
       ),
       child: Text(
         '$count Peserta',
         style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[700]),
       ),
    );
  }
} // <<-- Tutup class _AllTasksSectionState