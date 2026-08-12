import 'package:flutter/material.dart' hide Card;
import 'package:provider/provider.dart';
import '../../data/mock_db.dart';
import '../../data/store.dart';
import '../../data/types.dart';
import '../../nav.dart';
import '../../theme.dart' as theme;
import '../../widgets/ui.dart' as ui;

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<Store>();
    final nav = context.read<Nav>();
    final t = theme.light;
    final value = store.portfolioValue();
    final change = store.portfolioDayChange();
    final byGame = store.portfolioByGame();
    final movers = store.cards.values
        .map((c) => (c: c, ch: c.price / c.dayOpen - 1))
        .toList()
      ..sort((a, b) => b.ch.abs().compareTo(a.ch.abs()));
    final topMovers = movers.take(4).toList();

    return Container(
      color: t.bg,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('CardVault', style: theme.fontDisplay(fontSize: 20, color: t.ink)),
              Text('demo data · live ticker', style: TextStyle(color: t.muted, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => nav.push(NavOverlay.search()),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: t.panel,
                border: Border.all(color: t.line),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text('Search any card — name, set, or game…', style: TextStyle(color: t.muted, fontSize: 13.5)),
            ),
          ),
          GestureDetector(
            onTap: () => nav.setTab(AppTab.binders),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: t.panel,
                border: Border.all(color: t.line),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Portfolio value', style: TextStyle(color: t.muted, fontSize: 12)),
                  Text('\$${fmt(value)}', style: theme.fontHeavy(fontSize: 32, color: t.ink)),
                  Text(
                    '${change >= 0 ? '▲' : '▼'} ${pct(change)} today',
                    style: TextStyle(color: change >= 0 ? t.up : t.down, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  ui.Sparkline(
                    data: store.portfolioSeries.length > 1 ? store.portfolioSeries : [value, value],
                    color: change >= 0 ? t.up : t.down,
                    width: 300,
                    height: 44,
                  ),
                  if (byGame.length > 1)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: byGame.map((g) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(color: t.bg, borderRadius: BorderRadius.circular(999)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 7,
                                  height: 7,
                                  margin: const EdgeInsets.only(right: 6),
                                  decoration: BoxDecoration(
                                    color: Color(gameColors[g.game] ?? theme.gold.toARGB32()),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Text(
                                  '${gameShort[g.game] ?? g.game} \$${fmt(g.value)}',
                                  style: TextStyle(color: t.ink2, fontSize: 11, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => nav.setTab(AppTab.scan),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    decoration: BoxDecoration(color: t.accentBg, borderRadius: BorderRadius.circular(12)),
                    alignment: Alignment.center,
                    child: Text('Scan a card', style: TextStyle(color: t.accent, fontSize: 14, fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () => nav.setTab(AppTab.binders),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    decoration: BoxDecoration(
                      color: t.panel,
                      border: Border.all(color: t.line),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text('My binders', style: TextStyle(color: t.ink, fontSize: 14, fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => nav.push(NavOverlay.signals()),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: t.panel,
                      border: Border.all(color: t.line),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Signals', style: TextStyle(color: t.ink, fontSize: 13.5, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text('hold-or-sell advice on cards you own', style: TextStyle(color: t.muted, fontSize: 11)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () => nav.push(NavOverlay.radar()),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: t.panel,
                      border: Border.all(color: t.line),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Deal radar', style: TextStyle(color: t.ink, fontSize: 13.5, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text('listings below market, live', style: TextStyle(color: t.muted, fontSize: 11)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 22, bottom: 8),
            child: Text("Today's movers in your collection", style: TextStyle(color: t.ink, fontSize: 15, fontWeight: FontWeight.w600)),
          ),
          ...topMovers.map((m) {
            final c = m.c;
            final ch = m.ch;
            return Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: t.panel,
                border: Border.all(color: t.line),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  ui.CardThumb(cardId: c.id, w: 30, h: 42),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => nav.push(NavOverlay.card(c.id)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${c.name} · ${c.number}', style: TextStyle(color: t.ink, fontSize: 13.5, fontWeight: FontWeight.w600)),
                          Text(c.set, style: TextStyle(color: t.muted, fontSize: 11.5)),
                        ],
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('\$${fmt(c.price)}', style: TextStyle(color: t.ink, fontSize: 13.5, fontWeight: FontWeight.w600)),
                      Text(pct(ch), style: TextStyle(color: ch >= 0 ? t.up : t.down, fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
            );
          }),
          Padding(
            padding: const EdgeInsets.only(top: 22, bottom: 8),
            child: Text('Your listings', style: TextStyle(color: t.ink, fontSize: 15, fontWeight: FontWeight.w600)),
          ),
          if (store.listings.isEmpty)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: t.panel,
                border: Border.all(color: t.line),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: const ui.EmptyState(
                image: 'assets/illustrations/empty-listings.png',
                text: 'Nothing listed yet — scan a card and tap Sell now.',
                size: 150,
              ),
            )
          else
            ...store.listings.map((l) {
              final c = store.cards[l.cardId]!;
              final sold = l.status == ListingStatus.sold;
              return Opacity(
                opacity: sold ? 0.75 : 1,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: t.panel,
                    border: Border.all(color: t.line),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      ui.CardThumb(cardId: c.id, w: 30, h: 42),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${c.name} · ${l.condition.code}', style: TextStyle(color: t.ink, fontSize: 13.5, fontWeight: FontWeight.w600)),
                            Text(l.markets.join(' + '), style: TextStyle(color: t.muted, fontSize: 11.5)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('\$${fmt(l.price)}', style: TextStyle(color: t.ink, fontSize: 13.5, fontWeight: FontWeight.w600)),
                          ui.Chip(
                            label: sold ? 'sold' : 'active',
                            bg: sold ? const Color(0x242BD48A) : t.accentBg,
                            color: sold ? t.up : t.accent,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
