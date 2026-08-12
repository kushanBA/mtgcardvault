import 'dart:math';
import 'package:flutter/material.dart' hide Card;
import 'package:provider/provider.dart';
import '../../data/mock_db.dart';
import '../../data/store.dart';
import '../../nav.dart';
import '../../theme.dart' as theme;
import '../../widgets/ui.dart' as ui;

const _packCost = 4.29;
const _commons = ['Charmander', 'Squirtle', 'Rookidee', 'Lechonk', 'Energy ×4'];

class _Pull {
  final String name;
  final String sub;
  final double value;
  final bool hit;
  final String? id;
  const _Pull({required this.name, required this.sub, required this.value, required this.hit, this.id});
}

class RipModeScreen extends StatefulWidget {
  const RipModeScreen({super.key});

  @override
  State<RipModeScreen> createState() => _RipModeScreenState();
}

class _RipModeScreenState extends State<RipModeScreen> {
  final List<_Pull> pulls = [];
  bool done = false;
  final _rand = Random();

  double get total => pulls.fold(0, (s, p) => s + p.value);
  double get mult => total / _packCost;
  int get luck => (mult * 17).round().clamp(0, 99);
  _Pull? get best => pulls.isEmpty ? null : pulls.reduce((m, p) => p.value > m.value ? p : m);

  void _pull() {
    setState(() {
      if (_rand.nextDouble() < 0.28) {
        final c = cards[_rand.nextInt(cards.length)];
        final store = context.read<Store>();
        final live = store.cards[c.id]!.price;
        store.addToCollection(c.id);
        pulls.insert(0, _Pull(name: c.name, sub: '${c.number} · ${c.set}', value: live, hit: true, id: c.id));
      } else {
        final name = _commons[_rand.nextInt(_commons.length)];
        final value = ((0.15 + _rand.nextDouble() * 1.1) * 100).round() / 100;
        pulls.insert(0, _Pull(name: name, sub: 'common / uncommon', value: value, hit: false));
      }
    });
  }

  void _reset() => setState(() {
        pulls.clear();
        done = false;
      });

  @override
  Widget build(BuildContext context) {
    final nav = context.read<Nav>();
    final t = theme.cameraTheme;

    if (done) {
      return Container(
        color: t.bg,
        padding: const EdgeInsets.all(22),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF0B1017),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF2B3139)),
                image: const DecorationImage(image: AssetImage('assets/illustrations/recap-bg.png'), fit: BoxFit.cover, opacity: 0.9),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('RIP RECAP · BOOSTER', style: TextStyle(color: t.muted, fontSize: 9.5, letterSpacing: 1.5)),
                      Text('CARDVAULT', style: TextStyle(color: t.muted, fontSize: 9.5, letterSpacing: 1.5)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (best != null) ui.CardThumb(cardId: best!.id, w: 52, h: 72),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text.rich(TextSpan(children: [
                              TextSpan(text: '\$${fmt(_packCost)} → \$${fmt(total)} ', style: const TextStyle(color: Color(0xFFEDF1F7), fontSize: 22, fontWeight: FontWeight.w700)),
                              TextSpan(text: '${mult.toStringAsFixed(1)}×', style: TextStyle(color: t.detect)),
                            ])),
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                'Best pull: ${best?.name ?? '—'} · Luck: top ${100 - luck}% of rips',
                                style: TextStyle(color: t.muted, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text('Share-ready recap — social export lands with the growth build.', style: TextStyle(color: t.muted, fontSize: 11.5), textAlign: TextAlign.center),
            ),
            GestureDetector(
              onTap: _reset,
              child: Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.symmetric(vertical: 12),
                alignment: Alignment.center,
                decoration: BoxDecoration(color: t.gold, borderRadius: BorderRadius.circular(11)),
                child: const Text('Rip another pack', style: TextStyle(color: Color(0xFF131316), fontSize: 13, fontWeight: FontWeight.w700)),
              ),
            ),
            GestureDetector(
              onTap: nav.pop,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text('Close', style: TextStyle(color: t.muted, fontSize: 13)),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      color: t.bg,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Rip Mode', style: TextStyle(color: t.ink, fontSize: 16, fontWeight: FontWeight.w700)),
                GestureDetector(onTap: nav.pop, child: Text('✕', style: TextStyle(color: t.muted, fontSize: 16))),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Booster pack · cost \$${fmt(_packCost)}', style: TextStyle(color: t.muted, fontSize: 11.5)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              children: [
                Text('\$${fmt(total)}', style: theme.fontHeavy(fontSize: 40, color: t.detect)),
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFF1E2B26), borderRadius: BorderRadius.circular(999)),
                  child: Text('${mult.toStringAsFixed(1)}× pack cost', style: TextStyle(color: t.detect, fontSize: 12, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Luck vs this set', style: TextStyle(color: t.muted, fontSize: 10.5)),
                    Text('top ${100 - luck}%', style: TextStyle(color: t.muted, fontSize: 10.5)),
                  ],
                ),
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  height: 5,
                  decoration: BoxDecoration(color: const Color(0xFF23262C), borderRadius: BorderRadius.circular(3)),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: luck / 100,
                    child: Container(decoration: BoxDecoration(color: t.gold, borderRadius: BorderRadius.circular(3))),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
              children: [
                if (pulls.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.asset('assets/illustrations/pack.png', width: 190, height: 238, fit: BoxFit.cover),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text('Flip cards past the camera — each one tallies here.', style: TextStyle(color: t.muted, fontSize: 12.5), textAlign: TextAlign.center),
                        ),
                      ],
                    ),
                  ),
                ...pulls.asMap().entries.map((entry) {
                  final i = entry.key;
                  final p = entry.value;
                  final isHitFirst = p.hit && i == 0;
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 10),
                    margin: EdgeInsets.zero,
                    decoration: BoxDecoration(
                      color: isHitFirst ? const Color(0xFF1C2B24) : null,
                      borderRadius: isHitFirst ? BorderRadius.circular(10) : null,
                      border: isHitFirst
                          ? Border.all(color: const Color(0xFF2E5B47))
                          : const Border(bottom: BorderSide(color: Color(0xFF1E2126))),
                    ),
                    child: Row(
                      children: [
                        ui.CardThumb(cardId: p.id, w: 26, h: 36),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.name, style: TextStyle(color: t.ink, fontSize: 12.5, fontWeight: p.hit ? FontWeight.w700 : FontWeight.w400)),
                              Text(p.sub, style: TextStyle(color: t.muted, fontSize: 10.5)),
                            ],
                          ),
                        ),
                        Text('\$${fmt(p.value)}', style: TextStyle(color: p.hit ? t.detect : t.muted, fontSize: 13, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Expanded(
                  flex: 14,
                  child: GestureDetector(
                    onTap: _pull,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(border: Border.all(color: const Color(0xFF3A3F47), width: 1.5), borderRadius: BorderRadius.circular(11)),
                      child: Text('Pull next card (simulated)', style: TextStyle(color: t.ink, fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: pulls.isEmpty ? null : () => setState(() => done = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: t.gold, borderRadius: BorderRadius.circular(11)),
                      child: const Text('End rip', style: TextStyle(color: Color(0xFF131316), fontSize: 13, fontWeight: FontWeight.w700)),
                    ),
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
