import 'dart:async';
import 'package:flutter/foundation.dart';
import '../core/storage/local_storage.dart';
import 'mock_db.dart' as db;
import 'types.dart';

class Pool {
  final int slotsFilled;
  final int slotsTotal;
  final int yourCards;
  const Pool({required this.slotsFilled, required this.slotsTotal, required this.yourCards});

  Pool copyWith({int? slotsFilled, int? yourCards}) =>
      Pool(slotsFilled: slotsFilled ?? this.slotsFilled, slotsTotal: slotsTotal, yourCards: yourCards ?? this.yourCards);

  Map<String, dynamic> toJson() => {'slotsFilled': slotsFilled, 'slotsTotal': slotsTotal, 'yourCards': yourCards};
  factory Pool.fromJson(Map<String, dynamic> j) =>
      Pool(slotsFilled: j['slotsFilled'] as int, slotsTotal: j['slotsTotal'] as int, yourCards: j['yourCards'] as int);
}

const _defaultPool = Pool(slotsFilled: 17, slotsTotal: 20, yourCards: 0);

List<Binder> _startBinders() => [
      const Binder(
        id: 'b1',
        name: 'Obsidian Flames · Master',
        game: 'Pokémon',
        isPublic: true,
        pockets: [
          Pocket(cardId: 'zard', paid: 120),
          Pocket(cardId: 'pidgeot', paid: 40),
          Pocket(cardId: 'garde', paid: 30),
          Pocket(cardId: 'iono', paid: 150),
          Pocket(cardId: 'lugia', paid: 180),
          Pocket(cardId: 'mew', paid: 70),
          Pocket(cardId: 'pika', paid: 55),
          Pocket(cardId: 'zapdos', paid: 85),
          Pocket(),
        ],
      ),
      const Binder(
        id: 'b2',
        name: 'Alt-art shrine',
        game: 'Pokémon',
        isPublic: false,
        pockets: [
          Pocket(cardId: 'moonbreon', paid: 380),
          Pocket(cardId: 'giratina', paid: 60),
          Pocket(cardId: 'rayquaza', paid: 480),
          Pocket(),
          Pocket(),
          Pocket(),
          Pocket(),
          Pocket(),
          Pocket(),
        ],
      ),
    ];

class GameAllocation {
  final String game;
  final double value;
  final double change;
  const GameAllocation({required this.game, required this.value, required this.change});
}

class Store extends ChangeNotifier {
  Map<String, Card> cards = {for (final c in db.cards) c.id: c};

  List<Binder> binders = _startBinders();
  List<Listing> listings = [];
  List<double> portfolioSeries = [];
  Pool pool = _defaultPool;
  List<MarketListing> market = List.of(db.marketSeed);
  Map<String, int> collection = Map.of(db.defaultCollection);
  List<String> wishlist = [];
  List<WantedPost> wanted = List.of(db.wantedSeed);
  bool _hydrated = false;
  Timer? _ticker;

  Store() {
    _hydrate();
  }

