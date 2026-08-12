import 'dart:async';
import 'package:flutter/material.dart' hide Card;
import 'package:provider/provider.dart';
import '../../data/services.dart';
import '../../data/store.dart';
import '../../data/types.dart';
import '../../nav.dart';
import '../../theme.dart' as theme;
import '../../widgets/ui.dart' as ui;

const _conditions = [Condition.nm, Condition.lp, Condition.mp, Condition.hp];
const _speeds = [
  ('fast', 'Fast sale', 0.94, 1),
  ('market', 'Market', 1.0, 3),
  ('max', 'Max value', 1.07, 9),
];
const _markets = ['In-app', 'eBay', 'TCGplayer'];

class QuickSellSheet extends StatefulWidget {
  final String cardId;
  final Condition condition;
  const QuickSellSheet({super.key, required this.cardId, required this.condition});

  @override
  State<QuickSellSheet> createState() => _QuickSellSheetState();
}

class _QuickSellSheetState extends State<QuickSellSheet> {
  late Condition condition = widget.condition;
  String speed = 'market';
  List<String> markets = ['In-app', 'eBay'];
  bool published = false;

  void _toggleMarket(String m) {
    setState(() {
      if (markets.contains(m)) {
        if (markets.length > 1) markets = markets.where((x) => x != m).toList();
      } else {
        markets = [...markets, m];
      }
    });
  }

  void _publish(Store store, Nav nav) {
    final c = store.cards[widget.cardId]!;
    final base = pricing.suggestListing(c, condition);
    final sp = _speeds.firstWhere((x) => x.$1 == speed);
    final price = (base.price * sp.$3 * 100).round() / 100;
    final fees = (price * (pricing.marketplaceFeeRate + 0.012) * 100).round() / 100;
    store.addListing(cardId: widget.cardId, condition: condition, price: price, fees: fees, markets: markets);
    setState(() => published = true);
    Timer(const Duration(milliseconds: 1100), nav.pop);
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<Store>();
    final nav = context.read<Nav>();
    final t = theme.light;
    final c = store.cards[widget.cardId]!;
    final base = pricing.suggestListing(c, condition);
    final sp = _speeds.firstWhere((x) => x.$1 == speed);
    final price = (base.price * sp.$3 * 100).round() / 100;
    final fees = (price * (pricing.marketplaceFeeRate + 0.012) * 100).round() / 100;
    final receive = ((price - fees) * 100).round() / 100;
    final days = sp.$4;

    return Material(
      color: const Color(0x73000000),
      child: GestureDetector(
        onTap: nav.pop,
        child: Column(
          children: [
            const Expanded(child: SizedBox.expand()),
            GestureDetector(
              onTap: () {},
              child: Container(
                decoration: BoxDecoration(color: t.bg, borderRadius: const BorderRadius.vertical(top: Radius.circular(22))),
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 26),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(width: 36, height: 4, margin: const EdgeInsets.only(bottom: 10), alignment: Alignment.center, decoration: BoxDecoration(color: t.line, borderRadius: BorderRadius.circular(2))),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Quick sell', style: TextStyle(color: t.ink, fontSize: 17, fontWeight: FontWeight.w700)),
                          GestureDetector(onTap: nav.pop, child: Text('✕', style: TextStyle(color: t.muted, fontSize: 16))),
                        ],
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 12),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: t.panel, border: Border.all(color: t.line), borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          children: [
                            ui.CardThumb(cardId: c.id, w: 34, h: 48),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${c.name} · ${c.number}', style: TextStyle(color: t.ink, fontSize: 13.5, fontWeight: FontWeight.w600)),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 1),
                                    child: Text('Photos + comps auto-filled from your scan', style: TextStyle(color: t.muted, fontSize: 11.5)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 14, bottom: 6),
                        child: Text.rich(TextSpan(children: [
                          TextSpan(text: 'Condition ', style: TextStyle(color: t.muted, fontSize: 12)),
                          TextSpan(text: '· AI suggests ${widget.condition.code}', style: TextStyle(color: t.up)),
                        ])),
                      ),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: _conditions.map((k) {
                          final on = condition == k;
                          return GestureDetector(
                            onTap: () => setState(() => condition = k),
                            child: ui.Chip(label: k.code, bg: on ? t.ink : null, border: on ? null : t.line, color: on ? t.bg : t.ink2),
                          );
                        }).toList(),
                      ),
                      Padding(padding: const EdgeInsets.only(top: 14, bottom: 6), child: Text('Pricing', style: TextStyle(color: t.muted, fontSize: 12))),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: _speeds.map((s) {
                          final on = speed == s.$1;
                          return GestureDetector(
                            onTap: () => setState(() => speed = s.$1),
                            child: ui.Chip(label: s.$2, bg: on ? t.accentBg : null, border: on ? null : t.line, color: on ? t.accent : t.ink2),
                          );
                        }).toList(),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: t.panel, border: Border.all(color: t.line), borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Your price', style: TextStyle(color: t.muted, fontSize: 12)),
                                Text('\$${fmt(price)}', style: TextStyle(color: t.ink, fontSize: 22, fontWeight: FontWeight.w700)),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 3),
                              child: Text('sells in ~$days day${days > 1 ? 's' : ''} at this price', style: TextStyle(color: t.up, fontSize: 11.5)),
                            ),
                          ],
                        ),
                      ),
                      Padding(padding: const EdgeInsets.only(top: 14, bottom: 6), child: Text('Marketplaces', style: TextStyle(color: t.muted, fontSize: 12))),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: _markets.map((m) {
                          final on = markets.contains(m);
                          return GestureDetector(
                            onTap: () => _toggleMarket(m),
                            child: ui.Chip(label: on ? '✓ $m' : m, bg: on ? t.accentBg : null, border: on ? null : t.line, color: on ? t.accent : t.ink2),
                          );
                        }).toList(),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Fees (5% + payment)', style: TextStyle(color: t.ink2, fontSize: 12)),
                            Text('−\$${fmt(fees)}', style: TextStyle(color: t.ink2, fontSize: 12)),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('You receive', style: TextStyle(color: t.ink, fontSize: 13.5, fontWeight: FontWeight.w700)),
                            Text('\$${fmt(receive)}', style: TextStyle(color: t.up, fontSize: 13.5, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: published ? null : () => _publish(store, nav),
                        child: Container(
                          margin: const EdgeInsets.only(top: 14),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(color: published ? t.up : t.ink, borderRadius: BorderRadius.circular(12)),
                          child: Text(
                            published ? 'Listed ✓' : 'Publish to ${markets.length} marketplace${markets.length > 1 ? 's' : ''}',
                            style: TextStyle(color: t.bg, fontSize: 14, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
