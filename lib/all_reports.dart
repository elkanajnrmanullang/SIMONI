import 'package:flutter/material.dart';
import 'package:simoni/add_reports.dart';
import 'package:simoni/download_reports.dart';
import 'package:simoni/home_screen.dart';
import 'package:simoni/models/user_model.dart';

class AllReportsPage extends StatefulWidget {
  final UserModel user; // <-- TAMBAHKAN FIELD INI
  const AllReportsPage({Key? key, required this.user}) : super(key: key); // <-- UPDATE KONSTRUKTOR

  @override
  State<AllReportsPage> createState() => _AllReportsPageState();
}

class _AllReportsPageState extends State<AllReportsPage> {
  bool showAllReports = true; // true = Semua Laporan, false = Unduh Laporan

  // Sample data untuk reports
  final List<Map<String, dynamic>> reports = [
    {
      'date': '21-09-2025',
      'time': '09:15',
      'title': 'Koordinasi lintas departemen terkait kebutuhan sumber daya',
      'location': 'Bandar Lampung',
      'image': 'assets/images/meeting1.jpg', // Ganti dengan path gambar Anda
    },
    {
      'date': '21-09-2025',
      'time': '09:15',
      'title': 'Koordinasi lintas departemen terkait kebutuhan sumber daya',
      'location': 'Bandar Lampung',
      'image': 'assets/images/meeting2.jpg',
    },
    {
      'date': '21-09-2025',
      'time': '09:15',
      'title': 'Koordinasi lintas departemen terkait kebutuhan sumber daya',
      'location': 'Bandar Lampung',
      'image': 'assets/images/meeting3.jpg',
    },
    {
      'date': '21-09-2025',
      'time': '09:15',
      'title': 'Koordinasi lintas departemen terkait kebutuhan sumber daya',
      'location': 'Bandar Lampung',
      'image': 'assets/images/meeting4.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Reports',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header dengan deskripsi
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Temukan laporan atau review dari seluruh kegiatan dan tugas masing-masing pegawai di setiap bulannya. Anda dapat membuat, memantau perkembangan kinerja, pencapaian target, serta aktivitas harian hingga bulanan.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                // Toggle buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            showAllReports = true;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: showAllReports
                              ? const Color(0xFF2D9F8F)
                              : Colors.white,
                          foregroundColor: showAllReports
                              ? Colors.white
                              : Colors.grey,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: showAllReports
                                  ? const Color(0xFF2D9F8F)
                                  : Colors.grey.shade300,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Semua Laporan',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DownloadReportsPage(),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: !showAllReports
                              ? const Color(0xFF2D9F8F)
                              : Colors.grey,
                          side: BorderSide(
                            color: !showAllReports
                                ? const Color(0xFF2D9F8F)
                                : Colors.grey.shade300,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Unduh Laporan',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // List of reports
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final report = reports[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 70,
                        height: 70,
                        color: Colors.grey[300],
                        // Gunakan Image.asset jika Anda punya gambar
                        // child: Image.asset(
                        //   report['image'],
                        //   fit: BoxFit.cover,
                        // ),
                        child: const Icon(
                          Icons.people,
                          color: Colors.grey,
                          size: 30,
                        ),
                      ),
                    ),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              report['date'],
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              report['time'],
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          report['title'],
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              report['location'],
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      // Bottom navigation with FAB
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddReportPage()),
          );
        },
        backgroundColor: const Color(0xFF2D9F8F),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.home_outlined),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen(user: widget.user)),
                  );
                },
                color: Colors.grey,
              ),
              IconButton(
                icon: const Icon(Icons.description),
                onPressed: () {},
                color: const Color(0xFF2D9F8F),
              ),
              const SizedBox(width: 48), // Space for FAB
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {},
                color: Colors.grey,
              ),
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey[300],
                child: const Icon(Icons.person, size: 20, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
