import 'package:flutter/material.dart';
import '../../../theme.dart' as theme;

/// The purple-gradient "Sheoldred, the Apocalypse" card used as the running
/// illustration across onboarding (Welcome, First scan, Scan result).
class SheoldredCard extends StatelessWidget {
  final double width;
  final double height;

  const SheoldredCard({super.key, required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    final t = theme.light;
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3B2A6B), Color(0xFF1B1230)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: t.accent.withValues(alpha: 0.4)),
      ),
      child: Align(
        alignment: Alignment.topLeft,
        child: Text(
          'Sheoldred, the Apocalypse',
          style: TextStyle(color: t.ink, fontSize: 10.5, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
