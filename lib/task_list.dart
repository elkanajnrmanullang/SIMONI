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
  DateTime _selectedDate = DateTime.now();
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  int _taskCountToday = 0; // State untuk jumlah tugas di AppBar

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null); // Inisialisasi locale
  }

  // --- Fungsi Kalender ---
  List<DateTime> _getWeekDays() {
    DateTime now = _selectedDate;
    // Awal minggu hari Senin (now.weekday - 1)
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    List<DateTime> weekDays = [];
    for (int i = 0; i < 7; i++) {
      weekDays.add(startOfWeek.add(Duration(days: i)));
    }
    return weekDays;
  }

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
      Colors.grey,      // Berjalan
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
    final weekDays = _getWeekDays();
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
                  onPressed: _previousMonth,
                ),
                Text(
                  '${_getMonthName(_selectedMonth)} $_selectedYear',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
<<<<<<< HEAD
                IconButton(
                  icon: Icon(Icons.chevron_right, size: 28, color: Colors.grey[700]),
                  onPressed: _nextMonth,
=======

                // Week Days Selector
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: weekDays.map((date) {
                      final dayName = _getDayName(date);
                      final dayNumber = date.day;
                      final isSelected = date.day == _selectedDate.day &&
                          date.month == _selectedDate.month &&
                          date.year == _selectedDate.year;

                      final hasTasks = _hasTasksOnDate(date);
                      final today = DateTime.now();
                      final todayOnly = DateTime(today.year, today.month, today.day);
                      final dateOnly = DateTime(date.year, date.month, date.day);
                      final isPast = dateOnly.isBefore(todayOnly);

                      return GestureDetector(
                        onTap: isPast ? null : () {
                          setState(() {
                            _selectedDate = date;
                          });
                        },
                        child: Container(
                          width: 50,
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF4DB6AC) : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                            border: isSelected 
                                ? null 
                                : Border.all(
                                    color: isPast ? Colors.grey.shade500 : Colors.black,
                                    width: 1,
                                  ),
                          ),
                          child: Opacity(
                            opacity: isPast ? 0.8 : 1.0,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  dayName,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : 
                                    (isPast ? Colors.grey.shade400 : Colors.grey.shade600),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  dayNumber.toString(),
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : 
                                    (isPast ? Colors.grey.shade400 : Colors.black),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  width: 5,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: () {
                                      if (isSelected && hasTasks) {
                                        return Colors.white;
                                      } else if (isSelected && !hasTasks) {
                                        return Colors.transparent;
                                      } else if (isPast && hasTasks) {
                                        return Colors.grey.shade500;
                                      } else if (!isPast && hasTasks) {
                                        return const Color(0xFF43A895);
                                      } else {
                                        return Colors.transparent;
                                      }
                                    }(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
>>>>>>> ec23a19a2f70effda018e3c5e7462bb7b36d4843
                ),
              ],
            ),
          ),

<<<<<<< HEAD
          // Week Days Selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: weekDays.map((date) {
                final dayName = _getDayName(date);
                final dayNumber = date.day;
                final isSelected = DateUtils.isSameDay(_selectedDate, date);

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDate = date;
                      _selectedMonth = date.month;
                      _selectedYear = date.year;
                    });
                  },
                  child: Container(
                    width: 48,
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
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          // Task List (StreamBuilder)
=======
          // Add shadow effect at the bottom of calendar section
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  // ignore: deprecated_member_use
                  Colors.black.withOpacity(0.05),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          
          // Task List Section with Grey Background
>>>>>>> ec23a19a2f70effda018e3c5e7462bb7b36d4843
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
<<<<<<< HEAD
        backgroundColor: const Color(0xFF4DB6AC),
        foregroundColor: Colors.white,
        tooltip: 'Tambah Tugas',
        child: const Icon(Icons.add),
=======
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        backgroundColor: const Color(0xFF2D7063),
        child: const Icon(Icons.add, color: Colors.white, size: 28,),
>>>>>>> ec23a19a2f70effda018e3c5e7462bb7b36d4843
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
<<<<<<< HEAD
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
=======
            width: 45,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  jamMulai,
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  jamSelesai,
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Task content card with green left border
        Expanded(
          child: Container(
>>>>>>> ec23a19a2f70effda018e3c5e7462bb7b36d4843
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
<<<<<<< HEAD
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
=======
            child: Row(
              children: [
                // Green left section (1/8 of the box)
                Container(
                  width: 15,
                  height: 100,
                  decoration: const BoxDecoration(
                    color: Color(0xFF43A895),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                ),

          // White content section
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical:14, horizontal: 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Left side: Title and Time
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title
                              Text(
                                judul,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                  fontFamily: 'Poppins',
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 15),
                              
                              // Time with icon
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time_outlined,
                                    size: 16,
                                    color: Colors.grey.shade500,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    waktu,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade500,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ],
                              ),
                            ],
>>>>>>> ec23a19a2f70effda018e3c5e7462bb7b36d4843
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
<<<<<<< HEAD
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
=======

                        const SizedBox(width: 8),

                        // Right side: Avatars and Edit icon (avatars left of edit icon, spacing 8)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Participants avatars with overlap (left)
                                SizedBox(
                                  height: 45,
                                  width: peserta.length * 28.0 + 12,
                                  child: Stack(
                                    children: peserta.asMap().entries.map((entry) {
                                      int index = entry.key;
                                      var p = entry.value;

                                      return Positioned(
                                        left: index * 28.0,
                                        child: Container(
                                          width: 42,
                                          height: 42,
                                          decoration: BoxDecoration(
                                            color: p['color'],
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 2.5,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                // ignore: deprecated_member_use
                                                color: Colors.black.withOpacity(0.1),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Center(
                                            child: Text(
                                              p['avatar'],
                                              style: const TextStyle(fontSize: 20),
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),

                                const SizedBox(width: 16),

                                // Edit icon (right)
                                Icon(
                                  Icons.edit_square,
                                  size: 20,
                                  color: Colors.grey.shade600,
                                ),
                              ],
                            ),
                          ],
                        ),],
                    ),
>>>>>>> ec23a19a2f70effda018e3c5e7462bb7b36d4843
                  ),
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