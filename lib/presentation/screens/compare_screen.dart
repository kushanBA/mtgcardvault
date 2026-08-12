import 'package:flutter/material.dart' hide Card;
import 'package:provider/provider.dart';
import '../../data/mock_db.dart';
import '../../data/store.dart';
import '../../nav.dart';
import '../../theme.dart' as theme;
import '../../widgets/ui.dart' as ui;

class _Swap {
  final String giveId;
  final String getId;
  const _Swap({required this.giveId, required this.getId});
}

class CompareScreen extends StatefulWidget {
  final String binderId;
  const CompareScreen({super.key, required this.binderId});

  @override
  State<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
  Set<int> selected = {0};
  bool proposed = false;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<Store>();
    final nav = context.read<Nav>();
    final t = theme.exchange;
    final myBinder = store.binders.where((b) => b.id == widget.binderId).firstOrNull;

    final mySpareIds = mySpares.keys.where((id) => communityBinder.needs.contains(id)).toList();
    final theirSpareIds = communityBinder.spares;
    final swaps = <_Swap>[
      for (var i = 0; i < mySpareIds.length; i++) _Swap(giveId: mySpareIds[i], getId: theirSpareIds[i % theirSpareIds.length]),
    ];

    final giveTotal = selected.fold<double>(0, (s, i) => i < swaps.length ? s + store.cards[swaps[i].giveId]!.price : s);
    final getTotal = selected.fold<double>(0, (s, i) => i < swaps.length ? s + store.cards[swaps[i].getId]!.price : s);
    final delta = getTotal - giveTotal;
    final fair = delta.abs() < (giveTotal * 0.05).clamp(15, double.infinity);

    final myValue = myBinder != null ? store.binderValue(myBinder) : 0.0;
    final theirValue = [...communityBinder.spares, ...communityBinder.needs].fold<double>(0, (s, id) => s + store.cards[id]!.price * 2.1);

    return Container(
      color: t.bg,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(onTap: nav.pop, child: Text('‹ Back', style: TextStyle(color: t.muted, fontSize: 14))),
                Text('Binder compare', style: TextStyle(color: t.ink, fontSize: 15, fontWeight: FontWeight.w700)),
                Text('offline ✓', style: TextStyle(color: t.muted, fontSize: 10.5)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: t.panel, borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('YOU · ${(myBinder?.name ?? 'BINDER').toUpperCase().substring(0, ((myBinder?.name ?? 'BINDER').length).clamp(0, 14))}', style: TextStyle(color: t.muted, fontSize: 9.5, letterSpacing: 0.5)),
                        Text('\$${fmt(myValue)}', style: TextStyle(color: t.ink, fontSize: 15, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text('⇄', style: TextStyle(color: theme.gold, fontSize: 17)),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: t.panel, borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${communityBinder.owner.toUpperCase()} · ${communityBinder.binderName.toUpperCase().substring(0, communityBinder.binderName.length.clamp(0, 10))}', style: TextStyle(color: t.muted, fontSize: 9.5, letterSpacing: 0.5)),
                        Text('\$${fmt(theirValue)}', style: TextStyle(color: t.ink, fontSize: 15, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${communityBinder.owner} · ★ ${communityBinder.rating} · ${communityBinder.trades} trades · ${communityBinder.distanceMi} mi away',
                style: TextStyle(color: t.muted, fontSize: 10.5),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('${swaps.length} swap match${swaps.length == 1 ? '' : 'es'} found', style: TextStyle(color: t.up, fontSize: 12, fontWeight: FontWeight.w700)),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 20),
              children: swaps.asMap().entries.map((entry) {
                final i = entry.key;
                final sw = entry.value;
                final give = store.cards[sw.giveId]!;
                final get = store.cards[sw.getId]!;
                final on = selected.contains(i);
                return GestureDetector(
                  onTap: () => setState(() {
                    if (selected.contains(i)) {
                      selected = {...selected}..remove(i);
                    } else {
                      selected = {...selected, i};
                    }
                  }),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF12161B),
                      border: Border.all(color: on ? const Color(0xFF2E5B47) : t.line),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            ui.CardThumb(cardId: sw.giveId, w: 26, h: 36),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text.rich(TextSpan(children: [
                                    TextSpan(text: 'You give: ${give.name}', style: TextStyle(color: t.ink, fontSize: 12, fontWeight: FontWeight.w600)),
                                    TextSpan(text: ' SPARE ×${mySpares[sw.giveId]}', style: TextStyle(color: t.up, fontSize: 9.5)),
                                  ])),
                                  Text('you own ×${(mySpares[sw.giveId] ?? 0) + 1} · keep ${mySpares[sw.giveId]}', style: TextStyle(color: t.muted, fontSize: 9.5)),
                                ],
                              ),
                            ),
                            Text('\$${fmt(give.price)}', style: TextStyle(color: t.ink, fontSize: 12, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        Center(child: Padding(padding: const EdgeInsets.symmetric(vertical: 2), child: Text('⇅', style: TextStyle(color: theme.gold, fontSize: 13)))),
                        Row(
                          children: [
                            ui.CardThumb(cardId: sw.getId, w: 26, h: 36),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text.rich(TextSpan(children: [
                                    TextSpan(text: 'You get: ${get.name}', style: TextStyle(color: t.ink, fontSize: 12, fontWeight: FontWeight.w600)),
                                    TextSpan(text: ' NEED', style: TextStyle(color: theme.gold, fontSize: 9.5)),
                                  ])),
                                  Text('fills a gap in your set', style: TextStyle(color: t.muted, fontSize: 9.5)),
                                ],
                              ),
                            ),
                            Text('\$${fmt(get.price)}', style: TextStyle(color: t.ink, fontSize: 12, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.only(top: 7),
                          decoration: BoxDecoration(border: Border(top: BorderSide(color: t.line))),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Δ \$${fmt((get.price - give.price).abs())} ${get.price >= give.price ? 'in your favor' : 'their way'}',
                                style: TextStyle(color: get.price >= give.price ? t.up : t.down, fontSize: 10.5, fontWeight: FontWeight.w600),
                              ),
                              Text(on ? '✓ selected' : 'tap to add', style: TextStyle(color: on ? t.up : t.muted, fontSize: 10.5, fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(color: t.panel, borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${selected.length} swap${selected.length == 1 ? '' : 's'} selected', style: TextStyle(color: t.muted, fontSize: 11.5)),
                      Text.rich(TextSpan(children: [
                        TextSpan(text: '\$${fmt(giveTotal)} ⇄ \$${fmt(getTotal)} · ', style: TextStyle(color: t.ink, fontSize: 12, fontWeight: FontWeight.w700)),
                        TextSpan(text: fair ? 'fair' : 'uneven', style: TextStyle(color: fair ? t.up : t.down)),
                      ])),
                    ],
                  ),
                ),
                Opacity(
                  opacity: (proposed || selected.isEmpty) ? 0.65 : 1,
                  child: GestureDetector(
                    onTap: (proposed || selected.isEmpty) ? null : () => setState(() => proposed = true),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: theme.gold, borderRadius: BorderRadius.circular(11)),
                      child: Text(
                        proposed ? 'Proposal sent to ${communityBinder.owner} ✓' : 'Propose swap to ${communityBinder.owner}',
                        style: const TextStyle(color: Color(0xFF0B0E11), fontSize: 13.5, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text("In person? Both tap Compare and scan each other's QR — works offline.", style: TextStyle(color: t.muted, fontSize: 10), textAlign: TextAlign.center),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