  Future<void> _hydrate() async {
    final b = await load<List<Binder>>('binders', (j) => (j as List).map((x) => Binder.fromJson(x as Map<String, dynamic>)).toList());
    final l = await load<List<Listing>>('listings', (j) => (j as List).map((x) => Listing.fromJson(x as Map<String, dynamic>)).toList());
    final p = await load<Pool>('pool', (j) => Pool.fromJson(j as Map<String, dynamic>));
    final m = await load<List<MarketListing>>('market', (j) => (j as List).map((x) => MarketListing.fromJson(x as Map<String, dynamic>)).toList());
    final col = await load<Map<String, int>>('collection', (j) => (j as Map).map((k, v) => MapEntry(k as String, v as int)));
    final wl = await load<List<String>>('wishlist', (j) => (j as List).cast<String>());
    final wn = await load<List<WantedPost>>('wanted', (j) => (j as List).map((x) => WantedPost.fromJson(x as Map<String, dynamic>)).toList());

    final known = cards.keys.toSet();
    final cardGame = {for (final c in cards.values) c.id: c.game};
    final finalBinders = (b ?? _startBinders()).map((x) {
      final pockets = x.pockets.map((k) => known.contains(k.cardId ?? '') ? k : const Pocket()).toList();
      final firstCard = pockets.firstWhere((k) => k.cardId != null, orElse: () => const Pocket()).cardId;
      final game = firstCard != null ? (cardGame[firstCard] ?? x.game) : x.game;
      return x.copyWith(game: game, pockets: pockets);
    }).toList();
    binders = finalBinders;

    if (l != null) listings = l.where((x) => known.contains(x.cardId)).toList();
    if (p != null) pool = p;
    if (m != null) market = m.where((x) => x.cardIds.every(known.contains)).toList();

    final colFinal = col != null
        ? Map<String, int>.fromEntries(col.entries.where((e) => known.contains(e.key)))
        : Map<String, int>.of(db.defaultCollection);
    final assigned = <String, int>{};
    for (final bd in finalBinders) {
      for (final k in bd.pockets) {
        if (k.cardId != null) assigned[k.cardId!] = (assigned[k.cardId!] ?? 0) + 1;
      }
    }
    for (final e in assigned.entries) {
      colFinal[e.key] = (colFinal[e.key] ?? 0) > e.value ? colFinal[e.key]! : e.value;
    }
    collection = colFinal;

    if (wl != null) wishlist = wl.where(known.contains).toList();
    if (wn != null) wanted = wn.where((x) => known.contains(x.cardId)).toList();

    _hydrated = true;
    notifyListeners();
    _startTicker();
  }

  void _startTicker() {
    _ticker = Timer.periodic(const Duration(seconds: 3), (_) => _tick());
  }

  void _tick() {
    final rand = _random.nextDouble();
    final next = <String, Card>{};
    for (final entry in cards.entries) {
      final drift = 1 + (_random.nextDouble() - 0.494) * 0.006;
      next[entry.key] = entry.value.copyWith(price: (entry.value.price * drift * 100).round() / 100);
    }
    cards = next;
    final total = collection.entries.fold<double>(0, (s, e) => s + (next[e.key]?.price ?? 0) * e.value);
    portfolioSeries = [...portfolioSeries.length > 59 ? portfolioSeries.sublist(portfolioSeries.length - 59) : portfolioSeries, total];
    _persist();
    notifyListeners();
    // silence unused warning
    assert(rand >= 0);
  }

  final _random = _Rng();

  void _persist() {
    if (!_hydrated) return;
    save('binders', binders.map((b) => b.toJson()).toList());
    save('listings', listings.map((l) => l.toJson()).toList());
    save('pool', pool.toJson());
    save('market', market.map((m) => m.toJson()).toList());
    save('collection', collection);
    save('wishlist', wishlist);
    save('wanted', wanted.map((w) => w.toJson()).toList());
  }

  void _commit() {
    _persist();
    notifyListeners();
  }

  double binderValue(Binder b) =>
      b.pockets.fold(0, (s, p) => s + (p.cardId != null ? (cards[p.cardId]?.price ?? 0) : 0));

  double binderDayChange(Binder b) {
    final now = b.pockets.fold<double>(0, (s, p) => s + (p.cardId != null ? (cards[p.cardId]?.price ?? 0) : 0));
    final open = b.pockets.fold<double>(0, (s, p) => s + (p.cardId != null ? (cards[p.cardId]?.dayOpen ?? 0) : 0));
    return open > 0 ? now / open - 1 : 0;
  }

  double portfolioValue() =>
      collection.entries.fold(0, (s, e) => s + (cards[e.key]?.price ?? 0) * e.value);

  double portfolioDayChange() {
    final now = collection.entries.fold<double>(0, (s, e) => s + (cards[e.key]?.price ?? 0) * e.value);
    final open = collection.entries.fold<double>(0, (s, e) => s + (cards[e.key]?.dayOpen ?? 0) * e.value);
    return open > 0 ? now / open - 1 : 0;
  }

