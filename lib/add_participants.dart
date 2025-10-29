import 'package:flutter/material.dart';

class AddParticipantsScreen extends StatefulWidget {
  final List<Map<String, dynamic>> selectedParticipants;

  const AddParticipantsScreen({Key? key, required this.selectedParticipants})
    : super(key: key);

  @override
  State<AddParticipantsScreen> createState() => _AddParticipantsScreenState();
}

class _AddParticipantsScreenState extends State<AddParticipantsScreen> {
  late List<Map<String, dynamic>> _selectedParticipants;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredParticipants = [];

  // Daftar semua peserta yang tersedia
  final List<Map<String, dynamic>> _allParticipants = [
    {
      'id': '1',
      'name': 'Siti Nurhayati',
      'role': 'Kepala UPTD',
      'avatar': 'https://i.pravatar.cc/150?img=5',
      'color': Colors.grey[400]!,
    },
    {
      'id': '2',
      'name': 'Bambang Supriyanto',
      'role': 'Kepala Subag. umum',
      'avatar': 'https://i.pravatar.cc/150?img=12',
      'color': Colors.grey[400]!,
    },
    {
      'id': '3',
      'name': 'Indah Lestari',
      'role': 'Kepala Mutu Pangan',
      'avatar': 'https://i.pravatar.cc/150?img=10',
      'color': Colors.grey[400]!,
    },
    {
      'id': '4',
      'name': 'Nova Putri',
      'role': 'Pengendali Mutu',
      'avatar': 'https://i.pravatar.cc/150?img=16',
      'color': Colors.grey[400]!,
    },
    {
      'id': '5',
      'name': 'Rudiyanto',
      'role': 'Kepala Seksi Keamanan',
      'avatar': 'https://i.pravatar.cc/150?img=8',
      'color': Colors.grey[400]!,
    },
    {
      'id': '6',
      'name': 'Fajar Nugroho',
      'role': 'Pranata Komputer',
      'avatar': 'https://i.pravatar.cc/150?img=13',
      'color':Colors.grey[400]!,
    },
    {
      'id': '7',
      'name': 'Dedi Kurnia',
      'role': 'Staf Pengolahan Data',
      'avatar': 'https://i.pravatar.cc/150?img=7',
      'color': Colors.grey[400]!,
    },
    {
      'id': '8',
      'name': 'Sumarno',
      'role': 'Staf Logistik',
      'avatar': 'https://i.pravatar.cc/150?img=11',
      'color': Colors.grey[400]!,
    },
    {
      'id': '9',
      'name': 'Laily Sari',
      'role': 'Pengawas Mutu Senior',
      'avatar': 'https://i.pravatar.cc/150?img=20',
      'color': Colors.grey[400]!,
    },
    {
      'id': '10',
      'name': 'Hendra Wijaya',
      'role': 'Teknisi Laboratorium',
      'avatar': 'https://i.pravatar.cc/150?img=14',
      'color': Colors.grey[400]!,
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedParticipants = List.from(widget.selectedParticipants);
    _filteredParticipants = _allParticipants;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      if (_searchController.text.isEmpty) {
        _filteredParticipants = _allParticipants;
      } else {
        _filteredParticipants = _allParticipants.where((participant) {
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
        title: const Text(
          'Semua Pegawai',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
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
                style: const TextStyle(fontFamily: 'Poppins'),
                decoration: InputDecoration(
                  hintText: 'Cari Pegawai',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                    fontFamily: 'Poppins',
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

          // List of Participants
          Expanded(
            child: _filteredParticipants.isEmpty
                ? Center(
                    child: Text(
                      'Tidak ada pegawai ditemukan',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 14,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  )
                : ListView.builder(
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
                              // Avatar with colored border
                              Stack(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: participant['color'],
                                        width: 2,
                                      ),
                                    ),
                                    child: CircleAvatar(
                                      radius: 22,
                                      backgroundImage: NetworkImage(
                                        participant['avatar'],
                                      ),
                                      backgroundColor: Colors.grey.shade200,
                                    ),
                                  ),
                                  // Online indicator (green dot)
                                  if (index % 3 == 0) // Simulasi online status
                                    Positioned(
                                      right: 2,
                                      bottom: 2,
                                      child: Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF4CAF50),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                    ),
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
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      participant['role'],
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Checkbox
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

          // Bottom Button
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
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                        fontFamily: 'Poppins',
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
                    child: const Text(
                      'Simpan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontFamily: 'Poppins',
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
