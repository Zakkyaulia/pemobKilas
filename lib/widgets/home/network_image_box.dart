import 'package:flutter/material.dart';

import '../../theme/app_radius.dart';
import '../../theme/home_colors.dart';

/// Displays a network image with rounded corners, a coloured
/// placeholder while loading, and an error fallback.
///
/// Supports fixed [height] or dynamic [aspectRatio] (e.g. 16:9, 1:1, 4:3, 9:16).
/// Corner radius uses `rounded-xl` = 12px ([AppRadius.medium]).
class NetworkImageBox extends StatelessWidget {
  const NetworkImageBox({
    super.key,
    required this.imageUrl,
    this.height,
    this.aspectRatio,
    this.semanticLabel,
  });

  /// URL of the image to display.
  final String imageUrl;

  /// Optional fixed height of the image container.
  final double? height;

  /// Optional aspect ratio (width / height) to dynamically scale image.
  final double? aspectRatio;

  /// Accessibility label for the image.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    Widget content = Image.network(
      imageUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: height,
      semanticLabel: semanticLabel,
      loadingBuilder: _loadingBuilder,
      errorBuilder: _errorBuilder,
    );

    if (aspectRatio != null) {
      content = AspectRatio(
        aspectRatio: aspectRatio!,
        child: content,
      );
    } else if (height != null) {
      content = SizedBox(
        width: double.infinity,
        height: height,
        child: content,
      );
    } else {
      content = SizedBox(
        width: double.infinity,
        height: 224,
        child: content,
      );
    }

    return ClipRRect(
      borderRadius: AppRadius.mediumAll,
      child: Container(
        width: double.infinity,
        color: HomeColors.surfaceSubtle,
        child: content,
      ),
    );
  }

  Widget _loadingBuilder(
    BuildContext context,
    Widget child,
    ImageChunkEvent? loadingProgress,
  ) {
    if (loadingProgress == null) return child;
    final expected = loadingProgress.expectedTotalBytes;
    final progress = expected != null
        ? loadingProgress.cumulativeBytesLoaded / expected
        : null;
    return Container(
      height: height ?? 200,
      color: HomeColors.surfaceSubtle,
      child: Center(
        child: CircularProgressIndicator(
          value: progress,
          strokeWidth: 2,
          color: HomeColors.primaryContainer,
        ),
      ),
    );
  }

  Widget _errorBuilder(
    BuildContext context,
    Object error,
    StackTrace? stackTrace,
  ) {
    return Container(
      height: height ?? 160,
      color: HomeColors.surfaceSubtle,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(
            Icons.broken_image_outlined,
            size: 32,
            color: HomeColors.onSurfaceVariant,
          ),
          SizedBox(height: 6),
          Text(
            'Gambar tidak dapat dimuat',
            style: TextStyle(
              fontSize: 12,
              color: HomeColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
