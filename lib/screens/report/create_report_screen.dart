import 'package:flutter/material.dart';
import 'create_report_controller.dart';

class CreateReportScreen extends StatefulWidget {
  const CreateReportScreen({Key? key}) : super(key: key);

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final CreateReportController _controller = CreateReportController();

  @override
  void initState() {
    super.initState();
    // Mendengarkan perubahan state secara reaktif dari Controller
    _controller.addListener(_onStateChanged);
  }

  void _onStateChanged() {
    final state = _controller.state;

    // 4 & 5. FEEDBACK & NAVIGATION/RESULT
    if (state is ReportError) {
      // Feedback: Munculkan pesan error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.errorMessage),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (state is ReportSuccess) {
      // Feedback: Munculkan pesan sukses
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      // Navigation/Result: Tutup halaman pelaporan dan kirim nilai 'true'
      Navigator.pop(context, true);
    } else if (state is ReportLoading) {
      // Tutup keyboard saat sedang memuat
      FocusScope.of(context).unfocus();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onStateChanged);
    _controller.dispose();
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Laporan'),
        elevation: 0,
      ),
      // Menggunakan AnimatedBuilder untuk merender ulang UI hanya saat State berubah
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final state = _controller.state;
          final isLoading = state is ReportLoading;

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Detail Laporan',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _titleController,
                  enabled: !isLoading, // Disable input saat loading
                  decoration: InputDecoration(
                    labelText: 'Judul Laporan',
                    hintText: 'Contoh: Lampu Jalan Padam',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _descController,
                  enabled: !isLoading,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: 'Deskripsi',
                    hintText: 'Jelaskan kronologi atau lokasi detail...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null // Tombol mati saat loading
                        : () {
                            // Memicu EVENT saat tombol ditekan
                            _controller.dispatch(
                              SubmitReportEvent(
                                title: _titleController.text,
                                description: _descController.text,
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          )
                        : const Text(
                            'Kirim Laporan',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}