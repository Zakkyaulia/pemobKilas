import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_spacing.dart';

/// A styled text field for authentication forms.
///
/// Renders a labeled input field matching the Figma design spec:
/// - 12px/w600 label above the field
/// - 14px/w400 input text
/// - Optional password toggle (eye icon)
/// - Error state styling
/// - Consistent border styling from theme
class AuthTextField extends StatefulWidget {
  const AuthTextField({
    super.key,
    required this.label,
    required this.hintText,
    this.controller,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.validator,
    this.prefixIcon,
    this.enabled = true,
  });

  /// The label displayed above the field.
  final String label;

  /// Placeholder text inside the field.
  final String hintText;

  /// Controller for reading/writing the field value.
  final TextEditingController? controller;

  /// When true, the field obscures text and shows a visibility toggle.
  final bool isPassword;

  /// Keyboard type for the field (email, number, etc.).
  final TextInputType keyboardType;

  /// The action button on the keyboard (next, done, etc.).
  final TextInputAction textInputAction;

  /// Validation function — receives the field value, returns error string or null.
  final String? Function(String?)? validator;

  /// Optional icon displayed at the start of the field.
  final IconData? prefixIcon;

  /// Whether the field is interactive.
  final bool enabled;

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Label ───────────────────────────────────────────────────────
        Text(widget.label, style: AppTextStyles.label),
        const SizedBox(height: AppSpacing.sm),

        // ── Input field ─────────────────────────────────────────────────
        TextFormField(
          controller: widget.controller,
          obscureText: widget.isPassword && _obscured,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          enabled: widget.enabled,
          style: AppTextStyles.input,
          validator: widget.validator,
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: AppTextStyles.inputHint,
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon, size: 20, color: AppColors.textMuted)
                : null,
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscured
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 20,
                      color: AppColors.textMuted,
                    ),
                    onPressed: () {
                      setState(() => _obscured = !_obscured);
                    },
                    splashRadius: 20,
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
