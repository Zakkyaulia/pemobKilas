import 'package:flutter/material.dart';

import '../../data/laporan_repository.dart';
import '../../models/laporan.dart';
import '../../routes/app_routes.dart';
import '../../widgets/state_views.dart';

enum ViewStatus { loading, success, error }

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _repository = LaporanRepository();
  ViewStatus _status = ViewStatus.loading;
  List<Laporan> _items = [];
  String _errorMessage = '';
  final bool _simulateError = false; // Ubah ke true untuk uji coba error

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    if (_status != ViewStatus.loading) {
      setState(() => _status = ViewStatus.loading);
    }
    try {
      final items = await _repository.fetchItems(simulateError: _simulateError);
      if (!mounted) return;
      setState(() {
        _items = items;
        _status = ViewStatus.success;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _status = ViewStatus.error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('KILAS UNAND', style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 16)),
            Text('Limau Manis', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    return switch (_status) {
      ViewStatus.loading => const LoadingView(),
      ViewStatus.error => ErrorView(message: _errorMessage, onRetry: _loadItems),
      ViewStatus.success => _buildSuccessView(),
    };
  }

  Widget _buildSuccessView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Kartu Profil (Sederhana)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              CircleAvatar(radius: 32, backgroundColor: Colors.blueAccent),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Zakky Aulia Aldrin', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    Text('NIM: 2311522018', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text('Laporan Tersimpan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 12),
        if (_items.isEmpty)
          const EmptyView(message: 'Belum ada data laporan.')
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _items.length,
            itemBuilder: (context, index) {
              final item = _items[index];
              return Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(item.judul, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${item.lokasi}\n+${item.dukungan} Dukungan'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.detail,
                      arguments: item,
                    );
                  },
                ),
              );
            },
          ),
      ],
    );
  }
}
