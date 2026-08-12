import 'package:flutter/material.dart' hide Card;
import 'package:provider/provider.dart';
import '../../data/store.dart';
import '../../nav.dart';
import '../../theme.dart' as theme;
import '../../widgets/ui.dart' as ui;

class _DealSeed {
  final String cardId;
  final double discount;
  final String source;
  final int minsAgo;
  const _DealSeed({required this.cardId, required this.discount, required this.source, required this.minsAgo});
}

const _dealSeeds = [
  _DealSeed(cardId: 'zard', discount: 0.23, source: 'eBay', minsAgo: 4),
  _DealSeed(cardId: 'moonbreon', discount: 0.15, source: 'TCGplayer', minsAgo: 26),
  _DealSeed(cardId: 'lugia', discount: 0.19, source: 'eBay', minsAgo: 41),
  _DealSeed(cardId: 'rayquaza', discount: 0.26, source: 'Cardmarket', minsAgo: 58),
];

class DealRadarScreen extends StatefulWidget {
  const DealRadarScreen({super.key});

  @override
  State<DealRadarScreen> createState() => _DealRadarScreenState();
}

class _DealRadarScreenState extends State<DealRadarScreen> {
  int threshold = 15;
  final Set<String> muted = {};

  @override
  Widget build(BuildContext context) {
    final store = context.watch<Store>();
    final nav = context.read<Nav>();
    final t = theme.light;

    final deals = _dealSeeds.map((d) {
      final card = store.cards[d.cardId]!;
      return (seed: d, card: card, listPrice: (card.price * (1 - d.discount) * 100).round() / 100);
    }).toList();
    final visible = deals.where((d) => d.seed.discount * 100 >= threshold && !muted.contains(d.seed.cardId)).toList();

    return Container(
      color: t.bg,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(onTap: nav.pop, child: Text('‹ Back', style: TextStyle(color: t.ink2, fontSize: 14))),
                Text('Deal radar', style: TextStyle(color: t.ink, fontSize: 16, fontWeight: FontWeight.w700)),
                Text('● scanning 4 markets', style: TextStyle(color: t.accent, fontSize: 11)),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 28),
              children: [
                ...visible.map((d) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: t.panel,
                      border: Border.all(color: d.seed.discount >= 0.2 ? const Color(0x732BD48A) : t.line),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ui.Chip(label: '${(d.seed.discount * 100).round()}% below market', bg: t.accentBg, color: t.accent),
                            Text('${d.seed.source} · ${d.seed.minsAgo} min ago', style: TextStyle(color: t.muted, fontSize: 10.5)),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ui.CardThumb(cardId: d.seed.cardId, w: 34, h: 48),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${d.card.name} · NM', style: TextStyle(color: t.ink, fontSize: 13.5, fontWeight: FontWeight.w700)),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 3),
                                      child: Text.rich(TextSpan(children: [
                                        TextSpan(text: '\$${fmt(d.listPrice)}', style: TextStyle(color: t.ink, fontSize: 16, fontWeight: FontWeight.w700)),
                                        TextSpan(text: '  market \$${fmt(d.card.price)}', style: TextStyle(color: t.muted, fontSize: 12, decoration: TextDecoration.lineThrough)),
                                      ])),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: Text(
                                        'last 3 solds: ${d.card.recentSolds.map((r) => '\$${r.price.round()}').join(' · ')}',
                                        style: TextStyle(color: t.muted, fontSize: 10.5),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 14,
                                child: GestureDetector(
                                  onTap: () => nav.push(NavOverlay.card(d.seed.cardId)),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 9),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(color: t.accent, borderRadius: BorderRadius.circular(9)),
                                    child: Text('View card', style: TextStyle(color: t.bg, fontSize: 12, fontWeight: FontWeight.w700)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 8,
                                child: GestureDetector(
                                  onTap: () => setState(() => muted.add(d.seed.cardId)),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 9),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(border: Border.all(color: t.line), borderRadius: BorderRadius.circular(9)),
                                    child: Text('Mute card', style: TextStyle(color: t.ink2, fontSize: 12, fontWeight: FontWeight.w600)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                if (visible.isEmpty)
                  const ui.EmptyState(
                    image: 'assets/illustrations/empty-radar.png',
                    text: 'Nothing under your threshold right now — radar keeps scanning.',
                  ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: t.panel, border: Border.all(color: t.line), borderRadius: BorderRadius.circular(14)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Alert threshold', style: TextStyle(color: t.ink2, fontSize: 12.5)),
                          Text('≥ $threshold% under market', style: TextStyle(color: t.ink, fontSize: 12.5, fontWeight: FontWeight.w700)),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Row(
                          children: [10, 15, 20, 25].map((v) {
                            final on = threshold == v;
                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: GestureDetector(
                                  onTap: () => setState(() => threshold = v),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 6),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: on ? t.ink : null,
                                      border: Border.all(color: on ? t.ink : t.line),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text('$v%', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: on ? t.bg : t.ink2)),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text('Scope: watchlist + owned sets. Push alerts fire the minute a listing appears.', style: TextStyle(color: t.muted, fontSize: 11)),
                      ),
                    ],
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
