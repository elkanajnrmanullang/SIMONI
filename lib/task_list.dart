import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; 
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart'; 
import 'package:simoni/add_task.dart';
import 'package:simoni/models/user_model.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart';

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
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    List<DateTime> weekDays = [];
    for (int i = 0; i < 7; i++) {
      weekDays.add(startOfWeek.add(Duration(days: i)));
    }
    return weekDays;
  }

  String _getDayName(DateTime date) {
    return DateFormat('E', 'id_ID').format(date);
  }

  void _previousMonth() {
    setState(() {
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
    return DateFormat('MMMM', 'id_ID').format(DateTime(_selectedYear, month));
  }
  // --- Akhir Fungsi Kalender ---

  // --- Fungsi Stream Query ---
  Stream<QuerySnapshot> _buildTaskStream() {
    final startOfDay = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, 0, 0, 0);
    final endOfDay = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, 23, 59, 59);

    Query query = FirebaseFirestore.instance.collection('tugas')
      .where('tanggalTarget', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
      .where('tanggalTarget', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
      .where('pembuatID', isEqualTo: widget.user.uid) // Filter by creator
      .orderBy('tanggalTarget', descending: false); // Order by time

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
        if (DateUtils.isSameDay(start, end)) { // Gunakan DateUtils.isSameDay
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
              style: GoogleFonts.poppins( // Terapkan GoogleFonts jika digunakan
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
             Text(
              '$_taskCountToday tugas hari ini',
              style: GoogleFonts.poppins( // Terapkan GoogleFonts jika digunakan
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
                  style: GoogleFonts.poppins( // Terapkan GoogleFonts jika digunakan
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
                          style: GoogleFonts.poppins( // Terapkan GoogleFonts jika digunakan
                            color: isSelected ? Colors.white : Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          dayNumber.toString(),
                          style: GoogleFonts.poppins( // Terapkan GoogleFonts jika digunakan
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
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _buildTaskStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF4DB6AC)));
                }
                if (snapshot.hasError) {
                  print('Error fetching tasks: ${snapshot.error}');
                  return const Center(child: Text('Gagal memuat tugas.', style: TextStyle(color: Colors.red)));
                }

                final taskDocs = snapshot.data?.docs ?? [];
                final currentTaskCount = taskDocs.length;

                // Update AppBar count di post frame callback jika perlu
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
                      style: GoogleFonts.poppins(color: Colors.grey), // Terapkan GoogleFonts
                    )
                  );
                }

                // Tampilkan ListView jika ada data
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 80.0), // Padding bawah FAB
                  itemCount: taskDocs.length,
                  itemBuilder: (context, index) {
                    final taskData = taskDocs[index].data() as Map<String, dynamic>;

                    return _buildTaskCard(
                      jam: _formatTaskStartTime(taskData['tanggalTarget']),
                      judul: taskData['judul'] ?? 'Tanpa Judul',
                      // Gunakan field 'mulai' dan 'selesai' dari data Anda jika ada
                      waktu: _formatTaskDuration(taskData['tanggalTarget'], taskData['tanggalSelesai']),
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
          // Kirim user ke AddTask screen jika diperlukan
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TambahTugasScreen(/* user: widget.user */)),
          );
        },
        backgroundColor: const Color(0xFF4DB6AC),
        foregroundColor: Colors.white,
        tooltip: 'Tambah Tugas',
        child: const Icon(Icons.add),
      ),
    );
  }

  // --- Widget _buildTaskCard ---
  Widget _buildTaskCard({
    required String jam,
    required String judul,
    required String waktu,
    required List<String> pesertaIDs,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 50,
            child: Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Text(
                jam,
                style: GoogleFonts.poppins( // Terapkan GoogleFonts
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          Container(
            width: 4,
            height: 70, // Sesuaikan tinggi kartu
            margin: const EdgeInsets.only(top: 4.0),
            decoration: BoxDecoration(
              color: const Color(0xFF4DB6AC),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    judul,
                    style: GoogleFonts.poppins( // Terapkan GoogleFonts
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 14, color: Colors.grey[600]), // Perkecil ikon waktu
                      const SizedBox(width: 4),
                      Text(
                        waktu,
                        style: GoogleFonts.poppins( // Terapkan GoogleFonts
                          fontSize: 12,
                          color: Colors.grey[600], // Warna sedikit lebih gelap
                        ),
                      ),
                      const Spacer(),
                      if (pesertaIDs.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${pesertaIDs.length} Peserta',
                            style: GoogleFonts.poppins( // Terapkan GoogleFonts
                              fontSize: 10,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
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