import 'package:flutter/material.dart';
import '../../../theme.dart' as theme;
import 'onboarding_step_chrome.dart';

class RealPricesStep extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onContinue;

  const RealPricesStep({super.key, required this.onBack, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    final t = theme.light;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StepHeader(step: 1, totalSteps: 6, onBack: onBack),
            const SizedBox(height: 26),
            Text(
              'Real market prices, not wishful asking prices.',
              style: theme.fontDisplay(fontSize: 25, color: t.ink),
            ),
            const SizedBox(height: 12),
            Text(
              'Every scan checks the stores collectors actually buy from — so you know '
              'what a card is worth before you trade, sell or sleeve it.',
              style: TextStyle(color: t.ink2, fontSize: 14, height: 1.55),
            ),
            const Spacer(),
            _PriceCard(t: t),
            const SizedBox(height: 22),
            ContinueButton(onTap: onContinue),
          ],
        ),
      ),
    );
  }
}

class _PriceCard extends StatelessWidget {
  final theme.AppColors t;
  const _PriceCard({required this.t});

  Widget _row(String label, String value, {bool struck = false, bool muted = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(color: muted ? t.down : t.muted, shape: BoxShape.circle),
              ),
              Text(label, style: TextStyle(color: muted ? t.muted : t.ink2, fontSize: 13)),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              color: muted ? t.muted : t.ink,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              decoration: struck ? TextDecoration.lineThrough : null,
              decorationColor: t.muted,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: t.panel,
        border: Border.all(color: t.line),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
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
                    Text('Dominaria United · #107 · NM', style: TextStyle(color: t.muted, fontSize: 11.5)),
                  ],
                ),
              ),
            ],
          ),
          Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Divider(color: t.line, height: 1)),
          _row('TCGplayer market', '\$84.50'),
          _row('Card Kingdom', '\$89.99'),
          _row('Scryfall', '\$82.10'),
          _row('Highest asking price', '\$139.99', struck: true, muted: true),
        ],
      ),
    );
  }
}
