import 'package:flutter/material.dart';
import '../../../theme.dart' as theme;
import 'sheoldred_card.dart';

class WelcomeStep extends StatelessWidget {
  final VoidCallback onGetStarted;
  final VoidCallback onSignIn;

  const WelcomeStep({super.key, required this.onGetStarted, required this.onSignIn});

  @override
  Widget build(BuildContext context) {
    final t = theme.light;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
        child: Column(
          children: [
            const Expanded(child: Center(child: _CardStackIllustration())),
            const SizedBox(height: 12),
            Text(
              'CARDVAULT',
              style: TextStyle(color: t.accent, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 3),
            ),
            const SizedBox(height: 10),
            Text(
              "What's your collection really worth?",
              textAlign: TextAlign.center,
              style: theme.fontDisplay(fontSize: 27, color: t.ink),
            ),
            const SizedBox(height: 10),
            Text(
              'Scan any card and see what it actually sells for, in seconds.',
              textAlign: TextAlign.center,
              style: TextStyle(color: t.ink2, fontSize: 14.5, height: 1.5),
            ),
            const SizedBox(height: 26),
            GestureDetector(
              onTap: onGetStarted,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                alignment: Alignment.center,
                decoration: BoxDecoration(color: t.accent, borderRadius: BorderRadius.circular(12)),
                child: const Text(
                  'Get started — 10 free scans',
                  style: TextStyle(color: Color(0xFF0B0E11), fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Already collecting with us? ', style: TextStyle(color: t.ink2, fontSize: 13)),
                GestureDetector(
                  onTap: onSignIn,
                  child: Text(
                    'Sign in',
                    style: TextStyle(color: t.accent, fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Decorative fan of three cards with a floating market-price chip — the
/// "hook" illustration on the Welcome step.
class _CardStackIllustration extends StatelessWidget {
  const _CardStackIllustration();

  Widget _card({required double angle, required double dx, required Color color, Widget? child}) {
    return Transform.translate(
      offset: Offset(dx, 0),
      child: Transform.rotate(
        angle: angle,
        child: Container(
          width: 150,
          height: 210,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(14)),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = theme.light;
    return SizedBox(
      width: 320,
      height: 260,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          _card(angle: -0.18, dx: -46, color: const Color(0xFF16202E)),
          _card(angle: 0.14, dx: 46, color: const Color(0xFF241A10)),
          const SheoldredCard(width: 150, height: 210),
          Positioned(
            bottom: 6,
            right: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: t.panel,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: t.line),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.35), blurRadius: 18, offset: const Offset(0, 8)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TCGPLAYER MARKET',
                    style: TextStyle(color: t.muted, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 0.6),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('\$84.50', style: theme.fontHeavy(fontSize: 19, color: t.ink)),
                      const SizedBox(width: 6),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text(
                          '▲ 12.4%',
                          style: TextStyle(color: t.up, fontSize: 11, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
