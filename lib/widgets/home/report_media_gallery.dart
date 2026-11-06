import 'package:flutter/material.dart';

import '../../theme/app_palette.dart';
import '../../theme/home_colors.dart';
import 'network_image_box.dart';
import 'video_player_box.dart';

/// Menampilkan media laporan (1–5 foto/video).
///
/// - 1 media: tampil seperti biasa (foto atau video).
/// - > 1 media: carousel geser dengan penanda "1/3" dan titik indikator.
class ReportMediaGallery extends StatefulWidget {
  const ReportMediaGallery({
    super.key,
    required this.media,
    this.aspectRatio,
    this.singleImageHeight,
    this.semanticLabel,
  });

  /// Path lokal atau URL media, urut sesuai `sort_order`.
  final List<String> media;

  /// Rasio media; carousel memakai 16:9 bila null.
  final double? aspectRatio;

  /// Tinggi foto tunggal bila [aspectRatio] null.
  final double? singleImageHeight;

  final String? semanticLabel;

  @override
  State<ReportMediaGallery> createState() => _ReportMediaGalleryState();
}

class _ReportMediaGalleryState extends State<ReportMediaGallery> {
  int _index = 0;

  @override
  void didUpdateWidget(covariant ReportMediaGallery oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_index >= widget.media.length) _index = 0;
  }

  Widget _item(String path, {double? height, double? ratio}) {
    if (isVideoMedia(path)) {
      return VideoPlayerBox(videoUrl: path, aspectRatio: ratio ?? 16 / 9);
    }
    return NetworkImageBox(
      imageUrl: path,
      height: height,
      aspectRatio: ratio,
      semanticLabel: widget.semanticLabel,
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = widget.media;
    if (media.isEmpty) return const SizedBox.shrink();

    if (media.length == 1) {
      final ratio = widget.aspectRatio ??
          (isVideoMedia(media.first) ? 16 / 9 : null);
      return _item(
        media.first,
        height: ratio == null ? widget.singleImageHeight : null,
        ratio: ratio,
      );
    }

    final ratio = widget.aspectRatio ?? 16 / 9;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AspectRatio(
          aspectRatio: ratio,
          child: Stack(
            children: [
              PageView.builder(
                itemCount: media.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (_, i) => _item(media[i], ratio: ratio),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Text(
                    '${_index + 1}/${media.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < media.length; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == _index ? 16 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: i == _index
                      ? HomeColors.primaryContainer
                      : AppPalette.divider(context),
                  borderRadius: BorderRadius.circular(9999),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
