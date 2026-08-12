import 'package:flutter/material.dart' hide Card;
import 'package:provider/provider.dart';
import '../../data/store.dart';
import '../../data/types.dart';
import '../../nav.dart';
import '../../theme.dart' as theme;
import '../../widgets/ui.dart' as ui;

enum _Verdict { sell, hold, watch }

extension on _Verdict {
  String get code => switch (this) {
        _Verdict.sell => 'SELL',
        _Verdict.hold => 'HOLD',
        _Verdict.watch => 'WATCH',
      };
  Color get bg => switch (this) {
        _Verdict.sell => const Color(0x29F0544F),
        _Verdict.hold => const Color(0x292BD48A),
        _Verdict.watch => const Color(0x29E3B341),
      };
  Color get ink => switch (this) {
        _Verdict.sell => const Color(0xFFF0544F),
        _Verdict.hold => const Color(0xFF2BD48A),
        _Verdict.watch => const Color(0xFFE3B341),
      };
  int get rank => switch (this) {
        _Verdict.sell => 0,
        _Verdict.watch => 1,
        _Verdict.hold => 2,
      };
}

class _Signal {
  final Card card;
  final _Verdict verdict;
  final double confidence;
  final String reason;
  const _Signal({required this.card, required this.verdict, required this.confidence, required this.reason});
}

class SignalsScreen extends StatefulWidget {
  const SignalsScreen({super.key});

  @override
  State<SignalsScreen> createState() => _SignalsScreenState();
}

class _SignalsScreenState extends State<SignalsScreen> {
  final Set<String> dismissed = {};
  String filter = 'All';

  @override
  Widget build(BuildContext context) {
    final store = context.watch<Store>();
    final nav = context.read<Nav>();
    final t = theme.light;

    final owned = <String>{};
    for (final b in store.binders) {
      for (final p in b.pockets) {
        if (p.cardId != null) owned.add(p.cardId!);
      }
    }
    final signals = <_Signal>[];
    for (final id in owned) {
      final c = store.cards[id]!;
      final ch30 = c.price / c.history[(c.history.length - 30).clamp(0, c.history.length - 1)] - 1;
      if (id == 'moonbreon') {
        signals.add(_Signal(
          card: c,
          verdict: _Verdict.watch,
          confidence: 0.66,
          reason: 'A special collection was announced. Reprint risk raised to high — this signal updates on the set-list reveal.',
        ));
      } else if (ch30 > 0.15) {
        signals.add(_Signal(
          card: c,
          verdict: _Verdict.sell,
          confidence: (0.6 + ch30).clamp(0, 0.9),
          reason: 'Spiked ${pct(ch30)} in 30d after tournament results. In similar spikes since 2022, prices gave back half within 14 days.',
        ));
      } else if (ch30 > 0.05) {
        signals.add(_Signal(
          card: c,
          verdict: _Verdict.hold,
          confidence: 0.8,
          reason: 'Up ${pct(ch30)} in 30d with rotation approaching — supply tightens and holders historically gained 12–20%.',
        ));
      }
    }
    signals.sort((a, b) => a.verdict.rank.compareTo(b.verdict.rank));

    final visible = signals.where((sg) => !dismissed.contains(sg.card.id) && (filter == 'All' || sg.verdict.code == filter)).toList();

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
                Text('Signals', style: TextStyle(color: t.ink, fontSize: 16, fontWeight: FontWeight.w700)),
                Text('${visible.length} active', style: TextStyle(color: t.muted, fontSize: 11)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
            child: Row(
              children: ['All', 'SELL', 'HOLD', 'WATCH'].map((k) {
                final on = filter == k;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: GestureDetector(
                    onTap: () => setState(() => filter = k),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: on ? t.ink : null,
                        border: Border.all(color: on ? t.ink : t.line),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(k, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: on ? t.bg : t.ink2)),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 28),
              children: [
                if (visible.isEmpty)
                  const ui.EmptyState(
                    image: 'assets/illustrations/empty-signals.png',
                    text: "No signals right now — you'll be pinged when the market moves on cards you own.",
                  ),
                ...visible.map((sg) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(color: t.panel, border: Border.all(color: t.line), borderRadius: BorderRadius.circular(14)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
                          color: sg.verdict.bg,
                          child: Text(
                            '${sg.verdict.code} SIGNAL · CONFIDENCE ${(sg.confidence * 100).round()}%',
                            style: TextStyle(color: sg.verdict.ink, fontSize: 10.5, fontWeight: FontWeight.w700, letterSpacing: 0.8),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ui.CardThumb(cardId: sg.card.id, w: 34, h: 48),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text.rich(TextSpan(children: [
                                          TextSpan(text: '${sg.card.name} · ${sg.card.number}  ', style: TextStyle(color: t.ink, fontSize: 13.5, fontWeight: FontWeight.w700)),
                                          TextSpan(text: '\$${fmt(sg.card.price)}', style: TextStyle(color: t.up)),
                                        ])),
                                        Padding(
                                          padding: const EdgeInsets.only(top: 3),
                                          child: Text(sg.reason, style: TextStyle(color: t.ink2, fontSize: 12, height: 1.4)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: ui.Sparkline(
                                  data: sg.card.history.sublist((sg.card.history.length - 45).clamp(0, sg.card.history.length)),
                                  color: sg.verdict == _Verdict.sell ? t.down : t.up,
                                  width: 280,
                                  height: 30,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Row(
                                  children: [
                                    if (sg.verdict == _Verdict.sell)
                                      Expanded(
                                        flex: 13,
                                        child: GestureDetector(
                                          onTap: () => nav.push(NavOverlay.sellSheet(sg.card.id, Condition.nm)),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(vertical: 8),
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(color: t.ink, borderRadius: BorderRadius.circular(9)),
                                            child: Text('Sell now · \$${sg.card.price.round()}', style: TextStyle(color: t.bg, fontSize: 12, fontWeight: FontWeight.w700)),
                                          ),
                                        ),
                                      ),
                                    if (sg.verdict == _Verdict.sell) const SizedBox(width: 8),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => setState(() => dismissed.add(sg.card.id)),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(border: Border.all(color: t.line), borderRadius: BorderRadius.circular(9)),
                                          child: Text('Dismiss', style: TextStyle(color: t.ink2, fontSize: 12, fontWeight: FontWeight.w600)),
                                        ),
                                      ),
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
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
