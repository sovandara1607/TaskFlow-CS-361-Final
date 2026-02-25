import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// A reusable styled text form field widget — dark mode aware.
class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final int maxLines;
  final bool obscureText;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        maxLines: maxLines,
        obscureText: obscureText,
        style: TextStyle(
          color: isDark ? Colors.white : AppConstants.textPrimary,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: isDark
              ? AppConstants.darkCard
              : Theme.of(context).colorScheme.surface,
        ),
      ),
    );
  }
}
