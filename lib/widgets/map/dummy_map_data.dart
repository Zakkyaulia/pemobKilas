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

  // 18 Titik sesuai laporan di feed (mock_reports.dart)
  static final List<ReportGeoData> basicReports = [
    // post-1: Ghezy — AC Ruang Kuliah GKB C
    ReportGeoData(
      id: 'post-1',
      title: 'AC Ruang Kuliah GKB C 204 bocor & tidak dingin',
      category: 'Kondisi Kampus',
      position: const LatLng(-0.914203, 100.461021),
    ),
    // post-2: Aziz — Genangan air PKM
    ReportGeoData(
      id: 'post-2',
      title: 'Genangan air hujan & dahan patah menutup bahu jalan PKM',
      category: 'Kondisi Kampus',
      position: const LatLng(-0.913540, 100.458920),
    ),
    // post-3: Biro Umum — Maintenance Lift Rektorat
    ReportGeoData(
      id: 'post-3',
      title: 'Maintenance Lift Gedung Rektorat Sayap Kanan',
      category: 'Info Penting',
      position: const LatLng(-0.914820, 100.460115),
    ),
    // post-4: Fadhil — Lampu Jalan Padam FTI
    ReportGeoData(
      id: 'post-4',
      title: 'Lampu penerangan jalan utama dekat FTI mati total',
      category: 'Kondisi Kampus',
      position: const LatLng(-0.915512, 100.457890),
    ),
    // post-5: Putri — Proyektor Rusak Gedung E
    ReportGeoData(
      id: 'post-5',
      title: 'Kabel HDMI & Proyektor Ruang E 102 rusak bergaris',
      category: 'Kondisi Kampus',
      position: const LatLng(-0.914102, 100.459340),
    ),
    // post-6: Diki — Sampah Kantin Gedung I
    ReportGeoData(
      id: 'post-6',
      title: 'Tempat sampah kantin penuh dan meluap ke area makan',
      category: 'Kondisi Kampus',
      position: const LatLng(-0.916210, 100.462150),
    ),
    // post-7: BEM — Jadwal Bus Kampus
    ReportGeoData(
      id: 'post-7',
      title: 'Penambahan Rute & Jam Operasional Bus Kampus UNAND',
      category: 'Info Penting',
      position: const LatLng(-0.912450, 100.456780),
    ),
    // post-8: Rian — Kran Air Toilet Perpustakaan
    ReportGeoData(
      id: 'post-8',
      title: 'Kran wastafel toilet patah dan air terus mengalir',
      category: 'Kondisi Kampus',
      position: const LatLng(-0.913980, 100.460890),
    ),
    // post-9: Siti — Jalan Berlubang Asrama Maninjau
    ReportGeoData(
      id: 'post-9',
      title: 'Lubang cukup dalam di tikungan asrama putri',
      category: 'Kondisi Kampus',
      position: const LatLng(-0.917120, 100.458210),
    ),
    // post-10: UPT Perpustakaan — Bebas Pustaka Online
    ReportGeoData(
      id: 'post-10',
      title: 'Pelayanan Bebas Pustaka & Unggah Mandiri Skripsi Online',
      category: 'Info Penting',
      position: const LatLng(-0.913890, 100.460750),
    ),
    // post-11: Ilham — Stopkontak Korslet Lab F
    ReportGeoData(
      id: 'post-11',
      title: 'Stopkontak meja baris ketiga Lab F-203 korslet',
      category: 'Kondisi Kampus',
      position: const LatLng(-0.914990, 100.457630),
    ),
    // post-12: Nabila — Pintu Toilet Rusak Gedung Pancasila
    ReportGeoData(
      id: 'post-12',
      title: 'Kunci selot pintu toilet wanita bilik 1 lepas',
      category: 'Kondisi Kampus',
      position: const LatLng(-0.913210, 100.459800),
    ),
    // post-13: KSR PMI — Donor Darah PKM
    ReportGeoData(
      id: 'post-13',
      title: 'Aksi Donor Darah Sukarela Dies Natalis UNAND',
      category: 'Info Penting',
      position: const LatLng(-0.913480, 100.458850),
    ),
    // post-14: Bayu — Pohon Tumbang Lapangan Futsal
    ReportGeoData(
      id: 'post-14',
      title: 'Dahan pohon kelapa patah menimpa pagar pembatas lapangan',
      category: 'Kondisi Kampus',
      position: const LatLng(-0.916800, 100.459990),
    ),
    // post-15: Tari — Air Keruh Gedung H
    ReportGeoData(
      id: 'post-15',
      title: 'Air kran wudhu gedung H berwarna kecokelatan',
      category: 'Kondisi Kampus',
      position: const LatLng(-0.914560, 100.461900),
    ),
    // post-16: LPPM — Hibah Riset Mahasiswa
    ReportGeoData(
      id: 'post-16',
      title: 'Pembukaan Proposal Hibah Riset & Pengabdian Kolaboratif',
      category: 'Info Penting',
      position: const LatLng(-0.914750, 100.460200),
    ),
    // post-17: Kevin — Wifi Rusak Plaza
    ReportGeoData(
      id: 'post-17',
      title: 'Access Point wifi @unand.ac.id di Plaza tidak ada koneksi',
      category: 'Kondisi Kampus',
      position: const LatLng(-0.913700, 100.459500),
    ),
    // post-18: LPTIK — Maintenance Server Portal Akademik
    ReportGeoData(
      id: 'post-18',
      title: 'Jadwal Pemeliharaan Rutin Server Portal Akademik & SIA',
      category: 'Info Penting',
      position: const LatLng(-0.915200, 100.458600),
    ),
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