  List<GameAllocation> portfolioByGame() {
    final by = <String, ({double value, double open})>{};
    for (final e in collection.entries) {
      final c = cards[e.key];
      if (c == null || e.value <= 0) continue;
      final cur = by[c.game] ?? (value: 0.0, open: 0.0);
      by[c.game] = (value: cur.value + c.price * e.value, open: cur.open + c.dayOpen * e.value);
    }
    final list = by.entries
        .map((e) => GameAllocation(game: e.key, value: e.value.value, change: e.value.open > 0 ? e.value.value / e.value.open - 1 : 0))
        .toList();
    list.sort((a, b) => b.value.compareTo(a.value));
    return list;
  }

  int assignedCount(String cardId) =>
      binders.fold(0, (s, b) => s + b.pockets.where((k) => k.cardId == cardId).length);

  void addToCollection(String cardId, {int qty = 1}) {
    collection = {...collection, cardId: (collection[cardId] ?? 0) + qty};
    _commit();
  }

  bool addToBinder(String binderId, String cardId) {
    final target = binders.firstWhere((b) => b.id == binderId, orElse: () => throw StateError('no binder'));
    final owned = collection[cardId] ?? 0;
    final assigned = assignedCount(cardId);
    final card = cards[cardId];
    if (card == null || target.game != card.game || owned - assigned < 1) return false;
    var ok = false;
    binders = binders.map((b) {
      if (b.id != binderId) return b;
      final i = b.pockets.indexWhere((p) => p.cardId == null);
      if (i == -1) return b;
      ok = true;
      final pockets = List<Pocket>.of(b.pockets);
      pockets[i] = Pocket(cardId: cardId, paid: card.price);
      return b.copyWith(pockets: pockets);
    }).toList();
    _commit();
    return ok;
  }

  void createBinder(String name, String game) {
    binders = [
      ...binders,
      Binder(id: 'b${_now()}', name: name, game: game, isPublic: false, pockets: List.generate(9, (_) => const Pocket())),
    ];
    _commit();
  }

  void togglePublic(String binderId) {
    binders = binders.map((b) => b.id == binderId ? b.copyWith(isPublic: !b.isPublic) : b).toList();
    _commit();
  }

  void addListing({required String cardId, required Condition condition, required double price, required double fees, required List<String> markets}) {
    listings = [
      Listing(id: 'l${_now()}', cardId: cardId, condition: condition, price: price, fees: fees, markets: markets, createdAt: _todayLabel(), status: ListingStatus.active),
      ...listings,
    ];
    _commit();
  }

  void markListingSold(String id) {
    Listing? listing;
    for (final l in listings) {
      if (l.id == id && l.status == ListingStatus.active) listing = l;
    }
    listings = listings.map((l) => l.id == id ? l.copyWith(status: ListingStatus.sold) : l).toList();
    if (listing == null) {
      _commit();
      return;
    }
    final cid = listing.cardId;
    final owned = collection[cid] ?? 0;
    if (owned > 0) {
      final assigned = assignedCount(cid);
      if (assigned >= owned) {
        final i = binders.indexWhere((b) => b.pockets.any((k) => k.cardId == cid));
        if (i != -1) {
          binders = binders.asMap().entries.map((entry) {
            if (entry.key != i) return entry.value;
            final b = entry.value;
            final slot = b.pockets.indexWhere((k) => k.cardId == cid);
            final pockets = List<Pocket>.of(b.pockets);
            pockets[slot] = const Pocket();
            return b.copyWith(pockets: pockets);
          }).toList();
        }
      }
      collection = {...collection, cid: (collection[cid] ?? 0) - 1 < 0 ? 0 : (collection[cid] ?? 0) - 1};
    }
    _commit();
  }

  void joinPool(int n) {
    pool = pool.copyWith(
      slotsFilled: (pool.slotsFilled + n) > pool.slotsTotal ? pool.slotsTotal : pool.slotsFilled + n,
      yourCards: pool.yourCards + n,
    );
    _commit();
  }

  double marketPrice(MarketListing l) {
    if (l.askPrice != null) return l.askPrice!;
    final base = l.cardIds.fold<double>(0, (s, id) => s + (cards[id]?.price ?? 0));
    return (base * (1 - l.discount) * 100).round() / 100;
  }

