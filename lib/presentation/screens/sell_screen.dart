import 'package:flutter/material.dart' hide Card;
import 'package:provider/provider.dart';
import '../../data/store.dart';
import '../../data/types.dart';
import '../../nav.dart';
import '../../theme.dart' as theme;
import '../../widgets/ui.dart' as ui;

const _poolPrice = 14.99;
const _soloPrice = 24.99;

class SellScreen extends StatefulWidget {
  const SellScreen({super.key});

  @override
  State<SellScreen> createState() => _SellScreenState();
}

class _SellScreenState extends State<SellScreen> {
  String segment = 'market';

  @override
  Widget build(BuildContext context) {
    final t = theme.light;
    return Container(
      color: t.bg,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          Text('Market', style: TextStyle(color: t.ink, fontSize: 20, fontWeight: FontWeight.w700)),
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 14),
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(color: t.panel, border: Border.all(color: t.line), borderRadius: BorderRadius.circular(11)),
            child: Row(
              children: [
                ('market', 'Buy'),
                ('wanted', 'Wanted'),
                ('mine', 'My listings'),
              ].map((seg) {
                final on = segment == seg.$1;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => segment = seg.$1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: on ? t.ink : null, borderRadius: BorderRadius.circular(8)),
                      child: Text(seg.$2, style: TextStyle(color: on ? t.bg : t.ink2, fontSize: 12.5, fontWeight: FontWeight.w700)),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          if (segment == 'market') const _MarketFeed(),
          if (segment == 'wanted') const _WantedFeed(),
          if (segment == 'mine') const _MyListings(),
        ],
      ),
    );
  }
}

class _SellerHeader extends StatelessWidget {
  final MarketListing l;
  const _SellerHeader({required this.l});

  @override
  Widget build(BuildContext context) {
    final t = theme.light;
    final initials = l.seller.name.split(' ').map((w) => w.isNotEmpty ? w[0] : '').join().substring(0, 2).toUpperCase();
    return Row(
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(color: t.accentBg, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: Text(initials, style: TextStyle(color: t.accent, fontWeight: FontWeight.w700, fontSize: 10.5)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text.rich(TextSpan(children: [
            TextSpan(text: l.seller.name, style: TextStyle(color: t.ink, fontSize: 12, fontWeight: FontWeight.w600)),
            TextSpan(text: ' · ★ ${l.seller.rating.toStringAsFixed(1)} · ${l.seller.trades} trades', style: TextStyle(color: t.muted, fontWeight: FontWeight.w400)),
          ])),
        ),
        Text(l.status == MarketStatus.mine ? 'your listing' : '${l.minsAgo} min ago', style: TextStyle(color: t.muted, fontSize: 10.5)),
      ],
    );
  }
}

class _MarketFeed extends StatefulWidget {
  const _MarketFeed();

  @override
  State<_MarketFeed> createState() => _MarketFeedState();
}

class _MarketFeedState extends State<_MarketFeed> {
  String? confirming;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<Store>();
    final nav = context.read<Nav>();
    final t = theme.light;

