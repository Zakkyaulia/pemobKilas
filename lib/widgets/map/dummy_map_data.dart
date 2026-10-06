import 'dart:math';
import 'package:latlong2/latlong.dart';

class ReportGeoData {
  final String id;
  final String title;
  final String category;
  final LatLng position;
  final double weight;

  ReportGeoData({
    required this.id,
    required this.title,
    required this.category,
    required this.position,
    this.weight = 1.0,
  });
}

class DummyMapData {
  // Pusat kampus Unand
  static const double _baseLat = -0.9142;
  static const double _baseLng = 100.4608;

  // 6 Titik sesuai spesifikasi (3 kawasan)
  static final List<ReportGeoData> basicReports = [
    // Kawasan A: 3 titik berdekatan (Paling pekat)
    ReportGeoData(id: 'A1', title: 'Jalan Rusak A1', category: 'Infrastruktur', position: const LatLng(-0.915111, 100.460693)),
    ReportGeoData(id: 'A2', title: 'Lampu Mati A2', category: 'Fasilitas', position: const LatLng(-0.915211, 100.460793)),
    ReportGeoData(id: 'A3', title: 'Pohon Tumbang A3', category: 'Lingkungan', position: const LatLng(-0.915011, 100.460593)),
    
    // Kawasan B: 2 titik berdekatan (Warna sedang)
    ReportGeoData(id: 'B1', title: 'Parkir Liar B1', category: 'Ketertiban', position: const LatLng(-0.914103, 100.458218)),
    ReportGeoData(id: 'B2', title: 'Sampah Menumpuk B2', category: 'Kebersihan', position: const LatLng(-0.914203, 100.458318)),
    
    // Kawasan C: 1 titik tunggal (Paling terang/dingin)
    ReportGeoData(id: 'C1', title: 'Gedung Bocor C1', category: 'Fasilitas', position: const LatLng(-0.912869, 100.462183)),
  ];

  /// Generator untuk 1000 titik simulasi skalabilitas (beban berat).
  static List<ReportGeoData> generateDummyReports([int count = 1000]) {
    final random = Random(42); // Seed tetap agar pola konsisten
    final List<ReportGeoData> reports = [];
    
    // Pusat kerumunan (clusters)
    final clusters = [
      const LatLng(-0.915111, 100.460693),
      const LatLng(-0.914103, 100.458218),
      const LatLng(-0.912869, 100.462183),
      const LatLng(-0.916000, 100.465000), // Rektorat area
    ];

    for (int i = 0; i < count; i++) {
      // 80% laporan berada di sekitar pusat kerumunan, 20% tersebar acak (noise)
      LatLng pos;
      if (random.nextDouble() < 0.8) {
        final center = clusters[random.nextInt(clusters.length)];
        // Radius kerumunan sekitar ~50-100 meter (0.0005 - 0.001 derajat)
        final latOffset = (random.nextDouble() - 0.5) * 0.0015;
        final lngOffset = (random.nextDouble() - 0.5) * 0.0015;
        pos = LatLng(center.latitude + latOffset, center.longitude + lngOffset);
      } else {
        // Tersebar acak di kawasan kampus
        final latOffset = (random.nextDouble() - 0.5) * 0.01;
        final lngOffset = (random.nextDouble() - 0.5) * 0.01;
        pos = LatLng(_baseLat + latOffset, _baseLng + lngOffset);
      }

      reports.add(
        ReportGeoData(
          id: 'RPT-$i',
          title: 'Laporan Simulasi #$i',
          category: 'Kategori ${random.nextInt(5) + 1}',
          position: pos,
        ),
      );
    }
    return reports;
  }
}
