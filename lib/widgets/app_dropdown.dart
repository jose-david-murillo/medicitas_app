import 'package:flutter/material.dart';

/// Widget reutilizable - Dropdown con API moderna (initialValue)
/// Envuelve DropdownButtonFormField usando initialValue en lugar de value (deprecated desde 3.33)
class AppDropdown<T> extends StatelessWidget {
  final T? initialValue;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String? label;
  final IconData? prefixIcon;

  const AppDropdown({
    super.key,
    this.initialValue,
    required this.items,
    required this.onChanged,
    this.label,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: initialValue,
      items: items,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
      ),
    );
  }
}
