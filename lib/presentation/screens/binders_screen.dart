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
import '../../features/binders/domain/entities/binder.dart' as api;
import '../../features/binders/presentation/bloc/binder_bloc.dart';
import '../../features/binders/presentation/bloc/binder_event.dart';
import '../../features/collection/domain/entities/collection_item.dart';
import '../../features/collection/presentation/bloc/collection_bloc.dart';
import '../../features/collection/presentation/bloc/collection_event.dart';
import '../../nav.dart';
import '../../theme.dart' as theme;
import '../../widgets/ui.dart' as ui;

class _GameSlice {
  final String game;
  final double value;

  /// null when day-open pricing isn't available yet — see MOBILE_API.md:
  /// `dayOpenPrice` is currently null for every catalog card.
  final double? changeFrac;
  _GameSlice({required this.game, required this.value, this.changeFrac});
}

class _PortfolioStats {
  final double value;
  final double? changeFrac;
  final int totalCards;
  final List<_GameSlice> byGame;
  _PortfolioStats({
    required this.value,
    required this.changeFrac,
    required this.totalCards,
    required this.byGame,
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
  var totalCards = 0;
  final byGameValue = <String, double>{};
  final byGameBase = <String, double>{};
  final byGameOpen = <String, double>{};
  final byGameAllOpen = <String, bool>{};

  for (final item in items) {
    final price = item.catalogCard.priceFor(priceCategory) ?? 0;
    final basePrice = item.catalogCard.price ?? 0;
    final lineValue = price * item.quantity;
    value += lineValue;
    baseValue += basePrice * item.quantity;
    totalCards += item.quantity;

    final label = api.GameApiValue.fromApiValue(item.catalogCard.game).label;
    byGameValue[label] = (byGameValue[label] ?? 0) + lineValue;
    byGameBase[label] = (byGameBase[label] ?? 0) + basePrice * item.quantity;
    byGameAllOpen.putIfAbsent(label, () => true);

    final open = item.catalogCard.dayOpenPrice;
    if (open == null) {
      allHaveOpen = false;
      byGameAllOpen[label] = false;
    } else {
      openTotal += open * item.quantity;
      byGameOpen[label] = (byGameOpen[label] ?? 0) + open * item.quantity;
    }
  }

  final byGame = byGameValue.entries.map((e) {
    final open = byGameOpen[e.key];
    final base = byGameBase[e.key];
    final hasChange =
        byGameAllOpen[e.key] == true &&
        open != null &&
        open > 0 &&
        base != null;
    return _GameSlice(
      game: e.key,
      value: e.value,
      changeFrac: hasChange ? base / open - 1 : null,
    );
  }).toList()..sort((a, b) => b.value.compareTo(a.value));

  return _PortfolioStats(
    value: value,
    changeFrac: allHaveOpen && openTotal > 0 ? baseValue / openTotal - 1 : null,
    totalCards: totalCards,
    byGame: byGame,
  );
}

class BindersScreen extends StatefulWidget {
  const BindersScreen({super.key});

  @override
  State<BindersScreen> createState() => _BindersScreenState();
}

class _BindersScreenState extends State<BindersScreen> {
  String segment = 'binders';

  @override
  void initState() {
    super.initState();
    final bloc = context.read<CollectionBloc>();
    if (bloc.state.myCollection is ResourceInitial) {
      bloc.add(const LoadMyCollection());
    }
  }

  void _openNewBinder() {
    final t = theme.exchange;
    final nameController = TextEditingController();
    api.Game selected = api.Game.mtg;
    String? error;

    showDialog(
      context: context,
      barrierColor: const Color(0x8C000000),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Dialog(
          backgroundColor: t.panel,
          insetPadding: const EdgeInsets.all(24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: t.line),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'New binder',
                  style: TextStyle(
                    color: t.ink,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pick its game — only cards of that game can go in.',
                  style: TextStyle(color: t.muted, fontSize: 11.5),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: nameController,
                  style: TextStyle(color: t.ink, fontSize: 13.5),
                  decoration: InputDecoration(
                    hintText: 'Binder name',
                    hintStyle: TextStyle(color: t.muted),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 8),
                ...api.Game.values.map((g) {
                  return InkWell(
                    onTap: () => setDialogState(() => selected = g),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(top: BorderSide(color: t.line)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            g.label,
                            style: TextStyle(
                              color: t.ink,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (selected == g)
                            Text(
                              'selected',
                              style: TextStyle(color: theme.gold, fontSize: 12),
                            ),
                        ],
                      ),
                    ),
                  );
                }),
                if (error != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    error!,
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 12,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () async {
                    final name = nameController.text.trim();
                    if (name.isEmpty) {
                      setDialogState(() => error = 'Give it a name');
                      return;
                    }
                    final either = await context.read<BinderBloc>().createBinder(
                      name,
                      selected,
                    );
                    either.match(
                      (failure) => setDialogState(() => error = failure.error),
                      (_) => Navigator.of(ctx).pop(),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: theme.gold,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Create',
                      style: TextStyle(
                        color: Color(0xFF0B0E11),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<Store>();
    final t = theme.exchange;
    final collectionAsync = context.watch<CollectionBloc>().state.myCollection;
    final priceCategory = context.watch<PriceCategoryBloc>().state.category;

    return Container(
      color: t.bg,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          Text('Binders', style: theme.fontDisplay(fontSize: 20, color: t.ink)),
          const SizedBox(height: 4),
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
              child: Text(
                e is Failure ? e.error : e.toString(),
                style: const TextStyle(color: Colors.redAccent, fontSize: 12.5),
              ),
            ),
            data: (items) {
              final stats = _computePortfolioStats(items, priceCategory);
              final up = (stats.changeFrac ?? 0) >= 0;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total collection value · ${stats.totalCards} cards',
                    style: TextStyle(color: t.muted, fontSize: 12),
                  ),
                  Text(
                    '\$${fmt(stats.value)}',
                    style: theme.fontHeavy(fontSize: 34, color: t.ink),
                  ),
                  Text(
                    stats.changeFrac == null
                        ? 'day change pending pricing data'
                        : '${up ? '▲' : '▼'} ${pct(stats.changeFrac!)} today',
                    style: TextStyle(
                      color: stats.changeFrac == null
                          ? t.muted
                          : (up ? t.up : t.down),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (stats.byGame.length > 1) ...[
                    const SizedBox(height: 14),
                    Row(
                      children: stats.byGame
                          .map(
                            (g) => Expanded(
                              flex: (g.value * 100).round().clamp(1, 1000000),
                              child: Container(
                                height: 6,
                                color: Color(
                                  gameColors[g.game] ?? theme.gold.toARGB32(),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 6),
                    ...stats.byGame.map(
                      (g) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: Color(
                                  gameColors[g.game] ?? theme.gold.toARGB32(),
                                ),
                                shape: BoxShape.circle,
                              ),
                            ),
                            Expanded(
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: gameShort[g.game] ?? g.game,
                                      style: TextStyle(
                                        color: t.ink,
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    TextSpan(
                                      text: stats.value > 0
                                          ? '  ${((g.value / stats.value) * 100).round()}%'
                                          : '',
                                      style: TextStyle(
                                        color: t.muted,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Text(
                              '\$${fmt(g.value)}',
                              style: TextStyle(
                                color: t.ink,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(
                              width: 64,
                              child: Text(
                                g.changeFrac == null ? '—' : pct(g.changeFrac!),
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  color: g.changeFrac == null
                                      ? t.muted
                                      : (g.changeFrac! >= 0 ? t.up : t.down),
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: t.panel,
              border: Border.all(color: t.line),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Row(
              children:
                  [
                    ('binders', 'Binders'),
                    ('singles', 'Single cards'),
                    (
                      'wishlist',
                      'Wishlist${store.wishlist.isNotEmpty ? ' · ${store.wishlist.length}' : ''}',
                    ),
                    ('public', 'Public'),
                  ].map((seg) {
                    final on = segment == seg.$1;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => segment = seg.$1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: on ? theme.gold : null,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            seg.$2,
                            style: TextStyle(
                              color: on ? const Color(0xFF0B0E11) : t.muted,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          if (segment == 'binders') _BinderList(onNew: _openNewBinder),
          if (segment == 'singles') const _SingleCards(),
          if (segment == 'wishlist') const _WishlistSection(),
          if (segment == 'public') const _PublicBinders(),
        ],
      ),
    );
  }
}

class _BinderList extends StatefulWidget {
  final VoidCallback onNew;
  const _BinderList({required this.onNew});

  @override
  State<_BinderList> createState() => _BinderListState();
}

class _BinderListState extends State<_BinderList> {
  @override
  void initState() {
    super.initState();
    final bloc = context.read<BinderBloc>();
    if (bloc.state.myBinders is ResourceInitial) {
      bloc.add(const LoadMyBinders());
    }
  }

  @override
  Widget build(BuildContext context) {
    final nav = context.read<Nav>();
    final t = theme.exchange;
    final bindersAsync = context.watch<BinderBloc>().state.myBinders;

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: bindersAsync.when(
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
              style: const TextStyle(color: Colors.redAccent, fontSize: 12.5),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (binders) => Column(
          children: [
            if (binders.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: ui.EmptyState(
                  image: 'assets/illustrations/empty-binder.png',
                  text: 'No binders yet — create one to start organizing your cards.',
                ),
              ),
            ...binders.map((b) {
              return GestureDetector(
                onTap: () => nav.push(NavOverlay.binder(b.id)),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: t.line)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: b.name,
                                    style: TextStyle(
                                      color: t.ink,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (b.isPublic)
                                    TextSpan(
                                      text: ' PUBLIC',
                                      style: TextStyle(
                                        color: t.up,
                                        fontSize: 10,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Text(
                              b.game.label,
                              style: TextStyle(color: t.muted, fontSize: 11.5),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'view ›',
                        style: TextStyle(color: t.muted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              );
            }),
            GestureDetector(
              onTap: widget.onNew,
              child: Container(
                margin: const EdgeInsets.only(top: 14),
                padding: const EdgeInsets.symmetric(vertical: 12),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFF2B3139),
                    width: 1.5,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '+ New binder — pick a game',
                  style: TextStyle(color: t.muted, fontSize: 12.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PublicBinders extends StatefulWidget {
  const _PublicBinders();

  @override
  State<_PublicBinders> createState() => _PublicBindersState();
}

class _PublicBindersState extends State<_PublicBinders> {
  @override
  void initState() {
    super.initState();
    final bloc = context.read<BinderBloc>();
    if (bloc.state.publicBinders is ResourceInitial) {
      bloc.add(const LoadPublicBinders());
    }
  }

  @override
  Widget build(BuildContext context) {
    final nav = context.read<Nav>();
    final t = theme.exchange;
    final pageAsync = context.watch<BinderBloc>().state.publicBinders;

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: pageAsync.when(
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
              style: const TextStyle(color: Colors.redAccent, fontSize: 12.5),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (page) => page.items.isEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'No public binders yet',
                    style: TextStyle(color: t.muted, fontSize: 12.5),
                  ),
                ),
              )
            : Column(
                children: page.items.map((b) {
                  return GestureDetector(
                    onTap: () => nav.push(NavOverlay.binder(b.id)),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: t.line)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  b.name,
                                  style: TextStyle(
                                    color: t.ink,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  b.game.label,
                                  style: TextStyle(
                                    color: t.muted,
                                    fontSize: 11.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'view ›',
                            style: TextStyle(color: t.muted, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
      ),
    );
  }
}

class _SingleCards extends StatefulWidget {
  const _SingleCards();

  @override
  State<_SingleCards> createState() => _SingleCardsState();
}

class _SingleCardsState extends State<_SingleCards> {
  String game = 'All';

  @override
  void initState() {
    super.initState();
    context.read<BinderBloc>().add(const LoadCardBinderNames());
  }

  Future<void> _openAssign(String catalogCardId, api.Game cardGame) async {
    final t = theme.exchange;
    List<api.Binder> compatible;
    try {
      final all = await context.read<BinderBloc>().myBindersOrLoad();
      compatible = all.where((b) => b.game == cardGame).toList();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not load binders: $e')));
      return;
    }
    if (!mounted) return;

    final selectedBinderId = await showDialog<String>(
      context: context,
      barrierColor: const Color(0x8C000000),
      builder: (ctx) => Dialog(
        backgroundColor: t.panel,
        insetPadding: const EdgeInsets.all(24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: t.line),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add to a binder',
                style: TextStyle(
                  color: t.ink,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${cardGame.label} binders only',
                style: TextStyle(color: t.muted, fontSize: 11.5),
              ),
              const SizedBox(height: 8),
              if (compatible.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    'No ${cardGame.label} binder yet — create one from the Binders tab first.',
                    style: TextStyle(color: t.muted, fontSize: 12.5),
                  ),
                ),
              ...compatible.map((b) {
                return InkWell(
                  onTap: () => Navigator.of(ctx).pop(b.id),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: t.line)),
                    ),
                    child: Text(
                      b.name,
                      style: TextStyle(
                        color: t.ink,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );

    if (selectedBinderId == null) return;
    final either = await context.read<BinderBloc>().addCardToBinder(
      selectedBinderId,
      catalogCardId,
    );
    if (!mounted) return;
    either.match(
      (failure) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failure.error))),
      (_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Added to binder ✓')));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final nav = context.read<Nav>();
    final t = theme.exchange;
    final collectionAsync = context.watch<CollectionBloc>().state.myCollection;
    final priceCategory = context.watch<PriceCategoryBloc>().state.category;
    final binderNames = context.watch<BinderBloc>().state.cardBinderNames.valueOrNull ?? {};

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: collectionAsync.when(
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
              style: const TextStyle(color: Colors.redAccent, fontSize: 12.5),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: ui.EmptyState(
                image: 'assets/illustrations/empty-listings.png',
                text:
                    'Nothing in your collection yet — scan a card to get started.',
              ),
            );
          }

          final gamesOwned = [
            'All',
            ...{
              for (final i in items)
                api.GameApiValue.fromApiValue(i.catalogCard.game).label,
            },
          ];
          final owned =
              items
                  .where(
                    (i) =>
                        game == 'All' ||
                        api.GameApiValue.fromApiValue(
                              i.catalogCard.game,
                            ).label ==
                            game,
                  )
                  .toList()
                ..sort(
                  (a, b) =>
                      ((b.catalogCard.priceFor(priceCategory) ?? 0) *
                              b.quantity)
                          .compareTo(
                            (a.catalogCard.priceFor(priceCategory) ?? 0) *
                                a.quantity,
                          ),
                );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: gamesOwned.map((g) {
                  return GestureDetector(
                    onTap: () => setState(() => game = g),
                    child: ui.Chip(
                      label: gameShort[g] ?? g,
                      bg: game == g ? t.panel : null,
                      color: game == g ? theme.gold : t.muted,
                      border: game == g ? null : t.line,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
              ...owned.map((item) {
                final card = item.catalogCard;
                final cardGame = api.GameApiValue.fromApiValue(card.game);
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: t.line)),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.network(
                          card.imageUrl,
                          width: 38,
                          height: 53,
                          fit: BoxFit.cover,
                          errorBuilder: (context, err, stack) =>
                              Container(width: 38, height: 53, color: t.panel),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: card.name,
                                    style: TextStyle(
                                      color: t.ink,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (item.quantity > 1)
                                    TextSpan(
                                      text: ' ×${item.quantity}',
                                      style: TextStyle(
                                        color: theme.gold,
                                        fontSize: 11,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Text(
                              '${cardGame.label} · ${card.setName}',
                              style: TextStyle(color: t.muted, fontSize: 11.5),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '\$${fmt((card.priceFor(priceCategory) ?? 0) * item.quantity)}',
                            style: TextStyle(
                              color: t.ink,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Builder(
                            builder: (_) {
                              final inBinders =
                                  binderNames[item.catalogCardId] ?? const [];
                              if (inBinders.isEmpty) {
                                return GestureDetector(
                                  onTap: () =>
                                      _openAssign(item.catalogCardId, cardGame),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: theme.gold,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      '→ binder',
                                      style: TextStyle(
                                        color: Color(0xFF0B0E11),
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                );
                              }
                              final label = inBinders.length > 1
                                  ? '${inBinders.first.name} +${inBinders.length - 1}'
                                  : inBinders.first.name;
                              return GestureDetector(
                                onTap: () => nav.push(
                                  NavOverlay.binder(inBinders.first.id),
                                ),
                                child: Container(
                                  constraints: const BoxConstraints(
                                    maxWidth: 96,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: t.line),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    label,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: t.muted,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  'Every scan lands here — assign copies into game-matching binders.',
                  style: TextStyle(color: t.muted, fontSize: 11),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _WishlistSection extends StatelessWidget {
  const _WishlistSection();

  @override
  Widget build(BuildContext context) {
    final store = context.watch<Store>();
    final nav = context.read<Nav>();
    final t = theme.exchange;
    final items = store.wishlist
        .map((id) => store.cards[id])
        .whereType<Card>()
        .toList();
    final total = items.fold<double>(0, (s, c) => s + c.price);

    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 8),
        child: ui.EmptyState(
          image: 'assets/illustrations/empty-listings.png',
          text:
              'Nothing on your wishlist — star ★ cards in Search or on any card page. Sellers see your wants and can offer their copy.',
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 6),
            decoration: BoxDecoration(
              color: t.panel,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Cost to complete · ${items.length} card${items.length > 1 ? 's' : ''}',
                  style: TextStyle(color: t.muted, fontSize: 11.5),
                ),
                Text(
                  '\$${fmt(total)}',
                  style: TextStyle(
                    color: theme.gold,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          ...items.map((c) {
            final listedNow = store.market.any(
              (l) =>
                  l.status == MarketStatus.available &&
                  l.kind == MarketKind.card &&
                  l.cardIds[0] == c.id,
            );
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 9),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: t.line)),
              ),
              child: Row(
                children: [
                  ui.CardThumb(cardId: c.id, w: 38, h: 53),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => nav.push(NavOverlay.card(c.id)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c.name,
                            style: TextStyle(
                              color: t.ink,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${c.game} · ${c.set}',
                            style: TextStyle(color: t.muted, fontSize: 11.5),
                          ),
                          // if (listedNow)
                          //   GestureDetector(
                          //     onTap: () => nav.setTab(AppTab.sell),
                          //     child: Padding(
                          //       padding: const EdgeInsets.only(top: 2),
                          //       child: Text(
                          //         '● listed on the market now →',
                          //         style: TextStyle(
                          //           color: t.up,
                          //           fontSize: 11,
                          //           fontWeight: FontWeight.w700,
                          //         ),
                          //       ),
                          //     ),
                          //   ),
                        ],
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${fmt(c.price)}',
                        style: TextStyle(
                          color: t.ink,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 5),
                      GestureDetector(
                        onTap: () => store.toggleWishlist(c.id),
                        child: Text(
                          '★',
                          style: TextStyle(color: theme.gold, fontSize: 17),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              "Sellers see these wants — you'll be pinged when one is listed under market.",
              style: TextStyle(color: t.muted, fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
