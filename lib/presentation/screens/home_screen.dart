import 'package:flutter/material.dart' hide Card;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../../core/bloc/resource.dart';
import '../../core/error/failure.dart';
import '../../core/pricing/bloc/price_category_bloc.dart';
import '../../core/pricing/price_category.dart';
import '../../data/mock_db.dart';
import '../../data/store.dart';
import '../../data/types.dart';
import '../../features/binders/domain/entities/binder.dart' as binders;
import '../../features/collection/domain/entities/collection_item.dart';
import '../../features/collection/presentation/bloc/collection_bloc.dart';
import '../../features/collection/presentation/bloc/collection_event.dart';
import '../../nav.dart';
import '../../theme.dart' as theme;
import '../../widgets/ui.dart' as ui;

class _PortfolioMover {
  final CollectionItem item;
  final double changeFrac;
  _PortfolioMover({required this.item, required this.changeFrac});
}

class _GameSlice {
  final String label;
  final Color color;
  final double value;
  _GameSlice({required this.label, required this.color, required this.value});
}

class _PortfolioStats {
  final double value;

  /// null when day-open pricing isn't available yet for (some of) these
  /// cards — see MOBILE_API.md: `dayOpenPrice` is currently null for every
  /// catalog card while the daily-snapshot job accumulates its first day.
  final double? changeFrac;
  final List<_GameSlice> byGame;
  final List<_PortfolioMover> movers;

  _PortfolioStats({
    required this.value,
    required this.changeFrac,
    required this.byGame,
    required this.movers,
  });
}

