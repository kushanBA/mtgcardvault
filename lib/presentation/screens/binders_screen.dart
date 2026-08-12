import 'package:flutter/material.dart' hide Card;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart';
import '../../core/error/failure.dart';
import '../../data/mock_db.dart';
import '../../data/store.dart';
import '../../data/types.dart';
import '../../features/binders/domain/entities/binder.dart' as api;
import '../../features/binders/presentation/providers/binder_providers.dart';
import '../../nav.dart';
import '../../theme.dart' as theme;
import '../../widgets/ui.dart' as ui;

const _frames = ['1D', '1W', '1M', '1Y', 'ALL'];

class BindersScreen extends ConsumerStatefulWidget {
  const BindersScreen({super.key});

  @override
  ConsumerState<BindersScreen> createState() => _BindersScreenState();
}

class _BindersScreenState extends ConsumerState<BindersScreen> {
  String frame = '1D';
  String segment = 'binders';

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
                    final either = await ref.read(createBinderUseCaseProvider)(
                      name,
                      selected,
                    );
                    either.match(
                      (failure) => setDialogState(() => error = failure.error),
                      (_) {
                        ref.invalidate(myBindersProvider);
                        Navigator.of(ctx).pop();
                      },
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
    final value = store.portfolioValue();
    final change = store.portfolioDayChange();
    final up = change >= 0;
    final series = store.portfolioSeries.length > 1
        ? store.portfolioSeries
        : [value * 0.98, value];
    final totalCards = store.collection.values.fold(0, (a, b) => a + b);
    final byGame = store.portfolioByGame();

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
                'Binders',
                style: theme.fontDisplay(fontSize: 20, color: t.ink),
              ),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '● ',
                      style: TextStyle(color: t.up),
                    ),
                    TextSpan(
                      text: 'live · demo ticker',
                      style: TextStyle(color: t.muted, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Total collection value · $totalCards cards',
            style: TextStyle(color: t.muted, fontSize: 12),
          ),
          Text(
            '\$${fmt(value)}',
            style: theme.fontHeavy(fontSize: 34, color: t.ink),
          ),
          Text(
            '${up ? '▲' : '▼'} ${pct(change)} today',
            style: TextStyle(
              color: up ? t.up : t.down,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          ui.Sparkline(
            data: series,
            color: up ? t.up : t.down,
            width: 320,
            height: 56,
          ),
          const SizedBox(height: 10),
          Row(
            children: _frames.map((fr) {
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: GestureDetector(
                  onTap: () => setState(() => frame = fr),
                  child: ui.Chip(
                    label: fr,
                    bg: frame == fr ? t.panel : null,
                    color: frame == fr ? theme.gold : t.muted,
                  ),
                ),
              );
            }).toList(),
          ),
          if (byGame.length > 1) ...[
            const SizedBox(height: 14),
            Row(
              children: byGame
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
            ...byGame.map(
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
                              text: '  ${((g.value / value) * 100).round()}%',
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
                        pct(g.change),
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: g.change >= 0 ? t.up : t.down,
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

class _BinderList extends ConsumerWidget {
  final VoidCallback onNew;
  const _BinderList({required this.onNew});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nav = context.read<Nav>();
    final t = theme.exchange;
    final bindersAsync = ref.watch(myBindersProvider);

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: bindersAsync.when(
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
              onTap: onNew,
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

class _PublicBinders extends ConsumerWidget {
  const _PublicBinders();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nav = context.read<Nav>();
    final t = theme.exchange;
    final pageAsync = ref.watch(publicBindersProvider);

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: pageAsync.when(
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

  void _openAssign(String cardId) {
    final store = context.read<Store>();
    final t = theme.exchange;
    final assignCard = store.cards[cardId]!;
    final compatible = store.binders
        .where(
          (b) =>
              b.game == assignCard.game &&
              b.pockets.any((p) => p.cardId == null),
        )
        .toList();
    showDialog(
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
                'Add ${assignCard.name} to a binder',
                style: TextStyle(
                  color: t.ink,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${assignCard.game} binders only',
                style: TextStyle(color: t.muted, fontSize: 11.5),
              ),
              const SizedBox(height: 8),
              if (compatible.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    'No ${assignCard.game} binder with free pockets — create one from the Binders tab first.',
                    style: TextStyle(color: t.muted, fontSize: 12.5),
                  ),
                ),
              ...compatible.map((b) {
                final free = b.pockets.where((p) => p.cardId == null).length;
                return InkWell(
                  onTap: () {
                    store.addToBinder(b.id, cardId);
                    Navigator.of(ctx).pop();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: t.line)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          b.name,
                          style: TextStyle(
                            color: t.ink,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '$free pockets free',
                          style: TextStyle(color: t.muted, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<Store>();
    final nav = context.read<Nav>();
    final t = theme.exchange;

    final owned =
        store.collection.entries
            .where((e) => e.value > 0)
            .map(
              (e) => (
                card: store.cards[e.key],
                qty: e.value,
                assigned: store.assignedCount(e.key),
              ),
            )
            .where(
              (x) => x.card != null && (game == 'All' || x.card!.game == game),
            )
            .toList()
          ..sort(
            (a, b) => (b.card!.price * b.qty).compareTo(a.card!.price * a.qty),
          );

    final gamesOwned = [
      'All',
      ...games.where(
        (g) => store.collection.entries.any(
          (e) => e.value > 0 && store.cards[e.key]?.game == g,
        ),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: gamesOwned.map((g) {
              return GestureDetector(
                onTap: () => setState(() => game = g),
                child: ui.Chip(
                  label: g == 'Magic: The Gathering' ? 'MTG' : g,
                  bg: game == g ? t.panel : null,
                  color: game == g ? theme.gold : t.muted,
                  border: game == g ? null : t.line,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          ...owned.map((x) {
            final card = x.card!;
            final free = x.qty - x.assigned;
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 9),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: t.line)),
              ),
              child: Row(
                children: [
                  ui.CardThumb(cardId: card.id, w: 38, h: 53),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => nav.push(NavOverlay.card(card.id)),
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
                                if (x.qty > 1)
                                  TextSpan(
                                    text: ' ×${x.qty}',
                                    style: TextStyle(
                                      color: theme.gold,
                                      fontSize: 11,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Text(
                            '${card.game} · ${x.assigned > 0 ? '${x.assigned} in binders · ' : ''}$free loose',
                            style: TextStyle(color: t.muted, fontSize: 11.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${fmt(card.price * x.qty)}',
                        style: TextStyle(
                          color: t.ink,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Opacity(
                        opacity: free < 1 ? 0.4 : 1,
                        child: GestureDetector(
                          onTap: free < 1 ? null : () => _openAssign(card.id),
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
              'Every scan and market buy lands here — assign copies into game-matching binders.',
              style: TextStyle(color: t.muted, fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ),
        ],
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