    return Column(
      children: [
        ...store.market.map((l) {
          final price = store.marketPrice(l);
          final marketValue = l.cardIds.fold<double>(0, (s, id) => s + store.cards[id]!.price);
          final diff = marketValue > 0 ? price / marketValue - 1 : 0.0;
          final purchased = l.status == MarketStatus.purchased;
          final mine = l.status == MarketStatus.mine;
          return Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: t.panel,
              border: Border.all(color: mine ? const Color(0x66E3B341) : t.line),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SellerHeader(l: l),
                const SizedBox(height: 10),
                if (l.kind == MarketKind.card)
                  Row(
                    children: [
                      ui.CardThumb(cardId: l.cardIds[0], w: 48, h: 67),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => nav.push(NavOverlay.card(l.cardIds[0])),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text.rich(TextSpan(children: [
                                TextSpan(text: '${store.cards[l.cardIds[0]]!.name} · ${l.condition.code}', style: TextStyle(color: t.ink, fontSize: 13.5, fontWeight: FontWeight.w700)),
                                if (store.wishlist.contains(l.cardIds[0])) const TextSpan(text: '  ★ on your wishlist', style: TextStyle(color: Color(0xFFE3B341), fontSize: 11)),
                              ])),
                              Text('${store.cards[l.cardIds[0]]!.set} · single card', style: TextStyle(color: t.muted, fontSize: 11)),
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text.rich(TextSpan(children: [
                                  TextSpan(text: '\$${fmt(price)}', style: TextStyle(color: t.ink, fontSize: 16, fontWeight: FontWeight.w700)),
                                  TextSpan(
                                    text: '  ${diff <= 0 ? '${(diff.abs() * 100).round()}% under market' : '${(diff * 100).round()}% over market'}',
                                    style: TextStyle(color: diff <= 0 ? t.up : t.down, fontSize: 11, fontWeight: FontWeight.w600),
                                  ),
                                ])),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                else ...[
                  Text.rich(TextSpan(children: [
                    TextSpan(text: l.binderName ?? '', style: TextStyle(color: t.ink, fontSize: 13.5, fontWeight: FontWeight.w700)),
                    TextSpan(text: ' · binder lot · ${l.cardIds.length} cards', style: TextStyle(color: t.muted, fontSize: 11, fontWeight: FontWeight.w400)),
                  ])),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: l.cardIds.take(5).map((id) => Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: ui.CardThumb(cardId: id, w: 40, h: 56),
                          )).toList(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text.rich(TextSpan(children: [
                      TextSpan(text: '\$${fmt(price)}', style: TextStyle(color: t.ink, fontSize: 16, fontWeight: FontWeight.w700)),
                      TextSpan(text: '  market value \$${fmt(marketValue)}', style: TextStyle(color: t.muted, fontSize: 11)),
                      if (diff < 0) TextSpan(text: '  · save \$${fmt(marketValue - price)}', style: TextStyle(color: t.up, fontSize: 11, fontWeight: FontWeight.w600)),
                    ])),
                  ),
                ],
                if (!mine)
                  GestureDetector(
                    onTap: purchased
                        ? null
                        : () {
                            if (confirming == l.id) {
                              store.buyListing(l.id);
                              setState(() => confirming = null);
                            } else {
                              setState(() => confirming = l.id);
                            }
                          },
                    child: Container(
                      margin: const EdgeInsets.only(top: 10),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: purchased ? const Color(0x262BD48A) : const Color(0xFFE3B341),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        purchased
                            ? (l.kind == MarketKind.binder ? 'In your binders ✓' : 'In your vault ✓')
                            : (confirming == l.id ? 'Confirm buy · \$${fmt(price)}' : 'Buy now'),
                        style: TextStyle(color: purchased ? t.up : const Color(0xFF0B1017), fontSize: 12.5, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                if (mine)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text('Live on the market — buyers see this exactly like the listings above.', style: TextStyle(color: t.muted, fontSize: 11)),
                  ),
              ],
            ),
          );
        }),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text('Escrow, shipping, and buyer protection arrive with the marketplace backend.', style: TextStyle(color: t.muted, fontSize: 11), textAlign: TextAlign.center),
        ),
      ],
    );
  }
}

class _WantedFeed extends StatelessWidget {
  const _WantedFeed();

