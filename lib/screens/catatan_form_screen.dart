import 'package:flutter/material.dart';
import '../utils/validators.dart';

class CatatanFormScreen extends StatefulWidget {
  const CatatanFormScreen({super.key});

  @override
  State<CatatanFormScreen> createState() => _CatatanFormScreenState();
}

class _CatatanFormScreenState extends State<CatatanFormScreen> {
  // (1) key untuk Form dan controller untuk input catatan
  final _formKey = GlobalKey<FormState>();
  final _catatanController = TextEditingController();

  // (2) buang controller saat layar ditutup
  @override
  void dispose() {
    _catatanController.dispose();
    super.dispose();
  }

  // (3) validasi dan kirim data catatan balik ke layar sebelumnya
  void _simpan() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    // Tutup layar ini sambil MEMBAWA teks catatan ke layar sebelumnya
    Navigator.pop(context, _catatanController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    // Menggunakan PopScope dan onPopInvokedWithResult sesuai ketentuan teknis Flutter terbaru
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        // Penanganan pop normal
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Tulis Catatan')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _catatanController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Catatan',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      Validators.minLength(value, 5, fieldName: 'Catatan'),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _simpan,
                  child: const Text('Simpan'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
