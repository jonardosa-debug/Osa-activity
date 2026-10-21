import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.prefixIcon,
    this.validator,
    this.maxLines = 1,
    this.hintText,
    this.enabled = true,
  });

  final String label;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;

  /// Optional field-level validation (Activity 9 addition).
  final String? Function(String?)? validator;

  /// Number of visible lines (Activity 9 addition, e.g. for descriptions).
  final int maxLines;

  /// Optional helper text shown under the field (Activity 9 addition).
  final String? hintText;

  /// Whether the field accepts input (Activity 9 addition).
  final bool enabled;

  @override
  Widget build(BuildContext context) => TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        maxLines: obscureText ? 1 : maxLines,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
          ),
        ),
      );
}
