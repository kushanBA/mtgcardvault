import 'package:flutter/material.dart' hide Card;
import 'package:provider/provider.dart';
import '../../data/mock_db.dart';
import '../../data/store.dart';
import '../../data/types.dart';
import '../../nav.dart';
import '../../theme.dart' as theme;
import '../../widgets/ui.dart' as ui;

const _gameMeta = <String, (String short, String blurb)>{
  'Pokémon': ('Pokémon', 'Scarlet & Violet, SWSH, promos'),
  'Magic: The Gathering': ('MTG', 'Modern, Commander, staples'),
  'One Piece': ('One Piece', 'Romance Dawn, leaders, alt arts'),
  'Flesh and Blood': ('Flesh & Blood', 'History Pack, Arcane Rising'),
};

/// Step 1: pick the game. Step 2: search cards inside it.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String? game;
  String q = '';

  @override
  Widget build(BuildContext context) {
    final store = context.watch<Store>();
    final nav = context.read<Nav>();
    final t = theme.light;

    List<Card> results = [];
    if (game != null) {
      final pool = cards.where((c) => c.game == game).map((c) => store.cards[c.id]!).toList();
      final needle = q.trim().toLowerCase();
      if (needle.isEmpty) {
        results = pool..sort((a, b) => b.price.compareTo(a.price));
      } else {
        results = pool.where((c) => c.name.toLowerCase().contains(needle) || c.set.toLowerCase().contains(needle)).toList();
      }
    }

    return Container(
      color: t.bg,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    if (game != null) {
                      setState(() {
                        game = null;
                        q = '';
                      });
                    } else {
                      nav.pop();
                    }
                  },
                  child: Text(game != null ? '‹ Games' : '‹ Back', style: TextStyle(color: t.ink2, fontSize: 14)),
                ),
                Text(game != null ? (_gameMeta[game]?.$1 ?? game!) : 'Search cards', style: TextStyle(color: t.ink, fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(width: 44),
              ],
            ),
          ),
          Expanded(
            child: game == null
                ? ListView(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Text('Pick a game first — then search its cards.', style: TextStyle(color: t.ink2, fontSize: 13)),
                      ),
                      ...games.map((g) {
                        final count = cards.where((c) => c.game == g).length;
                        final ownedValue = cards.where((c) => c.game == g).fold<double>(0, (s, c) => s + (store.collection[c.id] ?? 0) * store.cards[c.id]!.price);
                        return GestureDetector(
                          onTap: () => setState(() => game = g),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(color: t.panel, border: Border.all(color: t.line), borderRadius: BorderRadius.circular(14)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Row(
                                    children: cards.where((c) => c.game == g).take(3).map((c) => Padding(
                                          padding: const EdgeInsets.only(right: 10),
                                          child: ui.CardThumb(cardId: c.id, w: 44, h: 61),
                                        )).toList(),
                                  ),
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(_gameMeta[g]?.$1 ?? g, style: theme.fontDisplay(fontSize: 16, color: t.ink)),
                                    Text('$count cards in catalog ›', style: TextStyle(color: t.muted, fontSize: 11.5)),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text('${_gameMeta[g]?.$2 ?? ''}${ownedValue > 0 ? ' · you hold \$${fmt(ownedValue)}' : ''}', style: TextStyle(color: t.muted, fontSize: 11.5)),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  )
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
                        child: TextField(
                          onChanged: (v) => setState(() => q = v),
                          autofocus: true,
                          style: TextStyle(color: t.ink, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Search ${_gameMeta[game]?.$1 ?? game} — card name or set…',
                            hintStyle: TextStyle(color: t.muted),
                            filled: true,
                            fillColor: t.panel,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: t.line)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: t.line)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: t.line)),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(14, 6, 14, 28),
                          children: [
                            ...results.map((c) {
                              final ch = c.price / c.dayOpen - 1;
                              final wished = store.wishlist.contains(c.id);
                              final owned = store.collection[c.id] ?? 0;
                              return Container(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(border: Border(bottom: BorderSide(color: t.line))),
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
                                            Text(c.name, style: TextStyle(color: t.ink, fontSize: 13.5, fontWeight: FontWeight.w600)),
                                            Text('${c.set}${owned > 0 ? ' · you own ×$owned' : ''}', style: TextStyle(color: t.muted, fontSize: 11.5)),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text('\$${fmt(c.price)}', style: TextStyle(color: t.ink, fontSize: 13.5, fontWeight: FontWeight.w600)),
                                        Text(pct(ch), style: TextStyle(color: ch >= 0 ? t.up : t.down, fontSize: 11, fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: () => store.toggleWishlist(c.id),
                                      child: Container(
                                        width: 34,
                                        height: 34,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: wished ? t.accentBg : null,
                                          border: wished ? null : Border.all(color: t.line),
                                          borderRadius: BorderRadius.circular(17),
                                        ),
                                        child: Text(wished ? '★' : '☆', style: TextStyle(color: wished ? t.accent : t.muted, fontSize: 16)),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                            if (results.isEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 40),
                                child: Text(
                                  'No ${_gameMeta[game]?.$1 ?? game} cards match "$q" — the full catalog arrives with the live database.',
                                  style: TextStyle(color: t.muted, fontSize: 13),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Text('★ adds a card to your wishlist — sellers see it and can offer you theirs.', style: TextStyle(color: t.muted, fontSize: 11), textAlign: TextAlign.center),
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
