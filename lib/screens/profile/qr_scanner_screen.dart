import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../theme/home_colors.dart';
import '../../theme/home_text_styles.dart';

/// Layar pemindai kamera QR profil real-time menggunakan [MobileScanner].
class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  bool _isScanned = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isScanned) return;
    for (final barcode in capture.barcodes) {
      final raw = barcode.rawValue;
      if (raw != null && raw.trim().isNotEmpty) {
        _isScanned = true;
        HapticFeedback.mediumImpact();
        Navigator.of(context).pop(raw.trim());
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scanAreaSize = size.width * 0.70;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Pindai QR Profil',
          style: HomeTextStyles.labelLg.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on_rounded, color: Colors.white),
            tooltip: 'Flash',
            onPressed: () => _controller.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios_rounded, color: Colors.white),
            tooltip: 'Ganti Kamera',
            onPressed: () => _controller.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Live camera stream
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),

          // Semi-transparent overlay with center cutout
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withValues(alpha: 0.55),
              BlendMode.srcOut,
            ),
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                    backgroundBlendMode: BlendMode.dstOut,
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: scanAreaSize,
                    height: scanAreaSize,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Viewfinder borders
          Container(
            width: scanAreaSize,
            height: scanAreaSize,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: HomeColors.primaryContainer, width: 2),
            ),
            child: Stack(
              children: [
                Positioned(top: 8, left: 8, child: _buildCorner(true, true)),
                Positioned(top: 8, right: 8, child: _buildCorner(true, false)),
                Positioned(bottom: 8, left: 8, child: _buildCorner(false, true)),
                Positioned(bottom: 8, right: 8, child: _buildCorner(false, false)),
              ],
            ),
          ),

          // Instructions at bottom
          Positioned(
            bottom: 50,
            left: 24,
            right: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.75),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white12),
              ),
              child: Text(
                'Arahkan kamera ke kode QR profil mahasiswa UNAND untuk membuka profil secara langsung.',
                textAlign: TextAlign.center,
                style: HomeTextStyles.bodySm.copyWith(
                  color: Colors.white,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorner(bool isTop, bool isLeft) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        border: Border(
          top: isTop
              ? const BorderSide(color: Colors.white, width: 3.5)
              : BorderSide.none,
          bottom: !isTop
              ? const BorderSide(color: Colors.white, width: 3.5)
              : BorderSide.none,
          left: isLeft
              ? const BorderSide(color: Colors.white, width: 3.5)
              : BorderSide.none,
          right: !isLeft
              ? const BorderSide(color: Colors.white, width: 3.5)
              : BorderSide.none,
        ),
      ),
    );
  }
}

