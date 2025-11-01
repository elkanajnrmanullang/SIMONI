import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:simoni/add_participants.dart';
import 'package:simoni/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TambahTugasScreen extends StatefulWidget {
  final UserModel user; // <-- Menerima data user
  const TambahTugasScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<TambahTugasScreen> createState() => _TambahTugasScreenState();
}

class _TambahTugasScreenState extends State<TambahTugasScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController(); // Controller untuk list tanggal

  // Form controllers
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

  // --- PERBAIKAN 1: Tentukan tanggal mulai kalender ---
  // Kita gunakan 1 Jan di tahun ini sebagai titik awal (index 0)
  late DateTime _calendarStartDate;
  final int _totalCalendarDays = 365 * 3; // Tampilkan 3 tahun

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null); // Inisialisasi locale

    _mulai = DateTime.now();
    _selesai = DateTime.now().add(const Duration(hours: 1));

    // --- PERBAIKAN 2: Inisialisasi tanggal mulai ---
    final DateTime today = DateUtils.dateOnly(DateTime.now());
    _calendarStartDate = DateTime(today.year, 1, 1); // 1 Jan tahun ini

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedDate(animate: false); // Langsung lompat tanpa animasi saat load
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

  // --- FUNGSI _getWeekDays() TIDAK DIPERLUKAN LAGI ---

  // --- PERBAIKAN 3: Logika scroll untuk memusatkan tanggal ---
  void _scrollToSelectedDate({bool animate = true}) {
    if (!_scrollController.hasClients) return;

    // 1. Hitung index tanggal yang dipilih
    // Pastikan _selectedDate tidak sebelum _calendarStartDate
    final DateTime targetDate = DateUtils.dateOnly(_selectedDate);
    if (targetDate.isBefore(_calendarStartDate)) {
      return; // Tidak bisa scroll ke tanggal sebelum awal kalender
    }
    
    final int selectedIndex = targetDate.difference(_calendarStartDate).inDays;

    // 2. Tentukan ukuran item (lebar 50 + padding horizontal 4*2 = 8)
    const double itemWidth = 50.0 + 8.0; 

    // 3. Dapatkan lebar layar
    final double screenWidth = MediaQuery.of(context).size.width;

    // 4. Hitung offset untuk menempatkan item di tengah
    // (index * lebar item) - (setengah layar) + (setengah lebar item)
    double offset = (selectedIndex * itemWidth) - (screenWidth / 2) + (itemWidth / 2);

    // 5. Batasi offset agar tidak scroll ke area kosong
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

  String _getDayName(DateTime date) {
    return DateFormat('E', 'id_ID').format(date); // Versi intl
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

      // Cek jika tanggal baru < hari ini, paksa ke hari ini
      final DateTime today = DateUtils.dateOnly(DateTime.now());
      if (_selectedDate.isBefore(today)) {
        _selectedDate = today;
      }
    });
    _scrollToSelectedDate(); // Panggil scroll setelah state berubah
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
    _scrollToSelectedDate(); // Panggil scroll setelah state berubah
  }

  String _getMonthName(int month) {
    return DateFormat('MMMM', 'id_ID').format(DateTime(_selectedYear, month));
  }

  Future<void> _pickDateTime({required bool isMulai}) async {
    final DateTime now = DateTime.now();
    // Tanggal pertama yang bisa dipilih adalah hari ini
    final DateTime firstSelectableDate = DateUtils.dateOnly(now);

    DateTime initialDate = isMulai
        ? (_mulai ?? _selectedDate)
        : (_selesai ?? (_mulai ?? _selectedDate));

    // Pastikan initialDate tidak sebelum hari ini
    if (initialDate.isBefore(firstSelectableDate)) {
      initialDate = firstSelectableDate;
    }

    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstSelectableDate, // Hanya bisa pilih hari ini atau ke depan
      lastDate: DateTime(now.year + 5),
    );
    if (date == null) return;

    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
    );
    if (time == null) return;

    final DateTime combined = DateTime(
      date.year, date.month, date.day, time.hour, time.minute,
    );

    // Cek apakah waktu yang dipilih sudah lewat
    if (combined.isBefore(DateTime.now().subtract(const Duration(minutes: 1)))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak dapat memilih waktu yang sudah lewat'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      if (isMulai) {
        _mulai = combined;
        _selectedDate = combined; // Update kalender ke tanggal yg dipilih
        _selectedMonth = combined.month;
        _selectedYear = combined.year;
        if (_selesai != null && _selesai!.isBefore(_mulai!)) {
          _selesai = null;
        }
      } else {
        if (_mulai != null && combined.isBefore(_mulai!)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Waktu selesai tidak boleh sebelum waktu mulai'),
              backgroundColor: Colors.orange,
            ),
          );
        } else {
          _selesai = combined;
          _selectedDate = combined; // Update kalender ke tanggal yg dipilih
          _selectedMonth = combined.month;
          _selectedYear = combined.year;
        }
      }
    });

    // --- PERBAIKAN 4: Panggil scroll setelah memilih tanggal ---
    _scrollToSelectedDate();
  }

  String _formatDateTimeShort(DateTime? dt) {
    if (dt == null) return 'Pilih waktu';
    return DateFormat('d MMM, HH:mm', 'id_ID').format(dt);
  }

  Future<void> _navigateToAddParticipants() async {
    final result = await Navigator.push<List<Map<String, dynamic>>>(
      context,
      MaterialPageRoute(
        builder: (context) => AddParticipantsScreen(
          selectedParticipants: _peserta,
          // currentUser: widget.user, // Kirim user jika add_participants perlu
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

  // --- FUNGSI SUBMIT (INTEGRASI FIREBASE) ---
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Cek apakah tanggal yang dipilih sudah lewat
    final DateTime today = DateUtils.dateOnly(DateTime.now());
    final DateTime selectedDay = DateUtils.dateOnly(_selectedDate);
    if (selectedDay.isBefore(today)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak dapat menambah tugas untuk tanggal yang sudah lewat'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedKategori == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih kategori tugas/kegiatan'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    if (_mulai == null || _selesai == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih waktu mulai dan selesai'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      List<String> pesertaIDs = _peserta.map((p) => p['id'].toString()).toList();

      Map<String, dynamic> taskData = {
        'judul': _judulController.text.trim(),
        'kategori': _selectedKategori,
        'waktuMulai': Timestamp.fromDate(_mulai!),
        'waktuSelesai': Timestamp.fromDate(_selesai!),
        // Gunakan _mulai (yang sudah divalidasi) sebagai tanggal target
        'tanggalTarget': Timestamp.fromDate(_mulai!),
        'pembuatID': widget.user.uid,
        'pesertaIDs': pesertaIDs,
        'status': 'tertunda',
        'deskripsi': '',
      };

      await FirebaseFirestore.instance.collection('tugas').add(taskData);

      if (!mounted) return;
      _showSuccessDialog();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuat tugas: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  // --- Fungsi Dialog Sukses ---
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.of(context, rootNavigator: true).pop(); // tutup dialog
          if (mounted) {
            Navigator.of(context).pop(); // kembali ke layar sebelumnya
          }
        });

        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(
                      color: const Color(0xFF2D7063),
                      width: 4,
                    ),
                    boxShadow: [
                      BoxShadow(
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
                Text(
                  'Tersimpan!',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tugas Anda Berhasil Dibuat.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // final weekDays = _getWeekDays(); // <-- TIDAK DIPAKAI LAGI
    final appBarDate = DateFormat('d MMMM', 'id_ID').format(_selectedDate);
    // Variabel untuk mengecek hari ini (tanpa jam)
    final DateTime today = DateUtils.dateOnly(DateTime.now());

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
          appBarDate,
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: Padding(
            padding: const EdgeInsets.only(
              left: 16.0, right: 16.0, bottom: 12.0,
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
                        // Logika untuk menonaktifkan tombol 'previous month'
                        onPressed: () {
                          DateTime firstDayOfCurrentMonth = DateTime(today.year, today.month, 1);
                          DateTime firstDayOfSelectedMonth = DateTime(_selectedYear, _selectedMonth, 1);
                          if (firstDayOfSelectedMonth.isAfter(firstDayOfCurrentMonth)) {
                            _previousMonth();
                          }
                        },
                        color: DateTime(_selectedYear, _selectedMonth, 1).isAfter(DateTime(today.year, today.month, 1))
                            ? Colors.black87
                            : Colors.grey[300],
                      ),
                      Text(
                        '${_getMonthName(_selectedMonth)} $_selectedYear',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: _nextMonth, // Selalu bisa ke bulan depan
                      ),
                    ],
                  ),
                ),

                // --- PERBAIKAN 5: Ganti Row menjadi ListView.builder ---
                Container(
                  height: 90, // Beri tinggi tetap untuk list horizontal
                  child: ListView.builder(
                    controller: _scrollController, // <--- PENTING: Sambungkan controller
                    scrollDirection: Axis.horizontal,
                    itemCount: _totalCalendarDays, // Tampilkan total hari
                    padding: const EdgeInsets.symmetric(horizontal: 12.0), // Padding di awal & akhir list
                    itemBuilder: (context, index) {
                      
                      // Hitung tanggal berdasarkan index
                      final DateTime date = _calendarStartDate.add(Duration(days: index));
                      
                      final dayName = _getDayName(date);
                      final dayNumber = date.day;
                      final isSelected = DateUtils.isSameDay(date, _selectedDate);
                      final bool isPast = date.isBefore(today); // Cek apakah tanggal sudah lewat

                      // Gunakan Padding untuk spasi antar item
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: GestureDetector(
                          onTap: isPast ? null : () { // <-- JANGAN LAKUKAN APAPUN JIKA isPast
                            setState(() { 
                              _selectedDate = date; 
                              _selectedMonth = date.month;
                              _selectedYear = date.year;

                              // Sinkronkan tanggal di form
                              if (_mulai != null) {
                                _mulai = DateTime(date.year, date.month, date.day, _mulai!.hour, _mulai!.minute);
                              }
                              if (_selesai != null) {
                                _selesai = DateTime(date.year, date.month, date.day, _selesai!.hour, _selesai!.minute);
                              }
                            });
                            _scrollToSelectedDate(); // Panggil scroll saat di-tap
                          },
                          child: Container(
                            width: 50,
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                            decoration: BoxDecoration(
                              color: isSelected && !isPast ? const Color(0xFF4DB6AC) : Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                              border: isSelected && !isPast
                                  ? null
                                  : Border.all(
                                      color: isPast ? Colors.grey.shade300 : Colors.grey.shade400, // <-- ABU-ABU JIKA isPast
                                      width: 1,
                                    ),
                            ),
                            child: Opacity(
                              opacity: isPast ? 0.5 : 1.0, // <-- Buat transparan jika isPast
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    dayName,
                                    style: GoogleFonts.poppins(
                                      color: isSelected && !isPast
                                          ? Colors.white
                                          : (isPast ? Colors.grey.shade400 : Colors.grey.shade600),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    dayNumber.toString(),
                                    style: GoogleFonts.poppins(
                                      color: isSelected && !isPast
                                          ? Colors.white
                                          : (isPast ? Colors.grey.shade400 : Colors.black87),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  const SizedBox(height: 5, width: 5), // Placeholder
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // --- AKHIR PERBAIKAN 5 ---
              ],
            ),
          ),

          // Form Content
          Expanded(
            child: Container(
              color: Colors.grey.shade100,
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  // --- CATATAN: ScrollController utama form tidak terpasang ---
                  // Jika Anda ingin scroll form, pasang controller di sini
                  // controller: _formScrollController, 
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Judul Tugas Section
                        Text(
                          'Judul Tugas',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
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
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 14,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Masukkan judul tugas',
                              hintStyle: GoogleFonts.poppins(
                                color: Colors.grey.shade400,
                                fontSize: 14,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Judul tidak boleh kosong';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Kategori Section
                        Text(
                          'Kategori',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
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
                                  horizontal: 12,
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
                                  style: GoogleFonts.poppins(
                                    color: isSelected ? Colors.white : Colors.grey[700],
                                    fontSize: 13,
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
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Mulai',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  GestureDetector(
                                    onTap: () => _pickDateTime(isMulai: true),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            _formatDateTimeShort(_mulai),
                                            style: GoogleFonts.poppins(
                                              color: Colors.grey[800],
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
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
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Selesai',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  GestureDetector(
                                    onTap: () => _pickDateTime(isMulai: false),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            _formatDateTimeShort(_selesai),
                                            style: GoogleFonts.poppins(
                                              color: Colors.grey[800],
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
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
                        const SizedBox(height: 24),

                        // Tambah Peserta Section
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: _navigateToAddParticipants,
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: const Color(0xFF2D7063), width: 1.5),
                                  color: Colors.white,
                                ),
                                child: Icon(
                                  Icons.add,
                                  color: const Color(0xFF2D7063),
                                  size: 24,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: GestureDetector(
                                onTap: _navigateToAddParticipants,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: _peserta.isEmpty
                                      ? Text(
                                          'Tambah Peserta',
                                          style: GoogleFonts.poppins(
                                            color: Colors.grey.shade500,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        )
                                      : Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${_peserta.length} Peserta Dipilih',
                                              style: GoogleFonts.poppins(
                                                color: Colors.black87,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Wrap(
                                              spacing: -10,
                                              runSpacing: 4,
                                              children: [
                                                ..._peserta.take(7).map((participant) {
                                                  final avatarUrl = participant['avatar']?.toString() ?? '';
                                                  final bool isNetwork = avatarUrl.startsWith('http');

                                                  return Container(
                                                    width: 36,
                                                    height: 36,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      border: Border.all(color: Colors.white, width: 2),
                                                      color: participant['color'] ?? Colors.grey.shade300,
                                                      image: isNetwork
                                                          ? DecorationImage(
                                                              image: NetworkImage(avatarUrl),
                                                              fit: BoxFit.cover,
                                                            )
                                                          : null,
                                                    ),
                                                    child: !isNetwork && avatarUrl.isNotEmpty
                                                        ? Center(child: Text(avatarUrl, style: const TextStyle(fontSize: 16)))
                                                        : null,
                                                  );
                                                }), // <-- PERBAIKAN 3: Koma dihapus dari sini

                                                // Counter +N
                                                if (_peserta.length > 7)
                                                  Container(
                                                    width: 36,
                                                    height: 36,
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey.shade200,
                                                      shape: BoxShape.circle,
                                                      border: Border.all(color: Colors.white, width: 2),
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        '+${_peserta.length - 7}',
                                                        style: GoogleFonts.poppins(
                                                          fontSize: 11,
                                                          fontWeight: FontWeight.w600,
                                                          color: Colors.grey.shade700,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 48), // Jarak ke tombol submit

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
                                : Text(
                                    'Buat Tugas',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
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