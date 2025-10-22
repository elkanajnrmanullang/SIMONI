import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:simoni/add_task.dart';

class LihatTugasScreen extends StatefulWidget {
  const LihatTugasScreen({Key? key}) : super(key: key);

  @override
  State<LihatTugasScreen> createState() => _LihatTugasScreenState();
}

class _LihatTugasScreenState extends State<LihatTugasScreen> {
  DateTime _selectedDate = DateTime.now();
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  // Sample data tugas
  final List<Map<String, dynamic>> _tugasList = [
    {
      'judul': 'Inspeksi Keamanan Pangan',
      'waktu': '10:00-11:30',
      'jam': '10:00',
      'peserta': [
        {'avatar': '👨', 'color': Colors.blue},
        {'avatar': '👩', 'color': Colors.pink},
      ],
    },
    {
      'judul': 'Penyusunan Laporan',
      'waktu': '13:00-13:30',
      'jam': '13:00',
      'peserta': [
        {'avatar': '👨', 'color': Colors.blue},
        {'avatar': '👩', 'color': Colors.pink},
      ],
    },
    {
      'judul': 'Rapat Koordinasi',
      'waktu': '14:00-15:30',
      'jam': '14:00',
      'peserta': [
        {'avatar': '👨', 'color': Colors.blue},
        {'avatar': '👩', 'color': Colors.pink},
      ],
    },
    {
      'judul': 'Monitoring',
      'waktu': '15:30-16:00',
      'jam': '15:30',
      'peserta': [
        {'avatar': '👨', 'color': Colors.blue},
        {'avatar': '👩', 'color': Colors.pink},
      ],
    },
    {
      'judul': 'Cek sampel',
      'waktu': '16:30-17:00',
      'jam': '16:00',
      'peserta': [
        {'avatar': '👨', 'color': Colors.blue},
        {'avatar': '👩', 'color': Colors.pink},
      ],
    },
  ];

  List<DateTime> _getWeekDays() {
    // Get current week
    DateTime now = _selectedDate;
    int currentWeekday = now.weekday;
    DateTime startOfWeek = now.subtract(Duration(days: currentWeekday - 1));

    List<DateTime> weekDays = [];
    for (int i = 0; i < 7; i++) {
      weekDays.add(startOfWeek.add(Duration(days: i)));
    }
    return weekDays;
  }

  String _getDayName(DateTime date) {
    const days = ['Sen', 'Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum'];
    return days[date.weekday - 1];
  }

  void _previousMonth() {
    setState(() {
      if (_selectedMonth == 1) {
        _selectedMonth = 12;
        _selectedYear--;
      } else {
        _selectedMonth--;
      }
    });
  }

  void _nextMonth() {
    setState(() {
      if (_selectedMonth == 12) {
        _selectedMonth = 1;
        _selectedYear++;
      } else {
        _selectedMonth++;
      }
    });
  }

  String _getMonthName(int month) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final weekDays = _getWeekDays();

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
            const Text(
              '3 September',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${_tugasList.length} tugas hari ini',
              style: const TextStyle(
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
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _previousMonth,
                ),
                Text(
                  '${_getMonthName(_selectedMonth)} $_selectedYear',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
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
                final isSelected =
                    date.day == _selectedDate.day &&
                    date.month == _selectedDate.month &&
                    date.year == _selectedDate.year;
                final hasTask = date.day == 3; // Sample: day 3 has tasks

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDate = date;
                    });
                  },
                  child: Container(
                    width: 45,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF4DB6AC)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          dayName,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dayNumber.toString(),
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (hasTask)
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF4DB6AC),
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 20),

          // Task List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: _tugasList.length,
              itemBuilder: (context, index) {
                final tugas = _tugasList[index];
                return _buildTaskCard(
                  jam: tugas['jam'],
                  judul: tugas['judul'],
                  waktu: tugas['waktu'],
                  peserta: tugas['peserta'],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to Tambah Tugas Screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TambahTugasScreen()),
          );
        },
        backgroundColor: const Color(0xFF4DB6AC),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildTaskCard({
    required String jam,
    required String judul,
    required String waktu,
    required List<Map<String, dynamic>> peserta,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time column
          SizedBox(
            width: 50,
            child: Text(
              jam,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),

          // Green bar
          Container(
            width: 4,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF4DB6AC),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(width: 12),

          // Task content card
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
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
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        waktu,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const Spacer(),
                      // Participants avatars
                      Row(
                        children: peserta.map((p) {
                          return Container(
                            margin: const EdgeInsets.only(left: 4),
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: p['color'],
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: Center(
                              child: Text(
                                p['avatar'],
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          );
                        }).toList(),
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
