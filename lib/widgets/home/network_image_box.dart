import 'package:flutter/material.dart';

import '../../theme/app_radius.dart';
import '../../theme/home_colors.dart';

/// Displays a network image with rounded corners, a coloured
/// placeholder while loading, and an error fallback.
///
/// Corner radius uses `rounded-xl` = 12px ([AppRadius.medium]).
class NetworkImageBox extends StatelessWidget {
  const NetworkImageBox({
    super.key,
    required this.imageUrl,
    required this.height,
    this.semanticLabel,
  });

  /// URL of the image to display.
  final String imageUrl;

  /// Fixed height of the image container.
  final double height;

  /// Accessibility label for the image.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadius.mediumAll,
      child: Container(
        width: double.infinity,
        height: height,
        color: HomeColors.surfaceSubtle,
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          height: height,
          semanticLabel: semanticLabel,
          loadingBuilder: _loadingBuilder,
          errorBuilder: _errorBuilder,
        ),
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
    return Center(
      child: CircularProgressIndicator(
        value: progress,
        strokeWidth: 2,
        color: HomeColors.primary,
      ),
    );
  }

  static Widget _errorBuilder(
    BuildContext context,
    Object error,
    StackTrace? stackTrace,
  ) {
    return const Center(
      child: Icon(
        Icons.broken_image_outlined,
        color: HomeColors.onSurfaceVariant,
        size: 32,
      ),
    );
  }
}
