import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../theme/home_colors.dart';
import '../../theme/home_text_styles.dart';
import 'dummy_map_data.dart';

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
  ReportGeoData? _selectedReport;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    // Membaca dari data eksternal (mirip source.setData() di MapLibre)
    _reports = _use1000Points 
        ? DummyMapData.generateDummyReports(1000) 
        : DummyMapData.basicReports;
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
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
              // Tutup popup jika klik area kosong
              if (_selectedReport != null) {
                setState(() => _selectedReport = null);
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
            // Layer Kepadatan & Titik Individual (Diambil alih oleh _MapLayers)
            _MapLayers(
              reports: _reports,
              onReportTap: (report) {
                setState(() => _selectedReport = report);
              },
            ),
            const RichAttributionWidget(
              alignment: AttributionAlignment.bottomLeft,
              attributions: [
                TextSourceAttribution('© OpenStreetMap contributors'),
              ],
            ),
          ],
        ),
        
        // Popup Tooltip Ringan
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
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: HomeColors.surfacePure,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: HomeColors.primary, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(report.title, style: HomeTextStyles.labelLg.copyWith(color: HomeColors.onSurface)),
                  const SizedBox(height: 2),
                  Text(report.category, style: HomeTextStyles.bodySm.copyWith(color: HomeColors.onSurfaceVariant)),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              onPressed: () => setState(() => _selectedReport = null),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            )
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
              Text('Sedikit', style: HomeTextStyles.bodySm.copyWith(fontSize: 10)),
              const SizedBox(width: 4),
              Container(
                width: 60,
                height: 8,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.yellow, Colors.orange, Colors.red, Color(0xFF8B0000)],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 4),
              Text('Banyak', style: HomeTextStyles.bodySm.copyWith(fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
}

/// Widget perantara untuk membaca nilai zoom peta saat ini.
class _MapLayers extends StatelessWidget {
  final List<ReportGeoData> reports;
  final void Function(ReportGeoData) onReportTap;

  const _MapLayers({required this.reports, required this.onReportTap});

  @override
  Widget build(BuildContext context) {
    final camera = MapCamera.of(context);
    final currentZoom = camera.zoom;
    
    // 1. Hitung radius heatmap yang diinterpolasi dari zoom (mirip heatmap-radius)
    // Di zoom 14 -> 16px, di zoom 18 -> 60px
    final double heatRadius = 16.0 + ((currentZoom - 14.0) / 4.0) * 44.0;
    
    // 2. Hitung intensitas warna (opacity)
    // Makin dekat zoom, makin transparan agar nama jalan terlihat
    final double heatOpacity = (1.1 - ((currentZoom - 14.0) / 4.0)).clamp(0.4, 0.8);
    
    // 3. Tampilkan titik pin/lingkaran padat individual HANYA pada zoom >= 17
    final bool showPoints = currentZoom >= 16.5;

    return Stack(
      children: [
        // LAYER 1: Simulasi Heatmap dari GeoJSON
        MarkerLayer(
          markers: reports.map((report) {
            return Marker(
              point: report.position,
              width: heatRadius * 2,
              height: heatRadius * 2,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  // Menggunakan radial gradient untuk mensimulasikan ramp heatmap
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF8B0000).withOpacity(heatOpacity),      // Merah pekat inti
                      Colors.red.withOpacity(heatOpacity * 0.7),
                      Colors.orange.withOpacity(heatOpacity * 0.4),
                      Colors.yellow.withOpacity(heatOpacity * 0.1),
                      Colors.transparent,                                    // Transparan di pinggir
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
              return Marker(
                point: report.position,
                width: 16,
                height: 16,
                child: GestureDetector(
                  onTap: () => onReportTap(report),
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: HomeColors.statusFacility, // Warna titik solid
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}
