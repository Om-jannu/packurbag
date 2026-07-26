import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/app_theme.dart';

/// Standard validated text field — fixes LoginPage/RegisterPage previously
/// having no Form/validators at all. Styled as the design reference's flat
/// pill input (hint text, no floating label, muted tinted fill) rather than
/// Material's default outlined/floating-label field.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.prefixIcon,
    this.textInputAction,
    this.showVisibilityToggle = false,
  });

  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final IconData? prefixIcon;
  final TextInputAction? textInputAction;

  /// Shows an eye icon that toggles [obscureText] locally, matching the
  /// design reference's inline show/hide control in the password field.
  final bool showVisibilityToggle;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscured = widget.obscureText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscured,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      validator: widget.validator,
      style: AppTextStyles.body(color: AppTheme.textPrimary(context)),
      decoration: InputDecoration(
        hintText: widget.label,
        hintStyle: AppTextStyles.body(color: AppTheme.textMuted(context, opacity: 0.35)),
        filled: true,
        fillColor: AppTheme.surfaceInput(context),
        prefixIcon: widget.prefixIcon != null
            ? Icon(widget.prefixIcon, size: 18, color: AppTheme.textMuted(context, opacity: 0.4))
            : null,
        suffixIcon: widget.showVisibilityToggle
            ? IconButton(
                icon: Icon(
                  _obscured ? LucideIcons.eye : LucideIcons.eyeOff,
                  size: 18,
                  color: AppTheme.textMuted(context, opacity: 0.4),
                ),
                onPressed: () => setState(() => _obscured = !_obscured),
              )
            : null,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class Validators {
  Validators._();

  static String? required(String? value, {String field = 'This field'}) {
    if (value == null || value.trim().isEmpty) return '$field is required';
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final pattern = RegExp(r'^[\w\-.]+@([\w\-]+\.)+[\w\-]{2,4}$');
    if (!pattern.hasMatch(value)) return 'Enter a valid email address';
    return null;
  }

  static String? minLength(String? value, int length, {String field = 'This field'}) {
    if (value == null || value.length < length) {
      return '$field must be at least $length characters';
    }
    return null;
  }
}
