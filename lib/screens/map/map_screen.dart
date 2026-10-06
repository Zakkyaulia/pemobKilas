import 'package:flutter/material.dart';

import '../../theme/home_colors.dart';
import '../../theme/home_text_styles.dart';
import '../../widgets/map/map_view.dart';

/// Halaman peta dasar yang akan menampilkan sebaran hotspot laporan.
class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HomeColors.canvasBase,
      body: SafeArea(
        bottom: false, // Biarkan peta tembus ke bawah layar
        child: Column(
          children: [
            // Header sederhana
            Container(
              height: 64,
              width: double.infinity,
              color: HomeColors.surfacePure,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Peta Hotspot Laporan',
                style: HomeTextStyles.headlineMd,
              ),
            ),
            const Divider(
              height: 1, 
              thickness: 1, 
              color: HomeColors.surfaceContainer,
            ),
            
            // Komponen peta yang responsif dan mengisi ruang
            const Expanded(
              child: MapView(),
            ),
          ],
        ),
      ),
    );
  }
}
