import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:simoni/add_task.dart';

class LihatTugasScreen extends StatefulWidget {
  const LihatTugasScreen({Key? key}) : super(key: key);

  @override
  State<LihatTugasScreen> createState() => _LihatTugasScreenState();
}

class _LihatTugasScreenState extends State<LihatTugasScreen> {
  final ScrollController _scrollController = ScrollController();

  DateTime _selectedDate = DateTime.now();
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  // Sample data tugas
  final List<Map<String, dynamic>> _tugasList = [
    {
      'judul': 'Inspeksi Keamanan Pangan',
      'waktu': '10:00-11:30',
      'jamMulai': '10:00',
      'jamSelesai': '11:30',
      'peserta': [
        {'avatar': '👨', 'color': Colors.blue},
        {'avatar': '👩', 'color': Colors.pink},
      ],
    },
    {
      'judul': 'Penyusunan Laporan',
      'waktu': '13:00-13:30',
      'jamMulai': '13:00',
      'jamSelesai': '13:30',
      'peserta': [
        {'avatar': '👨', 'color': Colors.blue},
        {'avatar': '👩', 'color': Colors.pink},
      ],
    },
    {
      'judul': 'Rapat Koordinasi',
      'waktu': '14:00-15:30',
      'jamMulai': '14:00',
      'jamSelesai': '15:30',
      'peserta': [
        {'avatar': '👨', 'color': Colors.blue},
        {'avatar': '👩', 'color': Colors.pink},
      ],
    },
    {
      'judul': 'Monitoring',
      'waktu': '15:30-16:00',
      'jamMulai': '15:30',
      'jamSelesai': '16:00',
      'peserta': [
        {'avatar': '👨', 'color': Colors.blue},
        {'avatar': '👩', 'color': Colors.pink},
      ],
    },
    {
      'judul': 'Cek sampel',
      'waktu': '16:30-17:00',
      'jamMulai': '16:30',
      'jamSelesai': '17:00',
      'peserta': [
        {'avatar': '👨', 'color': Colors.blue},
        {'avatar': '👩', 'color': Colors.pink},
      ],
    },
  ];

  // Sample data untuk tasks yang ada (contoh)
  final List<Map<String, dynamic>> _existingTasks = [
    {'date': DateTime(2025, 10, 29), 'title': 'Meeting'},
    {'date': DateTime(2025, 10, 29), 'title': 'Review'},
    {'date': DateTime(2025, 10, 31), 'title': 'Inspeksi'},
    {'date': DateTime(2025, 10, 31), 'title': 'Laporan'},
    {'date': DateTime(2025, 10, 27), 'title': 'Audit'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedDate();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<DateTime> _getWeekDays() {
    DateTime now = _selectedDate;
    DateTime startOfWeek = now.subtract(Duration(days: 3));
    
    List<DateTime> weekDays = [];
    for (int i = 0; i < 7; i++) {
      weekDays.add(startOfWeek.add(Duration(days: i)));
    }
    return weekDays;
  }

  void _scrollToSelectedDate() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        (45.0 + 8.0) * 3,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  String _getDayName(DateTime date) {
    const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    return days[date.weekday - 1];
  }

  bool _hasTasksOnDate(DateTime date) {
    return _existingTasks.any((task) {
      DateTime taskDate = task['date'];
      return taskDate.year == date.year &&
             taskDate.month == date.month &&
             taskDate.day == date.day;
    });
  }

  int _getTaskCountOnDate(DateTime date) {
    return _existingTasks.where((task) {
      DateTime taskDate = task['date'];
      return taskDate.year == date.year &&
             taskDate.month == date.month &&
             taskDate.day == date.day;
    }).length;
  }

  String _getTaskCountText() {
    int count = _getTaskCountOnDate(_selectedDate);
    if (count == 0) {
      return '0 tugas hari ini';
    } else if (count == 1) {
      return '1 tugas hari ini';
    } else {
      return '$count tugas hari ini';
    }
  }

  void _previousMonth() {
    setState(() {
      if (_selectedMonth == 1) {
        _selectedMonth = 12;
        _selectedYear--;
      } else {
        _selectedMonth--;
      }

      int maxDay = DateUtils.getDaysInMonth(_selectedYear, _selectedMonth);
      int newDay = _selectedDate.day.clamp(1, maxDay);

      _selectedDate = DateTime(_selectedYear, _selectedMonth, newDay);
      _scrollToSelectedDate();
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

      int maxDay = DateUtils.getDaysInMonth(_selectedYear, _selectedMonth);
      int newDay = _selectedDate.day.clamp(1, maxDay);

      _selectedDate = DateTime(_selectedYear, _selectedMonth, newDay);
      _scrollToSelectedDate();
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
        toolbarHeight: 120,
        automaticallyImplyLeading: false,
        flexibleSpace: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button dengan circle background
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.chevron_left, color: Colors.black, size: 24),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(height: 16),
                // Tanggal selected
                Text(
                  '${_selectedDate.day} ${_getMonthName(_selectedDate.month)}',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 4),
                // Jumlah tugas
                Text(
                  _getTaskCountText(),
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Calendar Section
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              children: [
                // Calendar Month Selector
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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
                          fontFamily: 'Poppins',
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
                ),
              ],
            ),
          ),

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
          Expanded(
            child: Container(
              color: Colors.grey.shade100,
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: _tugasList.length,
                itemBuilder: (context, index) {
                  final tugas = _tugasList[index];
                  return _buildTaskCard(
                    jamMulai: tugas['jamMulai'],
                    jamSelesai: tugas['jamSelesai'],
                    judul: tugas['judul'],
                    waktu: tugas['waktu'],
                    peserta: tugas['peserta'],
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TambahTugasScreen()),
          );
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        backgroundColor: const Color(0xFF2D7063),
        child: const Icon(Icons.add, color: Colors.white, size: 28,),
      ),
    );
  }

  Widget _buildTaskCard({
    required String jamMulai,
    required String jamSelesai,
    required String judul,
    required String waktu,
    required List<Map<String, dynamic>> peserta,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Time column (left side)
          SizedBox(
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
                          ),
                        ),

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