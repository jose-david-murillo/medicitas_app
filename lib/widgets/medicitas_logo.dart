import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

/// Widget reutilizable - Logo MediCitas
/// Demuestra uso de StatelessWidget, Container, Icon, Text
class MedicitasLogo extends StatelessWidget {
  final double size;
  final bool showSubtitle;
  const MedicitasLogo({super.key, this.size = 26, this.showSubtitle = true});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ExcludeSemantics(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.add,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'MediCitas',
              style: TextStyle(
                color: Colors.white,
                fontSize: size,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        if (showSubtitle) ...[
          const SizedBox(height: 8),
          const Text(
            'Gestión de citas médicas',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ],
    );
  }
}
