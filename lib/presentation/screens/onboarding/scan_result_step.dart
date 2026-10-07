import 'package:flutter/material.dart';
import '../../../theme.dart' as theme;
import 'onboarding_step_chrome.dart';
import 'sheoldred_card.dart';

class ScanResultStep extends StatelessWidget {
  final int freeScansLeft;
  final VoidCallback onClose;
  final VoidCallback onAddToVault;
  final VoidCallback onScanAnother;

  const ScanResultStep({
    super.key,
    required this.freeScansLeft,
    required this.onClose,
    required this.onAddToVault,
    required this.onScanAnother,
  });

  @override
  Widget build(BuildContext context) {
    final t = theme.light;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: onClose,
                  child: Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: t.panel),
                    child: Text('✕', style: TextStyle(color: t.ink2, fontSize: 14)),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: t.accentBg, borderRadius: BorderRadius.circular(999)),
                  child: Text(
                    '● $freeScansLeft free scan${freeScansLeft == 1 ? '' : 's'} left',
                    style: TextStyle(color: t.accent, fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.topCenter,
                      children: [
                        const SheoldredCard(width: 168, height: 236),
                        Positioned(
                          bottom: -14,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: t.bg,
                              border: Border.all(color: t.up),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '✓ Card matched',
                              style: TextStyle(color: t.up, fontSize: 11.5, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Sheoldred, the Apocalypse',
                      textAlign: TextAlign.center,
                      style: theme.fontDisplay(fontSize: 21, color: t.ink),
                    ),
                    const SizedBox(height: 4),
                    Text('Dominaria United · #107 · Mythic', style: TextStyle(color: t.muted, fontSize: 12.5)),
                    const SizedBox(height: 18),
                    Text('\$84.50', style: theme.fontHeavy(fontSize: 42, color: t.accent)),
                    const SizedBox(height: 4),
                    Text(
                      'TCGPLAYER MARKET',
                      style: TextStyle(color: t.muted, fontSize: 10.5, fontWeight: FontWeight.w700, letterSpacing: 1),
                    ),
                    const SizedBox(height: 22),
                    IntrinsicHeight(
                      child: Row(
                        children: [
                          Expanded(child: _PriceColumn(label: 'Card Kingdom', value: '\$89.99', t: t)),
                          VerticalDivider(color: t.line, width: 1),
                          Expanded(child: _PriceColumn(label: 'Scryfall', value: '\$82.10', t: t)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            GoldButton(onTap: onAddToVault, label: 'Add to my vault'),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: onScanAnother,
              child: Text(
                'Scan another card',
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

class _PriceColumn extends StatelessWidget {
  final String label;
  final String value;
  final theme.AppColors t;
  const _PriceColumn({required this.label, required this.value, required this.t});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: t.muted, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: t.ink, fontSize: 15, fontWeight: FontWeight.w700)),
      ],
    );
  }
}
