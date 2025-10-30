import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:simoni/add_participants.dart';

class TambahTugasScreen extends StatefulWidget {
  const TambahTugasScreen({Key? key}) : super(key: key);

  @override
  State<TambahTugasScreen> createState() => _TambahTugasScreenState();
}

class _TambahTugasScreenState extends State<TambahTugasScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();

  // Form controllers / state
  final TextEditingController _judulController = TextEditingController();
  String? _selectedKategori;
  DateTime? _mulai;
  DateTime? _selesai;
  final List<Map<String, dynamic>> _peserta = [];

  // Calendar state
  DateTime _selectedDate = DateTime.now();
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  bool _isSubmitting = false;

  final List<String> _kategoriOptions = [
    'Pengawasan Pangan',
    'Riset & Laboratorium',
    'Logistik',
    'Produksi & Distribusi',
    'Pengawasan & Keamanan Pangan',
  ];

  // Sample data untuk tasks yang ada (contoh)
  // Ganti dengan data sebenarnya dari database/API Anda
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

    _mulai = DateTime.now();
    _selesai = DateTime.now().add(const Duration(hours: 1));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedDate();
    });
  }

  @override
  void dispose() {
    _judulController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ==========================
  // 📅 Calendar Helper Functions
  // ==========================

  List<DateTime> _getWeekDays() {
    DateTime now = _selectedDate;
    DateTime startOfWeek = now.subtract(Duration(days: 3)); // Start 3 days before
    
    List<DateTime> weekDays = [];
    for (int i = 0; i < 7; i++) {
      weekDays.add(startOfWeek.add(Duration(days: i)));
    }
    return weekDays;
  }

  void _scrollToSelectedDate() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        (45.0 + 8.0) * 3, // Width of each date item + spacing, multiplied by 3 for center
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  String _getDayName(DateTime date) {
    const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    return days[date.weekday - 1];
  }

  // Fungsi untuk mengecek apakah tanggal memiliki tugas
  bool _hasTasksOnDate(DateTime date) {
    return _existingTasks.any((task) {
      DateTime taskDate = task['date'];
      return taskDate.year == date.year &&
             taskDate.month == date.month &&
             taskDate.day == date.day;
    });
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

  Future<void> _pickDateTime({required bool isMulai}) async {
    final DateTime now = DateTime.now();
    DateTime initialDate = isMulai
        ? (_mulai ?? _selectedDate)
        : (_selesai ?? (_mulai ?? _selectedDate));

    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (date == null) return;

    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
    );
    if (time == null) return;

    final DateTime combined = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    setState(() {
      if (isMulai) {
        _mulai = combined;
        if (_selesai != null && _selesai!.isBefore(_mulai!)) {
          _selesai = null;
        }
      } else {
        _selesai = combined;
      }
    });
  }

  String _formatDateTimeShort(DateTime? dt) {
    if (dt == null) return 'Pilih waktu';
    return DateFormat('d MMM, HH:mm').format(dt);
  }
  
  Future<void> _navigateToAddParticipants() async {
  final result = await Navigator.push<List<Map<String, dynamic>>>(
    context,
    MaterialPageRoute(
      builder: (context) => AddParticipantsScreen(
        selectedParticipants: _peserta,
      ),
    ),
  );

  if (result != null) {
    setState(() {
      _peserta.clear();
      _peserta.addAll(result);
    });
  }
}

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_judulController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan isi judul tugas'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    if (_selectedKategori == null ) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih kategori tugas/kegiatan'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    showDialog(
  context: context,
  barrierDismissible: false, // tidak bisa ditutup klik luar
  builder: (BuildContext context) {
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context, rootNavigator: true).pop(); // tutup dialog
      if (mounted){
      Navigator.of(context).pop();
      } // kembali ke layar sebelumnya
    });

    return Dialog(
  backgroundColor: Colors.white,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(20),
  ),
  child: Padding(
    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white, // background putih
            border: Border.all(
              color: const Color(0xFF2D7063), // warna hijau border
              width: 4,
            ),
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.check_rounded,
            color: Color(0xFF2D7063),
            size: 45,
          ),
        ),

        const SizedBox(height: 20),
        const Text(
          'Tersimpan!',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Tugas Anda Berhasil Diunggah.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.black54,
            fontFamily: 'Poppins',
          ),
        ),
      ],
    ),
  ),
);
  },
);  } 

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
        title: Text(
          '${_selectedDate.day} ${_getMonthName(_selectedDate.month)}',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: Padding(
            padding: const EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              bottom: 12.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text(
                  '0 tugas hari ini',
                  style: TextStyle(
                    color: Colors.grey, 
                    fontSize: 12, 
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
                  color: Colors.black.withOpacity(0.5),
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

                      // Check if this date has tasks (you'll need to implement this logic)
                      final hasTasks = _hasTasksOnDate(date);
                      // Check if date is in the past (more than 3 days before today)
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
                                    return Colors.white; // Putih jika dipilih DAN ada task
                                  } else if (isSelected && !hasTasks) {
                                    return Colors.transparent; // Tidak ada dot jika dipilih tapi belum ada task
                                  } else if (isPast && hasTasks) {
                                    return Colors.grey.shade500; // Abu jika past dan ada task
                                  } else if (!isPast && hasTasks) {
                                    return const Color(0xFF4DB6AC); // Teal jika ada task dan belum past
                                  } else {
                                    return Colors.transparent; // Tidak ada dot
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
               
            // Form Content
            Expanded(
              child : Container(
                color : Colors.grey.shade100,
                child : Form(
                  key : _formKey,
                  child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Judul Tugas Section
                        const Text(
                          'Judul Tugas',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                            fontFamily: 'Poppins',
                          ),              
                          ),            
                          const SizedBox(height: 12),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                          child: TextFormField(
                        controller: _judulController,
                        style : const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontFamily: 'Poppins',
                        ),
                        decoration: InputDecoration(
                          hintText: 'Masukkan judul tugas',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 14,
                            fontFamily: 'Poppins',
                            ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Kategori Section
                    const Text(
                      'Kategori',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _kategoriOptions.map((kategori) {
                        final isSelected = _selectedKategori == kategori;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedKategori = isSelected ? null : kategori;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal:10,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF4DB6AC)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF4DB6AC)
                                    : Colors.grey.shade400,
                              ),
                            ),
                            child: Text(
                              kategori,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.grey[400],
                                fontSize: 13,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Waktu Section
                    Row(
                      children: [
                        Flexible(
                          flex : 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Mulai',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              const SizedBox(height: 12),
                              GestureDetector(
                                onTap: () => _pickDateTime(isMulai : true),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _formatDateTimeShort(_mulai),
                                        style: TextStyle(
                                          color: Colors.grey[800],
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                
                                      const SizedBox(width : 4),
                                      Icon(
                                        Icons.keyboard_arrow_down,
                                        color: Colors.grey[800],
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 40),
                        Flexible(
                          flex : 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Selesai',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              const SizedBox(height: 12),
                              GestureDetector(
                                onTap: () => _pickDateTime(isMulai: false),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _formatDateTimeShort(_selesai),
                                        style: TextStyle(
                                          color: Colors.grey[800],
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                      
                                      const SizedBox(width : 4),
                                      Icon(
                                        Icons.keyboard_arrow_down,
                                        color: Colors.grey[800],
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // Tambah Peserta Section

Row(
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [
    // Add button (circle dengan icon +)
    GestureDetector(
      onTap: _navigateToAddParticipants,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF2D7063), width: 1.5),
        ),
        child: Icon(
          Icons.add,
          color: const Color(0xFF2D7063),
          size: 24,
        ),
      ),
    ),
    const SizedBox(width: 12),
    
    // Tambah Peserta box dengan avatar
    Expanded(
      child: GestureDetector(
        onTap: _navigateToAddParticipants,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12, 
            vertical: 12
            ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: _peserta.isEmpty
              ? Text(
                  'Tambah Peserta',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //Judul
                    const Text(
                      'Peserta',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Tampilkan avatar peserta
                    Wrap(
                        spacing: -10, // Overlap avatars
                        runSpacing: 6,
                        children: [
                          ..._peserta.take(7).map((participant) {
                            return Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                  width: 2,
                                ),
                                image: participant['avatar'].toString().startsWith('http')
                                  ? DecorationImage(
                                      image: NetworkImage(participant['avatar']),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                              color: participant['color'] ?? Colors.grey.shade300,
                            ),
                            child: !participant['avatar']
                                    .toString()
                                    .startsWith('http')
                                ? Center(
                                    child: Text(
                                      participant['avatar'],
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                  )
                                : null,
                          );
                        }),
                          // Jika ada lebih dari 7 peserta, tampilkan +N
                          if (_peserta.length > 7)
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  '+${_peserta.length - 7}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    const SizedBox(height: 8),
                    Text(
                      '${_peserta.length} Peserta',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
        ),
      ),
    ),
  ],
),
const SizedBox(height: 100),
                        // Buat Tugas Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4DB6AC),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: _isSubmitting
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Buat Tugas',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                          ),
                        ),
                      const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}