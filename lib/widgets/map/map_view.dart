import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../theme/home_colors.dart';
import '../../theme/home_text_styles.dart';
import 'dummy_map_data.dart';

// Ambang jarak (dalam derajat) untuk mengelompokkan pin yang saling berdekatan.
// ~0.0005° ≈ 55 meter. Pin yang lebih dekat dari ini dianggap satu klaster.
const double _kClusterThresholdDeg = 0.0005;

/// Menghitung jarak Euclidean sederhana antara dua koordinat (dalam derajat).
double _distanceDeg(LatLng a, LatLng b) {
  final dLat = a.latitude - b.latitude;
  final dLng = a.longitude - b.longitude;
  return sqrt(dLat * dLat + dLng * dLng);
}

/// Mengembalikan semua laporan yang berada dalam radius [_kClusterThresholdDeg]
/// dari [center], termasuk [center] itu sendiri.
List<ReportGeoData> _findCluster(
  ReportGeoData center,
  List<ReportGeoData> all,
) {
  return all
      .where((r) => _distanceDeg(r.position, center.position) <= _kClusterThresholdDeg)
      .toList();
}

/// Komponen peta yang menampilkan heatmap kepadatan laporan.
class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  late final MapController _mapController;

  // TOGGLE SIMULASI: Ubah menjadi true untuk menguji performa 1000 titik.
  final bool _use1000Points = false;

  late final List<ReportGeoData> _reports;

  /// Laporan yang sedang aktif ditampilkan di tooltip.
  ReportGeoData? _selectedReport;

  /// Klaster (grup laporan berdekatan) dari laporan yang dipilih.
  /// Berisi ≥1 elemen; jika hanya 1, tidak ada tombol navigasi.
  List<ReportGeoData> _cluster = [];

  /// Indeks laporan aktif di dalam [_cluster].
  int _clusterIndex = 0;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _reports = _use1000Points
        ? DummyMapData.generateDummyReports(1000)
        : DummyMapData.basicReports;
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  /// Dipanggil saat pengguna mengetuk sebuah pin.
  void _onPinTap(ReportGeoData tapped) {
    final cluster = _findCluster(tapped, _reports);
    // Pastikan urutan konsisten: urutkan berdasarkan id agar navigasi stabil.
    cluster.sort((a, b) => a.id.compareTo(b.id));
    final idx = cluster.indexWhere((r) => r.id == tapped.id);
    setState(() {
      _cluster = cluster;
      _clusterIndex = idx < 0 ? 0 : idx;
      _selectedReport = _cluster[_clusterIndex];
    });
  }

  /// Navigasi ke laporan sebelumnya dalam klaster.
  void _prevInCluster() {
    setState(() {
      _clusterIndex = (_clusterIndex - 1 + _cluster.length) % _cluster.length;
      _selectedReport = _cluster[_clusterIndex];
    });
  }

  /// Navigasi ke laporan berikutnya dalam klaster.
  void _nextInCluster() {
    setState(() {
      _clusterIndex = (_clusterIndex + 1) % _cluster.length;
      _selectedReport = _cluster[_clusterIndex];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: const LatLng(-0.9142, 100.4608),
            initialZoom: 15.0,
            minZoom: 14.0,
            maxZoom: 18.0,
            cameraConstraint: CameraConstraint.contain(
              bounds: LatLngBounds(
                const LatLng(-0.9350, 100.4400),
                const LatLng(-0.9000, 100.4800),
              ),
            ),
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all,
            ),
            onTap: (_, __) {
              if (_selectedReport != null) {
                setState(() {
                  _selectedReport = null;
                  _cluster = [];
                });
              }
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.pemob_kilas',
              errorTileCallback: (tile, error, stackTrace) {
                debugPrint('Gagal memuat tile: $error');
              },
            ),
            // Layer Kepadatan & Titik Individual
            _MapLayers(
              reports: _reports,
              selectedReportId: _selectedReport?.id,
              onReportTap: _onPinTap,
            ),
            const RichAttributionWidget(
              alignment: AttributionAlignment.bottomLeft,
              attributions: [
                TextSourceAttribution('© OpenStreetMap contributors'),
              ],
            ),
          ],
        ),

        // Tooltip laporan yang dipilih
        if (_selectedReport != null)
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: _buildTooltip(_selectedReport!),
          ),

        // Legenda Kepadatan
        Positioned(
          bottom: 24,
          right: 16,
          child: _buildLegend(),
        ),
      ],
    );
  }

  Widget _buildTooltip(ReportGeoData report) {
    final hasCluster = _cluster.length > 1;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: HomeColors.surfacePure,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Baris utama: ikon info + teks + tutup ─────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ikon kategori (warna berbeda sesuai kategori)
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _categoryColor(report.category).withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _categoryIcon(report.category),
                    color: _categoryColor(report.category),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.title,
                        style: HomeTextStyles.labelLg
                            .copyWith(color: HomeColors.onSurface),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      // Badge kategori
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _categoryColor(report.category)
                              .withOpacity(0.10),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(
                          report.category,
                          style: HomeTextStyles.bodySm.copyWith(
                            color: _categoryColor(report.category),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Tombol tutup
                GestureDetector(
                  onTap: () => setState(() {
                    _selectedReport = null;
                    _cluster = [];
                  }),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: HomeColors.surfaceContainer,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close,
                        size: 14, color: HomeColors.onSurfaceVariant),
                  ),
                ),
              ],
            ),

            // ── Navigasi klaster (hanya muncul jika ada pin yang berdekatan) ──
            if (hasCluster) ...[
              const SizedBox(height: 10),
              Container(
                height: 1,
                color: HomeColors.surfaceContainer,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  // Tombol sebelumnya
                  _ClusterNavButton(
                    icon: Icons.chevron_left_rounded,
                    onTap: _prevInCluster,
                    tooltip: 'Laporan sebelumnya',
                  ),
                  const SizedBox(width: 8),
                  // Indikator posisi (dot stepper)
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          '${_clusterIndex + 1} dari ${_cluster.length} laporan di area ini',
                          style: HomeTextStyles.bodySm.copyWith(
                            color: HomeColors.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 5),
                        // Dot stepper
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(_cluster.length, (i) {
                            final isActive = i == _clusterIndex;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: isActive ? 16 : 6,
                              height: 6,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 2),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? HomeColors.primary
                                    : HomeColors.outlineVariant,
                                borderRadius: BorderRadius.circular(99),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Tombol berikutnya
                  _ClusterNavButton(
                    icon: Icons.chevron_right_rounded,
                    onTap: _nextInCluster,
                    tooltip: 'Laporan berikutnya',
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: HomeColors.surfacePure.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Kepadatan', style: HomeTextStyles.labelSm),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Sedikit',
                  style: HomeTextStyles.bodySm.copyWith(fontSize: 10)),
              const SizedBox(width: 4),
              Container(
                width: 60,
                height: 8,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Colors.yellow,
                      Colors.orange,
                      Colors.red,
                      Color(0xFF8B0000)
                    ],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 4),
              Text('Banyak',
                  style: HomeTextStyles.bodySm.copyWith(fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  /// Warna aksen berdasarkan kategori laporan.
  Color _categoryColor(String category) {
    if (category == 'Info Penting') return HomeColors.primaryContainer;
    return HomeColors.statusCondition; // 'Kondisi Kampus' dan default
  }

  /// Ikon berdasarkan kategori laporan.
  IconData _categoryIcon(String category) {
    if (category == 'Info Penting') return Icons.campaign_outlined;
    return Icons.report_problem_outlined; // 'Kondisi Kampus' dan default
  }
}

// ─────────────────────────────────────────────────────────────────────────────

/// Tombol navigasi klaster (kiri / kanan).
class _ClusterNavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;

  const _ClusterNavButton({
    required this.icon,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: HomeColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: HomeColors.outlineVariant, width: 1),
          ),
          child: Icon(icon, size: 22, color: HomeColors.primary),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

/// Widget perantara untuk membaca nilai zoom peta saat ini.
class _MapLayers extends StatelessWidget {
  final List<ReportGeoData> reports;
  final String? selectedReportId;
  final void Function(ReportGeoData) onReportTap;

  const _MapLayers({
    required this.reports,
    required this.selectedReportId,
    required this.onReportTap,
  });

  @override
  Widget build(BuildContext context) {
    final camera = MapCamera.of(context);
    final currentZoom = camera.zoom;

    // 1. Hitung radius heatmap yang diinterpolasi dari zoom (mirip heatmap-radius)
    // Di zoom 14 -> 16px, di zoom 18 -> 60px
    final double heatRadius = 16.0 + ((currentZoom - 14.0) / 4.0) * 44.0;

    // 2. Hitung intensitas warna (opacity)
    // Makin dekat zoom, makin transparan agar nama jalan terlihat
    final double heatOpacity =
        (1.1 - ((currentZoom - 14.0) / 4.0)).clamp(0.4, 0.8);

    // 3. Tampilkan titik pin/lingkaran padat individual HANYA pada zoom >= 16.5
    final bool showPoints = currentZoom >= 16.5;

    return Stack(
      children: [
        // LAYER 1: Simulasi Heatmap
        MarkerLayer(
          markers: reports.map((report) {
            return Marker(
              point: report.position,
              width: heatRadius * 2,
              height: heatRadius * 2,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF8B0000).withOpacity(heatOpacity),
                      Colors.red.withOpacity(heatOpacity * 0.7),
                      Colors.orange.withOpacity(heatOpacity * 0.4),
                      Colors.yellow.withOpacity(heatOpacity * 0.1),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.2, 0.5, 0.8, 1.0],
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        // LAYER 2: Titik Individu (Point/Circle)
        if (showPoints)
          MarkerLayer(
            markers: reports.map((report) {
              final isSelected = report.id == selectedReportId;
              return Marker(
                point: report.position,
                // Pin yang terpilih sedikit lebih besar agar ada ruang untuk ring
                width: isSelected ? 28 : 20,
                height: isSelected ? 28 : 20,
                child: GestureDetector(
                  onTap: () => onReportTap(report),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    width: isSelected ? 26 : 16,
                    height: isSelected ? 26 : 16,
                    decoration: BoxDecoration(
                      // Pin terpilih: putih di tengah + ring biru tebal
                      // Pin normal: merah solid
                      color: isSelected
                          ? HomeColors.surfacePure
                          : HomeColors.statusFacility,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: HomeColors.primary, width: 3)
                          : Border.all(color: Colors.white, width: 2),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: HomeColors.primary.withOpacity(0.4),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ]
                          : const [
                              BoxShadow(
                                  color: Colors.black26, blurRadius: 4),
                            ],
                    ),
                    // Titik inti di dalam pin yang terpilih
                    child: isSelected
                        ? Center(
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: HomeColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          )
                        : null,
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}
