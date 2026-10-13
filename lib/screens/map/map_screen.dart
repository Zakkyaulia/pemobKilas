import 'package:flutter/material.dart';

import '../../theme/app_palette.dart';
import '../../theme/home_text_styles.dart';
import '../../widgets/map/map_view.dart';

/// Halaman peta dasar yang akan menampilkan sebaran hotspot laporan.
class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.canvas(context),
      body: SafeArea(
        bottom: false, // Biarkan peta tembus ke bawah layar
        child: Column(
          children: [
            // Header sederhana
            Container(
              height: 64,
              width: double.infinity,
              color: AppPalette.surface(context),
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Peta Hotspot Laporan',
                style: HomeTextStyles.headlineMd.copyWith(
                  color: AppPalette.textPrimary(context),
                ),
              ),
            ),
            Divider(
              height: 1, 
              thickness: 1, 
              color: AppPalette.divider(context),
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
