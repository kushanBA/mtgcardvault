import 'package:flutter/material.dart';
import '../../../theme.dart' as theme;
import 'onboarding_step_chrome.dart';

class CameraPrimerStep extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onContinue;
  final VoidCallback onSkip;

  const CameraPrimerStep({
    super.key,
    required this.onBack,
    required this.onContinue,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final t = theme.light;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StepHeader(step: 6, totalSteps: 6, onBack: onBack),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const _PhoneFrame(),
                    const SizedBox(height: 28),
                    Text('Price your first card.', style: theme.fontDisplay(fontSize: 24, color: t.ink)),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'Grab any Magic card nearby. CardVault only uses your camera to scan cards.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: t.ink2, fontSize: 14, height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ContinueButton(onTap: onContinue, label: 'Allow camera access'),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: onSkip,
              child: Text(
                'Search by name instead',
                textAlign: TextAlign.center,
                style: TextStyle(color: t.muted, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A rounded phone outline framing a bracket-cornered card silhouette —
/// previews what the real scan viewfinder (see `scan_screen.dart`) looks
/// like, without wiring up an actual camera preview here.
class _PhoneFrame extends StatelessWidget {
  const _PhoneFrame();

  @override
  Widget build(BuildContext context) {
    final t = theme.light;
    const bracket = Color(0xFF4ADE9E);

    Widget corner({double? top, double? bottom, double? left, double? right, required Border border}) {
      return Positioned(
        top: top,
        bottom: bottom,
        left: left,
        right: right,
        child: Container(width: 20, height: 20, decoration: BoxDecoration(border: border)),
      );
    }

    return Container(
      width: 210,
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: t.line, width: 1.4),
      ),
      child: Center(
        child: SizedBox(
          width: 130,
          height: 190,
          child: Stack(
            children: [
              Container(
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF16202E),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: t.line),
                ),
              ),
              corner(
                top: 0,
                left: 0,
                border: const Border(
                  top: BorderSide(color: bracket, width: 2.5),
                  left: BorderSide(color: bracket, width: 2.5),
                ),
              ),
              corner(
                top: 0,
                right: 0,
                border: const Border(
                  top: BorderSide(color: bracket, width: 2.5),
                  right: BorderSide(color: bracket, width: 2.5),
                ),
              ),
              corner(
                bottom: 0,
                left: 0,
                border: const Border(
                  bottom: BorderSide(color: bracket, width: 2.5),
                  left: BorderSide(color: bracket, width: 2.5),
                ),
              ),
              corner(
                bottom: 0,
                right: 0,
                border: const Border(
                  bottom: BorderSide(color: bracket, width: 2.5),
                  right: BorderSide(color: bracket, width: 2.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
