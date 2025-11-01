import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PegawaiModel {
  final String nama;
  final String id;
  final String posisi;
  final File? profileImage;

  PegawaiModel({
    required this.nama,
    required this.id,
    required this.posisi,
    this.profileImage,
  });
}

class InputPegawaiScreen extends StatefulWidget {
  const InputPegawaiScreen({Key? key}) : super(key: key);

  @override
  State<InputPegawaiScreen> createState() => _InputPegawaiScreenState();
}

class _InputPegawaiScreenState extends State<InputPegawaiScreen> {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _posisiController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final ImagePicker _picker = ImagePicker();
  File? _profileImage;

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _simpanData() async {
    bool isFormValid = _formKey.currentState!.validate();
    bool isImagePicked = _profileImage != null;

    if (!isImagePicked && isFormValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Harap unggah profile pegawai."),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (isFormValid && isImagePicked) {
      final newPegawai = PegawaiModel(
        nama: _namaController.text,
        id: _idController.text,
        posisi: _posisiController.text,
        profileImage: _profileImage,
      );

      bool dialogClosed = false;
      final navigator = Navigator.of(context);

      await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext dialogContext) {
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted && !dialogClosed) {
              Navigator.of(dialogContext).pop();
            }
          });
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Container(
              padding: const EdgeInsets.all(32.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey[300]!, width: 2),
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.black87,
                      size: 50,
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  const Text(
                    "Tersimpan!",
                    style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    "Data Pegawai Berhasil Tersimpan.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16.0, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          );
        },
      ).then((_) => dialogClosed = true);

      if (mounted) {
        navigator.pop(newPegawai);
      }
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _idController.dispose();
    _posisiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.grey[50],
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: const Icon(
                Icons.chevron_left,
                color: Colors.black,
                size: 30,
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 0, 24.0, 32.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Data Pegawai",
                  style: TextStyle(
                    fontSize: 28.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  "Masukkan data pegawai yang ingin ditambahkan",
                  style: TextStyle(fontSize: 15.0, color: Colors.grey[600]),
                ),
                const SizedBox(height: 32.0),
                _buildFormLabel("Nama Pegawai"),
                const SizedBox(height: 8.0),
                _buildTextFormField(controller: _namaController, hintText: ""),
                const SizedBox(height: 24.0),
                _buildFormLabel("ID Pegawai"),
                const SizedBox(height: 8.0),
                _buildTextFormField(
                  controller: _idController,
                  hintText: "",
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 24.0),
                _buildFormLabel("Posisi"),
                const SizedBox(height: 8.0),
                _buildTextFormField(
                  controller: _posisiController,
                  hintText: "",
                ),
                const SizedBox(height: 24.0),
                _buildFormLabel("Unggah Profile Pegawai"),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    _buildUploadButton(
                      icon: Icons.camera_alt_outlined,
                      text: "Ambil Gambar",
                      onTap: () => _pickImage(ImageSource.camera),
                    ),
                    const SizedBox(width: 16.0),
                    _buildUploadButton(
                      icon: Icons.image_outlined,
                      text: "Unggah Gambar",
                      onTap: () => _pickImage(ImageSource.gallery),
                    ),
                  ],
                ),
                if (_profileImage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.file(
                          _profileImage!,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 72.0),
                FilledButton(
                  onPressed: _simpanData,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.grey[700],
                    padding: const EdgeInsets.symmetric(vertical: 18.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  child: const Text(
                    "Simpan Data Pegawai",
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormLabel(String text) {
    return RichText(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        children: const [
          TextSpan(
            text: " *",
            style: TextStyle(
              color: Colors.red,
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[400]),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.grey[800]!),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Kolom ini tidak boleh kosong";
        }
        return null;
      },
    );
  }

  Widget _buildUploadButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.grey[700], size: 32.0),
              const SizedBox(height: 12.0),
              Text(
                text,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
