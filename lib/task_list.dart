import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // <-- Pastikan import
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart'; // <-- Pastikan import
import 'package:simoni/add_task.dart';
import 'package:simoni/models/user_model.dart'; // <-- Import UserModel
import 'package:cloud_firestore/cloud_firestore.dart'; // <-- Import Firestore

class LihatTugasScreen extends StatefulWidget {
  final UserModel user; // <-- Menerima data user
  const LihatTugasScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<LihatTugasScreen> createState() => _LihatTugasScreenState();
}

class _LihatTugasScreenState extends State<LihatTugasScreen> {
  // --- PERBAIKAN 1: Tambahkan ScrollController & state kalender ---
  final ScrollController _scrollController = ScrollController();
  late DateTime _calendarStartDate;
  final int _totalCalendarDays = 365 * 5; // Tampilkan 5 tahun (2 lalu, 3 depan)
  // -----------------------------------------------------------

  DateTime _selectedDate = DateTime.now();
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  int _taskCountToday = 0; // State untuk jumlah tugas di AppBar

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null); // Inisialisasi locale

    // --- PERBAIKAN 2: Inisialisasi tanggal awal kalender ---
    final DateTime today = DateUtils.dateOnly(DateTime.now());
    // Mulai 2 tahun yang lalu dari 1 Januari
    _calendarStartDate = DateTime(today.year - 2, 1, 1);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedDate(animate: false); // Langsung lompat ke hari ini
    });
    // ----------------------------------------------------
  }

  // --- PERBAIKAN 3: Tambahkan dispose controller ---
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  // ----------------------------------------------

  // --- Fungsi Kalender ---

  // --- PERBAIKAN 4: Hapus _getWeekDays() karena tidak dipakai ---
  // List<DateTime> _getWeekDays() { ... }
  // ---------------------------------------------------------

  // --- PERBAIKAN 5: Tambahkan fungsi scroll-ke-tengah ---
  void _scrollToSelectedDate({bool animate = true}) {
    if (!_scrollController.hasClients) return;

    // 1. Hitung index tanggal yang dipilih
    final DateTime targetDate = DateUtils.dateOnly(_selectedDate);

    // Pastikan tanggal target ada dalam jangkauan
    if (targetDate.isBefore(_calendarStartDate)) {
      _scrollController.jumpTo(0); // Scroll ke paling awal
      return;
    }

    final int selectedIndex = targetDate.difference(_calendarStartDate).inDays;
    if (selectedIndex < 0) {
      _scrollController.jumpTo(0);
      return;
    }

    // 2. Tentukan ukuran item (lebar 48 + padding horizontal 4*2 = 8)
    const double itemWidth = 48.0 + 8.0;

    // 3. Dapatkan lebar layar
    final double screenWidth = MediaQuery.of(context).size.width;

    // 4. Hitung offset untuk menempatkan item di tengah
    double offset = (selectedIndex * itemWidth) - (screenWidth / 2) + (itemWidth / 2);

    // 5. Batasi offset
    final double maxScroll = _scrollController.position.maxScrollExtent;
    if (offset < 0) {
      offset = 0;
    } else if (offset > maxScroll) {
      offset = maxScroll;
    }

    // 6. Lakukan scrolling
    if (animate) {
      _scrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _scrollController.jumpTo(offset);
    }
  }
  // --- AKHIR FUNGSI BARU ---

  String _getDayName(DateTime date) {
    // Gunakan DateFormat untuk nama hari Indonesia
    return DateFormat('E', 'id_ID').format(date);
  }

  void _previousMonth() {
    setState(() {
      // Logika yang benar untuk pindah bulan & tanggal
      DateTime newDate = DateTime(_selectedYear, _selectedMonth - 1, _selectedDate.day);
      int maxDay = DateUtils.getDaysInMonth(newDate.year, newDate.month);
      if (newDate.day > maxDay) {
        _selectedDate = DateTime(newDate.year, newDate.month, maxDay);
      } else {
        _selectedDate = newDate;
      }
      _selectedMonth = _selectedDate.month;
      _selectedYear = _selectedDate.year;
    });
    // --- PERBAIKAN 6: Panggil scroll ---
    _scrollToSelectedDate();
    // ----------------------------------
  }

  void _nextMonth() {
    setState(() {
      // Logika yang benar untuk pindah bulan & tanggal
      DateTime newDate = DateTime(_selectedYear, _selectedMonth + 1, _selectedDate.day);
      int maxDay = DateUtils.getDaysInMonth(newDate.year, newDate.month);
      if (newDate.day > maxDay) {
        _selectedDate = DateTime(newDate.year, newDate.month, maxDay);
      } else {
        _selectedDate = newDate;
      }
      _selectedMonth = _selectedDate.month;
      _selectedYear = _selectedDate.year;
    });
    // --- PERBAIKAN 7: Panggil scroll ---
    _scrollToSelectedDate();
    // ----------------------------------
  }

  String _getMonthName(int month) {
    // Gunakan DateFormat untuk nama bulan Indonesia
    return DateFormat('MMMM', 'id_ID').format(DateTime(_selectedYear, month));
  }
  // --- Akhir Fungsi Kalender ---

  // --- Fungsi Stream Query Firestore ---
  Stream<QuerySnapshot> _buildTaskStream() {
    final startOfDay = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, 0, 0, 0);
    final endOfDay = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, 23, 59, 59);

    Query query = FirebaseFirestore.instance.collection('tugas');

    // Filter berdasarkan tanggal
    query = query
        .where('tanggalTarget', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('tanggalTarget', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay));

    // Filter berdasarkan user (hanya pembuat)
    query = query.where('pembuatID', isEqualTo: widget.user.uid);
    // TODO: Ganti query ini jika ingin menampilkan tugas 'peserta' juga

    // Urutkan berdasarkan waktu mulai
    query = query.orderBy('tanggalTarget', descending: false);

    return query.snapshots();
  }
  // --- Akhir Fungsi Stream Query ---

  // --- Fungsi Format Waktu ---
  String _formatTaskStartTime(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return DateFormat('HH:mm').format(timestamp.toDate());
    }
    return '--:--';
  }

  String _formatTaskDuration(dynamic startTimestamp, dynamic endTimestamp) {
    if (startTimestamp is Timestamp && endTimestamp is Timestamp) {
      final start = startTimestamp.toDate();
      final end = endTimestamp.toDate();
      if (DateUtils.isSameDay(start, end)) {
        return '${DateFormat('HH:mm').format(start)} - ${DateFormat('HH:mm').format(end)}';
      } else {
        return '${DateFormat('dd/MM HH:mm', 'id_ID').format(start)} - ${DateFormat('dd/MM HH:mm', 'id_ID').format(end)}';
      }
    }
    if (startTimestamp is Timestamp) {
      return DateFormat('HH:mm').format(startTimestamp.toDate());
    }
    return '--:--';
  }
  // --- Akhir Fungsi Format Waktu ---

  // --- FUNGSI BARU: Update Status Tugas di Firestore ---
  Future<void> _updateTaskStatus(String taskId, String newStatus) async {
    try {
      Map<String, dynamic> dataToUpdate = {
        'status': newStatus,
      };

      if (newStatus == 'selesai') {
        dataToUpdate['tanggalSelesai'] = Timestamp.now();
      }

      await FirebaseFirestore.instance
          .collection('tugas')
          .doc(taskId)
          .update(dataToUpdate);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status tugas diperbarui menjadi: $newStatus'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memperbarui status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  // --- AKHIR FUNGSI BARU ---

  // --- FUNGSI BARU: Tampilkan Menu Pilihan Status ---
  void _showStatusMenu(String taskId, String currentStatus) {
    const List<String> statuses = ['selesai', 'berjalan', 'tertunda', 'dibatalkan'];
    const List<String> displayNames = ['Selesai', 'Sedang Dikerjakan', 'Tertunda', 'Dibatalkan'];
    const List<IconData> icons = [
      Icons.check_circle_rounded,
      Icons.access_time_filled_rounded,
      Icons.refresh_rounded,
      Icons.cancel_rounded,
    ];
    const List<Color> colors = [
      Color(0xFF4ADE80), // Selesai
      Colors.grey, // Berjalan
      Color(0xFF90D0F7), // Tertunda
      Color(0xFFF79090), // Dibatalkan
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  'Ubah Status Tugas',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ...List.generate(statuses.length, (index) {
                final status = statuses[index];
                final isSelected = (status == currentStatus);

                return ListTile(
                  leading: Icon(icons[index], color: colors[index]),
                  title: Text(
                    displayNames[index],
                    style: GoogleFonts.poppins(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? const Color(0xFF4DB6AC) : Colors.black87,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check, color: Color(0xFF4DB6AC))
                      : null,
                  onTap: () {
                    if (!isSelected) {
                      _updateTaskStatus(taskId, status); // Kirim ke Firestore
                    }
                    Navigator.pop(context); // Tutup bottom sheet
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }
  // --- AKHIR FUNGSI BARU ---

  @override
  Widget build(BuildContext context) {
    // final weekDays = _getWeekDays(); // <-- TIDAK DIPAKAI LAGI
    final appBarDate = DateFormat('d MMMM', 'id_ID').format(_selectedDate);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              appBarDate,
              style: GoogleFonts.poppins(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '$_taskCountToday tugas hari ini',
              style: GoogleFonts.poppins(
                color: Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Calendar Month Selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.chevron_left, size: 28, color: Colors.grey[700]),
                  onPressed: _previousMonth, // <-- Selalu bisa mundur
                ),
                Text(
                  '${_getMonthName(_selectedMonth)} $_selectedYear',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.chevron_right, size: 28, color: Colors.grey[700]),
                  onPressed: _nextMonth,
                ),
              ],
            ),
          ),

          // --- PERBAIKAN 8: Ganti Row kalender jadi ListView.builder ---
          Container(
            height: 90, // Beri tinggi tetap untuk list
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: _totalCalendarDays,
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              itemBuilder: (context, index) {
                // Hitung tanggal berdasarkan index
                final DateTime date = _calendarStartDate.add(Duration(days: index));
                
                final dayName = _getDayName(date);
                final dayNumber = date.day;
                final isSelected = DateUtils.isSameDay(date, _selectedDate);
                
                // Tidak ada lagi 'isPast' check untuk disabling
                
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0), // Spasi antar item
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDate = date;
                        _selectedMonth = date.month;
                        _selectedYear = date.year;
                      });
                      _scrollToSelectedDate(); // Panggil scroll saat di-tap
                    },
                    child: Container(
                      width: 48, // Lebar item
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF4DB6AC) : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            dayName,
                            style: GoogleFonts.poppins(
                              color: isSelected ? Colors.white : Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            dayNumber.toString(),
                            style: GoogleFonts.poppins(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(height: 6), // Placeholder
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // --- AKHIR PERBAIKAN 8 ---

          const SizedBox(height: 16),

          // Task List (StreamBuilder)
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _buildTaskStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF4DB6AC)));
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Gagal memuat tugas.', style: TextStyle(color: Colors.red)));
                }

                final taskDocs = snapshot.data?.docs ?? [];
                final currentTaskCount = taskDocs.length;

                if (_taskCountToday != currentTaskCount) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() { _taskCountToday = currentTaskCount; });
                    }
                  });
                }

                if (taskDocs.isEmpty) {
                  return Center(
                      child: Text(
                        'Tidak ada tugas pada tanggal ini.',
                        style: GoogleFonts.poppins(color: Colors.grey),
                      )
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 80.0),
                  itemCount: taskDocs.length,
                  itemBuilder: (context, index) {
                    final taskData = taskDocs[index].data() as Map<String, dynamic>;
                    final String taskId = taskDocs[index].id; // <-- Ambil ID Dokumen

                    return _buildTaskCard(
                      taskId: taskId, // <-- Kirim ID Tugas
                      jam: _formatTaskStartTime(taskData['tanggalTarget']),
                      judul: taskData['judul'] ?? 'Tanpa Judul',
                      waktu: _formatTaskDuration(taskData['tanggalTarget'], taskData['tanggalSelesai']),
                      status: taskData['status'] ?? 'tertunda', // <-- Kirim Status
                      pesertaIDs: List<String>.from(taskData['pesertaIDs'] ?? []),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TambahTugasScreen(user: widget.user)),
          );
        },
        backgroundColor: const Color(0xFF4DB6AC),
        foregroundColor: Colors.white,
        tooltip: 'Tambah Tugas',
        child: const Icon(Icons.add),
      ),
    );
  }

  // --- REVISI _buildTaskCard ---
  Widget _buildTaskCard({
    required String taskId, // <-- Terima ID Tugas
    required String jam,
    required String judul,
    required String waktu,
    required String status, // <-- Terima Status
    required List<String> pesertaIDs, // <-- Terima ID Peserta
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Kolom Jam
          SizedBox(
            width: 50,
            child: Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Text(
                jam,
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ),
          ),
          // Garis Hijau
          Container(
            width: 4,
            height: 70, // Sesuaikan tinggi kartu
            margin: const EdgeInsets.only(top: 4.0),
            decoration: BoxDecoration(
              color: const Color(0xFF4DB6AC), // Menggunakan warna tema
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(width: 12),
          // Konten Kartu
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey[50], // Latar belakang kartu
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Baris Judul dan Tombol Edit
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          judul,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // --- TOMBOL EDIT ---
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        iconSize: 20.0,
                        color: Colors.grey[600],
                        padding: const EdgeInsets.all(4.0),
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          // Panggil menu modal dengan ID dan status saat ini
                          _showStatusMenu(taskId, status);
                        },
                      ),
                      // --------------------
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Baris Waktu dan Peserta
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        waktu,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const Spacer(),
                      // Tampilkan jumlah peserta (dari data real)
                      if (pesertaIDs.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${pesertaIDs.length} Peserta',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}