  void buyListing(String id) {
    final l = market.firstWhere((x) => x.id == id, orElse: () => throw StateError('no listing'));
    if (l.status != MarketStatus.available) return;
    final base = l.cardIds.fold<double>(0, (s, cid) => s + (cards[cid]?.price ?? 0));
    final factor = l.askPrice != null && base > 0 ? l.askPrice! / base : 1 - l.discount;
    if (l.kind == MarketKind.binder) {
      final next = Map<String, int>.of(collection);
      for (final cid in l.cardIds) {
        next[cid] = (next[cid] ?? 0) + 1;
      }
      collection = next;
      binders = [
        ...binders,
        Binder(
          id: 'b${_now()}',
          name: l.binderName ?? "${l.seller.name}'s binder",
          game: cards[l.cardIds[0]]!.game,
          isPublic: false,
          pockets: List.generate(9, (i) {
            if (i >= l.cardIds.length) return const Pocket();
            final cid = l.cardIds[i];
            return Pocket(cardId: cid, paid: ((cards[cid]!.price * factor) * 100).round() / 100);
          }),
        ),
      ];
    } else {
      final cid = l.cardIds[0];
      collection = {...collection, cid: (collection[cid] ?? 0) + 1};
    }
    market = market.map((x) => x.id == id ? x.copyWith(status: MarketStatus.purchased) : x).toList();
    _commit();
  }

  void toggleWishlist(String cardId) {
    wishlist = wishlist.contains(cardId) ? wishlist.where((x) => x != cardId).toList() : [...wishlist, cardId];
    _commit();
  }

  double wantedPrice(WantedPost w) => ((cards[w.cardId]?.price ?? 0) * (1 + w.premium) * 100).round() / 100;

  void offerToBuyer(String id) {
    final w = wanted.firstWhere((x) => x.id == id, orElse: () => throw StateError('no wanted'));
    if (w.status != WantedStatus.open) return;
    final price = wantedPrice(w);
    final fees = (price * 0.062 * 100).round() / 100;
    listings = [
      Listing(id: 'l${_now()}', cardId: w.cardId, condition: Condition.nm, price: price, fees: fees, markets: ['direct to ${w.buyer.name}'], createdAt: _todayLabel(), status: ListingStatus.active),
      ...listings,
    ];
    wanted = wanted.map((x) => x.id == id ? x.copyWith(status: WantedStatus.offered) : x).toList();
    _commit();
  }

  void sellBinder(String binderId, double askPrice) {
    final b = binders.firstWhere((x) => x.id == binderId, orElse: () => throw StateError('no binder'));
    final cardIds = b.pockets.map((p) => p.cardId).whereType<String>().toList();
    if (cardIds.isEmpty) return;
    market = [
      MarketListing(id: 'm${_now()}', kind: MarketKind.binder, cardIds: cardIds, binderName: b.name, condition: Condition.nm, discount: 0, seller: const Buyer(name: 'You', rating: 5.0, trades: 0), minsAgo: 0, status: MarketStatus.mine, askPrice: askPrice),
      ...market,
    ];
    _commit();
  }

  void resetAll() {
    binders = _startBinders();
    listings = [];
    pool = _defaultPool;
    market = List.of(db.marketSeed);
    collection = Map.of(db.defaultCollection);
    wishlist = [];
    wanted = List.of(db.wantedSeed);
    _commit();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}

int _seq = 0;
int _now() {
  _seq += 1;
  return DateTime.now().millisecondsSinceEpoch + _seq;
}

String _todayLabel() {
  final now = DateTime.now();
  return '${now.month}/${now.day}/${now.year}';
}

class _Rng {
  int _seed = DateTime.now().microsecondsSinceEpoch;
  double nextDouble() {
    _seed = (_seed * 1103515245 + 12345) & 0x7FFFFFFF;
    return _seed / 0x7FFFFFFF;
  }
}

String fmt(double n) {
  final fixed = n.toStringAsFixed(2);
  final parts = fixed.split('.');
  final intPart = parts[0];
  final neg = intPart.startsWith('-');
  final digits = neg ? intPart.substring(1) : intPart;
  final buf = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buf.write(',');
    buf.write(digits[i]);
  }
  return '${neg ? '-' : ''}$buf.${parts[1]}';
}

String pct(double f) => '${f >= 0 ? '+' : ''}${(f * 100).toStringAsFixed(2)}%';