  @override
  Widget build(BuildContext context) {
    final store = context.watch<Store>();
    final nav = context.read<Nav>();
    final t = theme.light;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            'Buyers posted these wants from their wishlists. Own a loose copy? Offer it — the deal is pre-agreed at their price.',
            style: TextStyle(color: t.ink2, fontSize: 12.5, height: 1.4),
          ),
        ),
        ...store.wanted.map((w) {
          final card = store.cards[w.cardId]!;
          final price = store.wantedPrice(w);
          final qty = store.collection[w.cardId] ?? 0;
          final loose = qty - store.assignedCount(w.cardId);
          final initials = w.buyer.name.split(' ').map((x) => x.isNotEmpty ? x[0] : '').join().substring(0, 2).toUpperCase();
          final offered = w.status == WantedStatus.offered;
          return Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(color: t.panel, border: Border.all(color: t.line), borderRadius: BorderRadius.circular(14)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(color: t.accentBg, shape: BoxShape.circle),
                      alignment: Alignment.center,
                      child: Text(initials, style: TextStyle(color: t.accent, fontWeight: FontWeight.w700, fontSize: 10.5)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text.rich(TextSpan(children: [
                        TextSpan(text: w.buyer.name, style: TextStyle(color: t.ink, fontSize: 12, fontWeight: FontWeight.w600)),
                        TextSpan(text: ' · ★ ${w.buyer.rating.toStringAsFixed(1)} · wants this card', style: TextStyle(color: t.muted, fontWeight: FontWeight.w400)),
                      ])),
                    ),
                    Text('${w.minsAgo} min ago', style: TextStyle(color: t.muted, fontSize: 10.5)),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    children: [
                      ui.CardThumb(cardId: w.cardId, w: 48, h: 67),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => nav.push(NavOverlay.card(w.cardId)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(card.name, style: TextStyle(color: t.ink, fontSize: 13.5, fontWeight: FontWeight.w700)),
                              Text('${card.set} · ${card.game}', style: TextStyle(color: t.muted, fontSize: 11)),
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text.rich(TextSpan(children: [
                                  TextSpan(text: 'will pay \$${fmt(price)}', style: TextStyle(color: t.ink, fontSize: 16, fontWeight: FontWeight.w700)),
                                  TextSpan(
                                    text: '  ${w.premium >= 0 ? '${(w.premium * 100).round()}% over market' : '${(w.premium.abs() * 100).round()}% under market'}',
                                    style: TextStyle(color: w.premium >= 0 ? t.up : t.down, fontSize: 11, fontWeight: FontWeight.w600),
                                  ),
                                ])),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  loose > 0 ? 'you own ×$loose loose — ready to offer' : (qty > 0 ? 'your copies are all in binders' : "you don't own this card"),
                                  style: TextStyle(color: loose > 0 ? t.up : t.muted, fontSize: 11),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: (offered || loose < 1) ? null : () => store.offerToBuyer(w.id),
                  child: Container(
                    margin: const EdgeInsets.only(top: 10),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: offered ? const Color(0x262BD48A) : (loose < 1 ? t.panel : const Color(0xFFE3B341)),
                      border: (!offered && loose < 1) ? Border.all(color: t.line) : null,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      offered ? 'Offered to ${w.buyer.name} ✓ · listing created' : (loose < 1 ? 'No loose copy to offer' : 'Offer yours · \$${fmt(price)}'),
                      style: TextStyle(color: offered ? t.up : (loose < 1 ? t.muted : const Color(0xFF0B1017)), fontSize: 12.5, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text('Your own wishlist stars appear here for other sellers the same way.', style: TextStyle(color: t.muted, fontSize: 11), textAlign: TextAlign.center),
        ),
      ],
    );
  }
}

class _MyListings extends StatelessWidget {
  const _MyListings();

  @override
  Widget build(BuildContext context) {
    final store = context.watch<Store>();
    final nav = context.read<Nav>();
    final t = theme.light;
    final active = store.listings.where((l) => l.status == ListingStatus.active).toList();
    final sold = store.listings.where((l) => l.status == ListingStatus.sold).toList();
    final myBinderListings = store.market.where((l) => l.status == MarketStatus.mine).toList();
    final earned = sold.fold<double>(0, (s, l) => s + (l.price - l.fees));
    final pool = store.pool;
    final poolFull = pool.slotsFilled >= pool.slotsTotal;

    Widget stat(String label, String value, Color color) => Expanded(
          child: Container(
            padding: const EdgeInsets.all(10),
            alignment: Alignment.center,
            decoration: BoxDecoration(color: t.panel, border: Border.all(color: t.line), borderRadius: BorderRadius.circular(10)),
            child: Column(
              children: [
                Text(label, style: TextStyle(color: t.muted, fontSize: 11)),
                const SizedBox(height: 2),
                Text(value, style: TextStyle(color: color, fontSize: 17, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            stat('Active', '${active.length + myBinderListings.length}', t.ink),
            const SizedBox(width: 8),
            stat('Sold', '${sold.length}', t.ink),
            const SizedBox(width: 8),
            stat('Earned', '\$${fmt(earned)}', t.up),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 22, bottom: 8),
          child: Text('Active listings', style: TextStyle(color: t.ink, fontSize: 15, fontWeight: FontWeight.w600)),
        ),
        if (active.isEmpty && myBinderListings.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: t.panel, border: Border.all(color: t.line), borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                const ui.EmptyState(
                  image: 'assets/illustrations/empty-listings.png',
                  text: 'No active listings — scan a card and tap Sell now, or sell a whole binder from its detail page.',
                  size: 150,
                ),
                GestureDetector(
                  onTap: () => nav.setTab(AppTab.scan),
                  child: Container(
                    margin: const EdgeInsets.only(top: 10),
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 18),
                    decoration: BoxDecoration(color: t.accentBg, borderRadius: BorderRadius.circular(9)),
                    child: Text('Go to Scan', style: TextStyle(color: t.accent, fontWeight: FontWeight.w600, fontSize: 13)),
                  ),
                ),
              ],
            ),
          ),
        ...myBinderListings.map((l) => Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(color: t.panel, border: Border.all(color: t.line), borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  ui.CardThumb(cardId: l.cardIds[0], w: 34, h: 48),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${l.binderName} · binder lot', style: TextStyle(color: t.ink, fontSize: 13.5, fontWeight: FontWeight.w600)),
                        Text('${l.cardIds.length} cards · on the market', style: TextStyle(color: t.muted, fontSize: 11.5)),
                      ],
                    ),
                  ),
                  Text('\$${fmt(l.askPrice ?? 0)}', style: TextStyle(color: t.ink, fontSize: 15, fontWeight: FontWeight.w600)),
                ],
              ),
            )),
        ...active.map((l) {
          final c = store.cards[l.cardId]!;
          return Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(color: t.panel, border: Border.all(color: t.line), borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                Row(
                  children: [
                    ui.CardThumb(cardId: c.id, w: 34, h: 48),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${c.name} · ${l.condition.code}', style: TextStyle(color: t.ink, fontSize: 13.5, fontWeight: FontWeight.w600)),
                          Text('${l.markets.join(' + ')} · listed ${l.createdAt}', style: TextStyle(color: t.muted, fontSize: 11.5)),
                        ],
                      ),
                    ),
                    Text('\$${fmt(l.price)}', style: TextStyle(color: t.ink, fontSize: 15, fontWeight: FontWeight.w600)),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => nav.push(NavOverlay.show(l.id)),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(color: t.ink, borderRadius: BorderRadius.circular(9)),
                            child: Text('Show mode · QR', style: TextStyle(color: t.bg, fontSize: 12, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => store.markListingSold(l.id),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(border: Border.all(color: t.line), borderRadius: BorderRadius.circular(9)),
                            child: Text('Mark sold', style: TextStyle(color: t.ink2, fontSize: 12, fontWeight: FontWeight.w600)),
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
        if (sold.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 22, bottom: 8),
            child: Text('Sold', style: TextStyle(color: t.ink, fontSize: 15, fontWeight: FontWeight.w600)),
          ),
        ...sold.map((l) {
          final c = store.cards[l.cardId]!;
          return Opacity(
            opacity: 0.75,
            child: Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(color: t.panel, border: Border.all(color: t.line), borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  ui.CardThumb(cardId: c.id, w: 34, h: 48),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${c.name} · ${l.condition.code}', style: TextStyle(color: t.ink, fontSize: 13.5, fontWeight: FontWeight.w600)),
                        Text('net \$${fmt(l.price - l.fees)} after fees', style: TextStyle(color: t.muted, fontSize: 11.5)),
                      ],
                    ),
                  ),
                  ui.Chip(label: 'sold', bg: t.accentBg, color: t.accent),
                ],
              ),
            ),
          );
        }),
        Padding(
          padding: const EdgeInsets.only(top: 22, bottom: 8),
          child: Text('Grading pool', style: TextStyle(color: t.ink, fontSize: 15, fontWeight: FontWeight.w600)),
        ),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: t.panel, border: Border.all(color: t.line), borderRadius: BorderRadius.circular(14)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('PSA Value Bulk · Pool #14', style: TextStyle(color: t.ink, fontSize: 14, fontWeight: FontWeight.w700)),
                  ui.Chip(label: poolFull ? 'shipping soon' : 'closes 2d 14h', bg: t.warnBg, color: t.warnInk),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text.rich(TextSpan(children: [
                            TextSpan(text: '\$$_poolPrice', style: TextStyle(color: t.accent, fontSize: 20, fontWeight: FontWeight.w700)),
                            TextSpan(text: '/card · ', style: TextStyle(color: t.muted, fontSize: 12)),
                            TextSpan(text: '\$$_soloPrice solo', style: TextStyle(color: t.muted, fontSize: 12, decoration: TextDecoration.lineThrough)),
                          ])),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${pool.slotsFilled} of ${pool.slotsTotal} slots filled', style: TextStyle(color: t.muted, fontSize: 11.5)),
                                  Text('${pool.slotsTotal - pool.slotsFilled} left', style: TextStyle(color: t.muted, fontSize: 11.5)),
                                ],
                              ),
                              Container(
                                margin: const EdgeInsets.only(top: 5),
                                height: 6,
                                decoration: BoxDecoration(color: t.bg, borderRadius: BorderRadius.circular(3)),
                                child: FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: pool.slotsFilled / pool.slotsTotal,
                                  child: Container(decoration: BoxDecoration(color: t.up, borderRadius: BorderRadius.circular(3))),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset('assets/illustrations/slab.png', width: 66, height: 83, fit: BoxFit.cover),
                  ),
                ],
              ),
              if (pool.yourCards > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Your submission: ${pool.yourCards} card${pool.yourCards > 1 ? 's' : ''} · saving \$${fmt(pool.yourCards * (_soloPrice - _poolPrice))}',
                    style: TextStyle(color: t.accent, fontSize: 12),
                  ),
                ),
              GestureDetector(
                onTap: poolFull ? null : () => store.joinPool(1),
                child: Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: poolFull ? t.line : t.ink, borderRadius: BorderRadius.circular(10)),
                  child: Text(
                    poolFull ? 'Pool full — ships together' : 'Add a card to the pool',
                    style: TextStyle(color: poolFull ? t.muted : t.bg, fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
