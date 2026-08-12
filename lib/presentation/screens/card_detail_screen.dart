import 'package:flutter/material.dart' hide Card;
import 'package:provider/provider.dart';
import '../../data/store.dart';
import '../../data/types.dart';
import '../../nav.dart';
import '../../theme.dart' as theme;
import '../../widgets/ui.dart' as ui;

const _gradingFee = 25.0;

class CardDetailScreen extends StatefulWidget {
  final String cardId;
  final Condition condition;
  const CardDetailScreen({super.key, required this.cardId, this.condition = Condition.nm});

  @override
  State<CardDetailScreen> createState() => _CardDetailScreenState();
}

class _CardDetailScreenState extends State<CardDetailScreen> {
  String source = 'All';
  bool added = false;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<Store>();
    final nav = context.read<Nav>();
    final t = theme.light;
    final c = store.cards[widget.cardId]!;
    final change30 = c.price / c.history[(c.history.length - 30).clamp(0, c.history.length - 1)] - 1;
    final psa9Net = c.gradedPsa9 - _gradingFee;
    final psa10Net = c.gradedPsa10 - _gradingFee;
    final wished = store.wishlist.contains(widget.cardId);

    return Container(
      color: t.bg,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(onTap: nav.pop, child: Text('‹ Back', style: TextStyle(color: t.ink2, fontSize: 14))),
                Row(
                  children: [
                    Text(c.set, style: TextStyle(color: t.muted, fontSize: 12)),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () => store.toggleWishlist(widget.cardId),
                      child: Text(wished ? '★' : '☆', style: TextStyle(color: wished ? t.accent : t.muted, fontSize: 19)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ui.CardThumb(cardId: c.id, w: 86, h: 120),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c.name, style: theme.fontDisplay(fontSize: 18, color: t.ink)),
                          Text('${c.number} · ${c.language}', style: TextStyle(color: t.muted, fontSize: 12)),
                          Text('\$${fmt(c.price)}', style: theme.fontHeavy(fontSize: 28, color: t.ink)),
                          Text.rich(TextSpan(children: [
                            TextSpan(text: 'avg of last 12 sold · ', style: TextStyle(color: t.muted, fontSize: 12)),
                            TextSpan(text: '${pct(change30)} 30d', style: TextStyle(color: change30 >= 0 ? t.up : t.down)),
                          ])),
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: ui.Chip(
                              label: 'Est. ${widget.condition == Condition.nm ? 'near mint' : widget.condition.code} · AI condition',
                              bg: t.accentBg,
                              color: t.accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: ['All', 'eBay sold', 'TCGplayer'].map((k) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: GestureDetector(
                        onTap: () => setState(() => source = k),
                        child: ui.Chip(
                          label: k,
                          bg: source == k ? t.ink : null,
                          border: source == k ? null : t.line,
                          color: source == k ? t.bg : t.ink2,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: t.panel, border: Border.all(color: t.line), borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    children: [
                      ui.Sparkline(data: c.history, color: t.up, width: 300, height: 60),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('90d · $source', style: TextStyle(color: t.muted, fontSize: 11)),
                          Text('\$${fmt(c.history[0])} → \$${fmt(c.price)}', style: TextStyle(color: t.muted, fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    children: [
                      _Tile(label: 'Raw ${widget.condition.code}', value: '\$${c.price.round()}', t: t),
                      const SizedBox(width: 8),
                      _Tile(label: 'PSA 9 net', value: '\$${psa9Net.round()}', t: t),
                      const SizedBox(width: 8),
                      _Tile(label: 'PSA 10 net', value: '\$${psa10Net.round()}', t: t, bg: t.accentBg, color: t.accent),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    psa10Net > c.price * 1.8
                        ? 'Net of ~\$${_gradingFee.round()} grading fee. PSA 10 pays ${(psa10Net / c.price).toStringAsFixed(1)}× raw — worth grading if it\'s clean.'
                        : 'Net of ~\$${_gradingFee.round()} grading fee. Grading doesn\'t pay at this price — sell raw.',
                    style: TextStyle(color: t.muted, fontSize: 11),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 6),
                  child: Text('Recent solds', style: TextStyle(color: t.ink, fontSize: 15, fontWeight: FontWeight.w600)),
                ),
                ...c.recentSolds.map((r) => Container(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: t.line))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${r.source} · ${r.condition.code} · ${r.date}', style: TextStyle(color: t.ink2, fontSize: 12.5)),
                          Text('\$${fmt(r.price)}', style: TextStyle(color: t.ink, fontSize: 12.5, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    )),
                Padding(
                  padding: const EdgeInsets.only(top: 18),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 14,
                        child: GestureDetector(
                          onTap: () => nav.push(NavOverlay.sellSheet(widget.cardId, widget.condition)),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(color: t.ink, borderRadius: BorderRadius.circular(12)),
                            child: Text('Sell now', style: TextStyle(color: t.bg, fontWeight: FontWeight.w700, fontSize: 14)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 10,
                        child: GestureDetector(
                          onTap: () {
                            store.addToCollection(widget.cardId);
                            setState(() => added = true);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(color: t.panel, border: Border.all(color: t.line), borderRadius: BorderRadius.circular(12)),
                            child: Text(
                              added ? 'In collection ✓' : 'Add to collection',
                              style: TextStyle(color: added ? t.up : t.ink, fontWeight: FontWeight.w600, fontSize: 14),
                            ),
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
  }
}

class _Tile extends StatelessWidget {
  final String label;
  final String value;
  final theme.AppColors t;
  final Color? bg;
  final Color? color;
  const _Tile({required this.label, required this.value, required this.t, this.bg, this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        alignment: Alignment.center,
        decoration: BoxDecoration(color: bg ?? t.panel, border: Border.all(color: t.line), borderRadius: BorderRadius.circular(10)),
        child: Column(
          children: [
            Text(label, style: TextStyle(color: color ?? t.muted, fontSize: 11)),
            const SizedBox(height: 2),
            Text(value, style: TextStyle(color: color ?? t.ink, fontSize: 16, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
