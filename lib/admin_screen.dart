import 'package:flutter/material.dart';
import 'package:simoni/input_pegawai_screen.dart';
import 'dart:io';

class AdminScreen extends StatefulWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _selectedTabIndex = 0;

  final List<PegawaiModel> _pegawaiList = [];
  final List<PegawaiModel> _deletedPegawaiList = [];

  void _navigateToInputPegawai() async {
    final newPegawai = await Navigator.push<PegawaiModel>(
      context,
      MaterialPageRoute(builder: (context) => const InputPegawaiScreen()),
    );

    if (newPegawai != null) {
      setState(() {
        _pegawaiList.add(newPegawai);
        _selectedTabIndex = 0;
      });
    }
  }

  void _hapusPegawai(PegawaiModel pegawai) {
    setState(() {
      _pegawaiList.remove(pegawai);
      _deletedPegawaiList.add(pegawai);
    });
  }

  void _pulihkanPegawai(PegawaiModel pegawai) {
    setState(() {
      _deletedPegawaiList.remove(pegawai);
      _pegawaiList.add(pegawai);
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isSemuaPegawai = _selectedTabIndex == 0;
    final listToShow = isSemuaPegawai ? _pegawaiList : _deletedPegawaiList;
    final bool isEmpty = listToShow.isEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 24.0, 20.0, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: 32.0),
              _buildCustomToggle(),
              const SizedBox(height: 24.0),
              if (!isEmpty) ...[
                _buildSearchBarAndFilter(),
                const SizedBox(height: 24.0),
              ],
              Expanded(
                child: isEmpty
                    ? Center(
                        child: Text(
                          "Belum Ada Pegawai Yang Diinput",
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 16.0,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        itemCount: listToShow.length,
                        itemBuilder: (context, index) {
                          final pegawai = listToShow[index];
                          return _buildPegawaiTile(pegawai, isSemuaPegawai);
                        },
                      ),
              ),
              if (isEmpty) const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0, top: 16.0),
                child: _buildInputButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPegawaiTile(PegawaiModel pegawai, bool isSemuaPegawai) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 24.0,
                backgroundImage: pegawai.profileImage != null
                    ? FileImage(pegawai.profileImage!)
                    : const AssetImage('assets/images/profile_avatar.png')
                          as ImageProvider,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 10.0,
                  height: 10.0,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pegawai.nama,
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  pegawai.posisi,
                  style: TextStyle(fontSize: 14.0, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16.0),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: IconButton(
              icon: Icon(
                isSemuaPegawai ? Icons.cloud_outlined : Icons.restore,
                color: Colors.grey[600],
                size: 20.0,
              ),
              onPressed: () {
                if (!isSemuaPegawai) {
                  _pulihkanPegawai(pegawai);
                }
              },
            ),
          ),
          const SizedBox(width: 8.0),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: IconButton(
              icon: Icon(
                Icons.delete_outline,
                color: Colors.red[400],
                size: 20.0,
              ),
              onPressed: () {
                if (isSemuaPegawai) {
                  _hapusPegawai(pegawai);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBarAndFilter() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30.0),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Cari",
                hintStyle: TextStyle(color: Colors.grey[500]),
                prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 14.0,
                  horizontal: 8.0,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12.0),
        GestureDetector(
          onTap: () {},
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30.0),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Icon(Icons.swap_vert, color: Colors.grey[700]),
                const SizedBox(width: 8.0),
                Text(
                  "Urutkan",
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Selamat Datang, Admin!",
                style: TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 6.0),
              Text(
                "Ayo kelola dan lacak karyawan dengan cara\nyang paling efisien",
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.black,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Stack(
          clipBehavior: Clip.none,
          children: [
            const CircleAvatar(
              radius: 26.0,
              backgroundImage: AssetImage('assets/images/profile_avatar.png'),
            ),
            Positioned(
              bottom: 2,
              right: 2,
              child: Container(
                width: 12.0,
                height: 12.0,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2.0),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCustomToggle() {
    return Container(
      height: 48.0,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(30.0),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildToggleItem(
              text: "Semua Pegawai",
              isSelected: _selectedTabIndex == 0,
              onTap: () {
                setState(() {
                  _selectedTabIndex = 0;
                });
              },
            ),
          ),
          Expanded(
            child: _buildToggleItem(
              text: "Baru Terhapus",
              isSelected: _selectedTabIndex == 1,
              onTap: () {
                setState(() {
                  _selectedTabIndex = 1;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleItem({
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final Color selectedColor = Colors.grey[700]!;
    final Color unselectedTextColor = Colors.grey[600]!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : Colors.transparent,
          borderRadius: BorderRadius.circular(30.0),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? Colors.white : unselectedTextColor,
              fontWeight: FontWeight.w600,
              fontSize: 14.0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputButton() {
    return FilledButton(
      onPressed: _navigateToInputPegawai,
      style: FilledButton.styleFrom(
        backgroundColor: Colors.grey[700],
        padding: const EdgeInsets.symmetric(vertical: 18.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
      ),
      child: const Text(
        "Input Pegawai",
        style: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
