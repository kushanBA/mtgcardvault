import 'package:flutter/material.dart';
import '../../../theme.dart' as theme;
import '../../../widgets/ui.dart' as ui;
import 'onboarding_step_chrome.dart';

class AlertsPrimerStep extends StatelessWidget {
  final VoidCallback onSkip;
  final VoidCallback onTurnOnAlerts;
  final VoidCallback onMaybeLater;

  const AlertsPrimerStep({
    super.key,
    required this.onSkip,
    required this.onTurnOnAlerts,
    required this.onMaybeLater,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: onSkip,
                  child: Text('Skip', style: TextStyle(color: t.muted, fontSize: 13.5)),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: t.panel,
                border: Border.all(color: t.line),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: t.accentBg, borderRadius: BorderRadius.circular(8)),
                    child: Text(
                      'CV',
                      style: TextStyle(color: t.accent, fontSize: 10.5, fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'CardVault',
                                style: TextStyle(color: t.ink, fontSize: 13, fontWeight: FontWeight.w700),
                              ),
                            ),
                            Text('now', style: TextStyle(color: t.muted, fontSize: 11)),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Sheoldred is up 18% this week. Your signal says SELL — 82% confidence.',
                          style: TextStyle(color: t.ink2, fontSize: 12.5, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: t.panel,
                border: Border.all(color: t.line),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    color: t.down.withValues(alpha: 0.16),
                    child: Text(
                      'SELL SIGNAL · CONFIDENCE 82%',
                      style: TextStyle(color: t.down, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.4),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [Color(0xFF3B2A6B), Color(0xFF1B1230)]),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Sheoldred, the Apocalypse',
                                    style: TextStyle(color: t.ink, fontSize: 13.5, fontWeight: FontWeight.w700),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        '+18.2% 7d',
                                        style: TextStyle(color: t.up, fontSize: 11.5, fontWeight: FontWeight.w600),
                                      ),
                                      Text(' · \$99.80', style: TextStyle(color: t.muted, fontSize: 11.5)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        LayoutBuilder(
                          builder: (context, constraints) => ui.Sparkline(
                            data: const [82.1, 83.4, 82.9, 85.2, 88.6, 91.0, 95.5, 99.8],
                            color: t.down,
                            width: constraints.maxWidth,
                            height: 42,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),
            Text('Know the moment to sell.', style: theme.fontDisplay(fontSize: 25, color: t.ink)),
            const SizedBox(height: 10),
            Text(
              'Get a heads-up when cards you own spike, dip, or get listed below market.',
              style: TextStyle(color: t.ink2, fontSize: 14, height: 1.55),
            ),
            const Spacer(),
            ContinueButton(onTap: onTurnOnAlerts, label: 'Turn on alerts'),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: onMaybeLater,
              child: Text(
                'Maybe later',
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
