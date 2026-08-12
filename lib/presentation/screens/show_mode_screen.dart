import 'package:flutter/material.dart' hide Card;
import 'package:provider/provider.dart';
import '../../data/store.dart';
import '../../data/types.dart';
import '../../nav.dart';
import '../../theme.dart' as theme;
import '../../widgets/ui.dart' as ui;

/// Deterministic fake QR: hashes the listing id into a dot grid
/// (real QR lib comes with the marketplace build)
class _QrBlock extends StatelessWidget {
  final String seed;
  const _QrBlock({required this.seed});

  List<bool> _cells() {
    var h = 2166136261;
    for (final ch in seed.codeUnits) {
      h = (0x01000193 * (h ^ ch)) & 0xFFFFFFFF;
    }
    final out = <bool>[];
    for (var i = 0; i < 144; i++) {
      h = (0x5bd1e995 * (h ^ (h >>> 13))) & 0xFFFFFFFF;
      out.add(((h >>> (i % 24)) & 1) == 1);
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final cells = _cells();
    return Container(
      width: 96,
      height: 96,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFF22293A))),
      child: Stack(
        children: [
          Wrap(
            children: cells.map((on) => Container(width: 6, height: 6, color: on ? const Color(0xFF1B2420) : Colors.transparent)).toList(),
          ),
          Positioned(top: 4, left: 4, child: Container(width: 14, height: 14, decoration: BoxDecoration(border: Border.all(color: const Color(0xFF1B2420), width: 3)))),
          Positioned(top: 4, right: 4, child: Container(width: 14, height: 14, decoration: BoxDecoration(border: Border.all(color: const Color(0xFF1B2420), width: 3)))),
          Positioned(bottom: 4, left: 4, child: Container(width: 14, height: 14, decoration: BoxDecoration(border: Border.all(color: const Color(0xFF1B2420), width: 3)))),
        ],
      ),
    );
  }
}

class ShowModeScreen extends StatelessWidget {
  final String listingId;
  const ShowModeScreen({super.key, required this.listingId});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<Store>();
    final nav = context.read<Nav>();
    final t = theme.light;
    final listing = store.listings.where((l) => l.id == listingId).firstOrNull;
    if (listing == null) return const SizedBox.shrink();
    final c = store.cards[listing.cardId]!;
    final sold = listing.status == ListingStatus.sold;

    return Container(
      color: t.bg,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(onTap: nav.pop, child: Text('‹ Back', style: TextStyle(color: t.ink2, fontSize: 14))),
              Text('Show mode', style: TextStyle(color: t.ink, fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(width: 44),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
            decoration: BoxDecoration(color: t.warnBg, borderRadius: BorderRadius.circular(9)),
            child: Text(
              'Offline-ready · price cached today 11:20 AM — no signal needed at the table',
              style: TextStyle(color: t.warnInk, fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: t.panel, border: Border.all(color: t.line), borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                Text('CARDVAULT · VERIFIED LISTING', style: TextStyle(color: t.muted, fontSize: 10, letterSpacing: 1.2), textAlign: TextAlign.center),
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Column(
                    children: [
                      sold
                          ? ClipRRect(borderRadius: BorderRadius.circular(14), child: Image.asset('assets/illustrations/sold.png', width: 120, height: 120, fit: BoxFit.cover))
                          : _QrBlock(seed: listing.id),
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          sold ? 'Sold — nice trade. Inventory and stats updated.' : 'Buyer scans to verify condition + price',
                          style: TextStyle(color: t.muted, fontSize: 10.5),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ui.CardThumb(cardId: c.id, w: 56, h: 78),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(c.name, style: TextStyle(color: t.ink, fontSize: 15, fontWeight: FontWeight.w700)),
                            Text('${c.number} · ${c.set}', style: TextStyle(color: t.muted, fontSize: 11.5)),
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text('\$${fmt(listing.price)}', style: TextStyle(color: t.ink, fontSize: 24, fontWeight: FontWeight.w700)),
                            ),
                            Text('price locked 11:20 AM · market \$${fmt(c.price)}', style: TextStyle(color: t.muted, fontSize: 10.5)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    children: [
                      ui.Chip(label: 'AI condition: ${listing.condition.code}', bg: t.accentBg, color: t.accent),
                      const SizedBox(width: 6),
                      ui.Chip(label: '3 scan photos · verified', border: t.line, color: t.ink2),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.only(top: 12),
                  decoration: BoxDecoration(border: Border(top: BorderSide(color: t.line))),
                  child: Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(color: t.accentBg, shape: BoxShape.circle),
                        alignment: Alignment.center,
                        child: Text('CP', style: TextStyle(color: t.accent, fontWeight: FontWeight.w700, fontSize: 12)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text.rich(TextSpan(children: [
                          TextSpan(text: 'You', style: TextStyle(color: t.ink, fontWeight: FontWeight.w700)),
                          TextSpan(text: ' · verified seller · ★ 5.0', style: TextStyle(color: t.ink2)),
                        ]), style: const TextStyle(fontSize: 11.5)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Row(
              children: [
                Expanded(
                  flex: 14,
                  child: GestureDetector(
                    onTap: sold ? null : () => store.markListingSold(listing.id),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: sold ? t.up : t.ink, borderRadius: BorderRadius.circular(11)),
                      child: Text(sold ? 'Sold ✓ · inventory updated' : 'Mark as sold · cash', style: TextStyle(color: t.bg, fontSize: 13, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: t.panel, border: Border.all(color: t.line), borderRadius: BorderRadius.circular(11)),
                    child: Text('Pay in app · soon', style: TextStyle(color: t.muted, fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
