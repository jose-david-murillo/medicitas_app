import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

/// Widget reutilizable - Banner informativo para RF
/// Demuestra Container, Row, Icon, BoxDecoration
class InfoBanner extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color bgColor;
  const InfoBanner({
    super.key,
    required this.text,
    this.icon = Icons.info_outline,
    this.bgColor = const Color(0xFFE8F5E9),
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: text,
      child: ExcludeSemantics(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(icon, size: 16, color: AppColors.textDark),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textDark,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
