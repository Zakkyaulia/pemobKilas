import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';

/// A link section for guiding new students.
///
/// Displays a tappable text link "Panduan untuk mahasiswa baru"
/// at the bottom of the login screen per the Figma hierarchy.
class StudentGuideLink extends StatelessWidget {
  const StudentGuideLink({super.key, this.onTap});

  /// Called when the user taps the guide link.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          children: [
            TextSpan(text: 'Mahasiswa baru? ', style: AppTextStyles.body),
            TextSpan(
              text: 'Lihat panduan',
              style: AppTextStyles.link,
              recognizer: TapGestureRecognizer()..onTap = onTap,
            ),
          ],
        ),
      ),
    );
  }
}
