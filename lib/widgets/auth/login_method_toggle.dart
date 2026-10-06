import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';

/// Login method identifiers.
enum LoginMethod { email, nim }

/// A segmented toggle control for selecting the login method.
///
/// Displays two tabs: "Email" and "NIM". The active tab is highlighted
/// with the accent mint background and animated slide transition.
///
/// Visual spec from Figma:
/// - Outer container: rounded pill, light surface background
/// - Active segment: mint accent background, dark text
/// - Inactive segment: transparent, muted text
class LoginMethodToggle extends StatelessWidget {
  const LoginMethodToggle({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  /// The currently selected login method.
  final LoginMethod selected;

  /// Callback when the user taps a different method.
  final ValueChanged<LoginMethod> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceLightBlue,
        borderRadius: AppRadius.fullAll,
      ),
      child: Row(
        children: [
          _buildTab(label: 'Email', method: LoginMethod.email),
          _buildTab(label: 'NIM', method: LoginMethod.nim),
        ],
      ),
    );
  }

  Widget _buildTab({required String label, required LoginMethod method}) {
    final bool isActive = selected == method;

    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(method),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: isActive ? AppColors.accentCyan : Colors.transparent,
            borderRadius: AppRadius.fullAll,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTextStyles.toggleLabel.copyWith(
              color: isActive ? AppColors.primaryBlue : AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}