_PortfolioStats _computePortfolioStats(
  List<CollectionItem> items,
  PriceCategory priceCategory,
) {
  double value = 0;

  /// Totals on the flat `price`/`dayOpenPrice` basis — `dayOpenPrice` isn't
  /// broken out per market, so % change has to be computed against the same
  /// flat price `dayOpenPrice` was benchmarked against, not the price-type
  /// the person picked in Profile (which is only for the displayed $ amounts).
  double baseValue = 0;
  double openTotal = 0;
  var allHaveOpen = items.isNotEmpty;
  final byGameValue = <String, double>{};
  final movers = <_PortfolioMover>[];

  for (final item in items) {
    final price = item.catalogCard.priceFor(priceCategory) ?? 0;
    final basePrice = item.catalogCard.price ?? 0;
    final lineValue = price * item.quantity;
    value += lineValue;
    baseValue += basePrice * item.quantity;
    byGameValue[item.catalogCard.game] =
        (byGameValue[item.catalogCard.game] ?? 0) + lineValue;

    final open = item.catalogCard.dayOpenPrice;
    if (open == null) {
      allHaveOpen = false;
    } else {
      openTotal += open * item.quantity;
      if (open > 0) {
        movers.add(
          _PortfolioMover(item: item, changeFrac: basePrice / open - 1),
        );
      }
    }
  }

  movers.sort((a, b) => b.changeFrac.abs().compareTo(a.changeFrac.abs()));

  final byGame = byGameValue.entries.map((e) {
    final label = binders.GameApiValue.fromApiValue(e.key).label;
    return _GameSlice(
      label: gameShort[label] ?? label,
      color: Color(gameColors[label] ?? theme.gold.toARGB32()),
      value: e.value,
    );
  }).toList()..sort((a, b) => b.value.compareTo(a.value));

  return _PortfolioStats(
    value: value,
    changeFrac: allHaveOpen && openTotal > 0 ? baseValue / openTotal - 1 : null,
    byGame: byGame,
    movers: movers.take(4).toList(),
  );
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    final bloc = context.read<CollectionBloc>();
    if (bloc.state.myCollection is ResourceInitial) {
      bloc.add(const LoadMyCollection());
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<Store>();
    final nav = context.read<Nav>();
    final t = theme.light;
    final collectionAsync = context.watch<CollectionBloc>().state.myCollection;
    final priceCategory = context.watch<PriceCategoryBloc>().state.category;

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
              Text(
                'CardVault',
                style: theme.fontDisplay(fontSize: 20, color: t.ink),
              ),
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
              child: Text(
                'Search any card — name, set, or game…',
                style: TextStyle(color: t.muted, fontSize: 13.5),
              ),
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
              child: collectionAsync.when(
                initial: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Center(child: CircularProgressIndicator()),
                ),
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => Text(
                  e is Failure ? e.error : e.toString(),
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontSize: 12.5,
                  ),
                ),
                data: (items) {
                  final stats = _computePortfolioStats(items, priceCategory);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Portfolio value',
                        style: TextStyle(color: t.muted, fontSize: 12),
                      ),
                      Text(
                        '\$${fmt(stats.value)}',
                        style: theme.fontHeavy(fontSize: 32, color: t.ink),
                      ),
                      Text(
                        stats.changeFrac == null
                            ? 'day change pending pricing data'
                            : '${stats.changeFrac! >= 0 ? '▲' : '▼'} ${pct(stats.changeFrac!)} today',
                        style: TextStyle(
                          color: stats.changeFrac == null
                              ? t.muted
                              : (stats.changeFrac! >= 0 ? t.up : t.down),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (stats.byGame.length > 1)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: stats.byGame.map((g) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: t.bg,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 7,
                                      height: 7,
                                      margin: const EdgeInsets.only(right: 6),
                                      decoration: BoxDecoration(
                                        color: g.color,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    Text(
                                      '${g.label} \$${fmt(g.value)}',
                                      style: TextStyle(
                                        color: t.ink2,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => nav.push(NavOverlay.signals()),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.08,
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: t.panel,
                      border: Border.all(color: t.line),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Signals',
                          style: TextStyle(
                            color: t.ink,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () => nav.setTab(AppTab.binders),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.08,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    decoration: BoxDecoration(
                      color: t.panel,
                      border: Border.all(color: t.line),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'My binders',
                      style: TextStyle(
                        color: t.ink,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
                  onTap: () => nav.setTab(AppTab.scan),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.08,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    decoration: BoxDecoration(
                      color: t.accentBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Scan a card',
                      style: TextStyle(
                        color: t.accent,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 22, bottom: 8),
            child: Text(
              "Today's movers in your collection",
              style: TextStyle(
                color: t.ink,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          collectionAsync.when(
            initial: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            ),
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  e is Failure ? e.error : e.toString(),
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontSize: 12.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            data: (items) {
              final movers = _computePortfolioStats(
                items,
                priceCategory,
              ).movers;
              if (movers.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: t.panel,
                    border: Border.all(color: t.line),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: ui.EmptyState(
                    image: 'assets/illustrations/empty-signals.png',
                    text: items.isEmpty
                        ? 'Nothing in your collection yet — scan a card to get started.'
                        : 'Movers will appear once daily pricing data is available for your cards.',
                    size: 150,
                  ),
                );
              }
              return Column(
                children: movers.map((m) {
                  final card = m.item.catalogCard;
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
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.network(
                            card.imageUrl,
                            width: 30,
                            height: 42,
                            fit: BoxFit.cover,
                            errorBuilder: (context, err, stack) =>
                                Container(width: 30, height: 42, color: t.bg),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${card.name} · ${card.number}',
                                style: TextStyle(
                                  color: t.ink,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                card.setName,
                                style: TextStyle(
                                  color: t.muted,
                                  fontSize: 11.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '\$${fmt(card.priceFor(priceCategory) ?? 0)}',
                              style: TextStyle(
                                color: t.ink,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              pct(m.changeFrac),
                              style: TextStyle(
                                color: m.changeFrac >= 0 ? t.up : t.down,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(top: 22, bottom: 8),
            child: Text(
              'Your listings',
              style: TextStyle(
                color: t.ink,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (!store.listings.isEmpty)
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
            ),
          // else
          //   ...store.listings.map((l) {
          //     final c = store.cards[l.cardId]!;
          //     final sold = l.status == ListingStatus.sold;
          //     return Opacity(
          //       opacity: sold ? 0.75 : 1,
          //       child: Container(
          //         padding: const EdgeInsets.all(10),
          //         margin: const EdgeInsets.only(bottom: 8),
          //         decoration: BoxDecoration(
          //           color: t.panel,
          //           border: Border.all(color: t.line),
          //           borderRadius: BorderRadius.circular(12),
          //         ),
          //         child: Row(
          //           children: [
          //             ui.CardThumb(cardId: c.id, w: 30, h: 42),
          //             const SizedBox(width: 10),
          //             Expanded(
          //               child: Column(
          //                 crossAxisAlignment: CrossAxisAlignment.start,
          //                 children: [
          //                   Text(
          //                     '${c.name} · ${l.condition.code}',
          //                     style: TextStyle(
          //                       color: t.ink,
          //                       fontSize: 13.5,
          //                       fontWeight: FontWeight.w600,
          //                     ),
          //                   ),
          //                   Text(
          //                     l.markets.join(' + '),
          //                     style: TextStyle(color: t.muted, fontSize: 11.5),
          //                   ),
          //                 ],
          //               ),
          //             ),
          //             Column(
          //               crossAxisAlignment: CrossAxisAlignment.end,
          //               children: [
          //                 Text(
          //                   '\$${fmt(l.price)}',
          //                   style: TextStyle(
          //                     color: t.ink,
          //                     fontSize: 13.5,
          //                     fontWeight: FontWeight.w600,
          //                   ),
          //                 ),
          //                 ui.Chip(
          //                   label: sold ? 'sold' : 'active',
          //                   bg: sold ? const Color(0x242BD48A) : t.accentBg,
          //                   color: sold ? t.up : t.accent,
          //                 ),
          //               ],
          //             ),
          //           ],
          //         ),
          //       ),
          //     );
          //   }),
        ],
      ),
    );
  }
}
