import 'types.dart';

/// Deterministic pseudo-random so history curves are stable between reloads
class _Mulberry32 {
  int seed;
  _Mulberry32(this.seed);

  double next() {
    seed = (seed + 0x6d2b79f5) & 0xFFFFFFFF;
    int t = seed;
    t = (_imul(t ^ (t >>> 15), (t | 1))) & 0xFFFFFFFF;
    t = (t ^ (_imul(t ^ (t >>> 7), (t | 61)) & 0xFFFFFFFF)) & 0xFFFFFFFF;
    return ((t ^ (t >>> 14)) & 0xFFFFFFFF) / 4294967296.0;
  }

  static int _imul(int a, int b) => (a * b) & 0xFFFFFFFF;
}

List<double> _makeHistory(double target, int seed, {int days = 90}) {
  final rand = _Mulberry32(seed);
  final out = <double>[];
  double v = target * (0.78 + rand.next() * 0.12);
  for (var i = 0; i < days - 1; i++) {
    v = v * (1 + (rand.next() - 0.47) * 0.03);
    out.add((v * 100).round() / 100);
  }
  out.add(target);
  return out;
}

const List<String> games = ['Pokémon', 'Magic: The Gathering', 'One Piece', 'Flesh and Blood'];

const Map<String, String> gameShort = {
  'Pokémon': 'Pokémon',
  'Magic: The Gathering': 'MTG',
  'One Piece': 'One Piece',
  'Flesh and Blood': 'F&B',
};

/// Allocation colors for the per-game portfolio breakdown
const Map<String, int> gameColors = {
  'Pokémon': 0xFFE3B341,
  'Magic: The Gathering': 0xFF9A6BD6,
  'One Piece': 0xFFE05A4E,
  'Flesh and Blood': 0xFF2BD48A,
};

Card _card(
  String id,
  String name,
  String number,
  String set,
  String art,
  double price,
  int seed, [
  String game = 'Pokémon',
]) {
  final history = _makeHistory(price, seed);
  return Card(
    id: id,
    name: name,
    number: number,
    set: set,
    art: art,
    game: game,
    language: 'EN',
    dayOpen: price,
    price: price,
    history: history,
    gradedPsa9: (price * 1.7).round().toDouble(),
    gradedPsa10: (price * 4.1).round().toDouble(),
    recentSolds: [
      SoldRecord(source: 'eBay', condition: Condition.nm, date: 'Jul 14', price: (price * 1.02 * 100).round() / 100),
      SoldRecord(source: 'TCGplayer', condition: Condition.nm, date: 'Jul 13', price: (price * 0.99 * 100).round() / 100),
      SoldRecord(source: 'eBay', condition: Condition.lp, date: 'Jul 12', price: (price * 0.9 * 100).round() / 100),
    ],
  );
}

final List<Card> cards = [
  _card('zard', 'Charizard ex', '199/165', 'Obsidian Flames', '#B8651F', 182.4, 11),
  _card('pidgeot', 'Pidgeot ex', '217/165', 'Obsidian Flames', '#7B8FA3', 64.1, 12),
  _card('iono', 'Iono SIR', '237/193', 'Paldea Evolved', '#C77B9E', 186.0, 13),
  _card('moonbreon', 'Umbreon VMAX Alt', '215/203', 'Evolving Skies', '#4A4F6B', 455.0, 14),
  _card('garde', 'Gardevoir ex', '245/198', 'Scarlet & Violet', '#6BA35E', 41.75, 15),
  _card('giratina', 'Giratina V Alt', '186/196', 'Lost Origin', '#8A5FB0', 95.0, 16),
  _card('pika', 'Pikachu promo', 'SWSH285', 'SWSH Promos', '#D9A73E', 77.9, 17),
  _card('lugia', 'Lugia V Alt', '186/195', 'Silver Tempest', '#3E8FA8', 228.0, 18),
  _card('rayquaza', 'Rayquaza VMAX Alt', '218/203', 'Evolving Skies', '#2E7D5B', 610.0, 19),
  _card('mew', 'Mew ex', '232/193', '151', '#D98CB0', 96.2, 20),
  _card('cleffa', 'Cleffa', '080/165', 'Obsidian Flames', '#E3B7C8', 12.4, 21),
  _card('zapdos', 'Zapdos ex', '202/165', '151', '#C9A227', 110.2, 22),
  // Magic: The Gathering — real scans from the Scryfall public database
  _card('sheoldred', 'Sheoldred, the Apocalypse', '107/281', 'Dominaria United', '#3A2E3F', 68.5, 23, 'Magic: The Gathering'),
  _card('onering', 'The One Ring', '246/281', 'Tales of Middle-earth', '#8A6D1A', 52.0, 24, 'Magic: The Gathering'),
  _card('ragavan', 'Ragavan, Nimble Pilferer', '138/303', 'Modern Horizons 2', '#A8402A', 64.0, 27, 'Magic: The Gathering'),
  _card('bowmasters', 'Orcish Bowmasters', '103/281', 'Tales of Middle-earth', '#4C3A2A', 31.5, 28, 'Magic: The Gathering'),
  _card('atraxa', 'Atraxa, Grand Unifier', '196/271', 'Phyrexia: All Will Be One', '#5E5A66', 17.8, 29, 'Magic: The Gathering'),
  _card('fable', 'Fable of the Mirror-Breaker', '141/302', 'Kamigawa: Neon Dynasty', '#8A3A2A', 12.6, 30, 'Magic: The Gathering'),
  // One Piece — real scans from the official Bandai card list
  _card('luffy', 'Monkey D. Luffy Alt', 'OP05-119', 'Awakening of the New Era', '#B03030', 95.0, 25, 'One Piece'),
  _card('shanks', 'Shanks Leader', 'OP01-120', 'Romance Dawn', '#7A1F1F', 40.0, 26, 'One Piece'),
  _card('zoro', 'Roronoa Zoro', 'OP01-025', 'Romance Dawn', '#2A5A3A', 15.5, 31, 'One Piece'),
  _card('nami', 'Nami Alt', 'OP01-016', 'Romance Dawn', '#C77B3A', 34.0, 32, 'One Piece'),
  // Flesh and Blood — scans via the fabmaster image bucket (the-fab-cube DB)
  _card('estrike', 'Enlightened Strike', '1HP361', 'History Pack 1', '#7A6A3A', 48.0, 33, 'Flesh and Blood'),
  _card('cnc', 'Command and Conquer', '1HP360', 'History Pack 1', '#8A3A3A', 24.5, 34, 'Flesh and Blood'),
  _card('skullcap', 'Arcanite Skullcap', 'ARC150', 'Arcane Rising', '#4A5A7A', 27.0, 35, 'Flesh and Blood'),
  _card('tunic', "Fyendal's Spring Tunic", '1HP341', 'History Pack 1', '#3A6A4A', 84.0, 36, 'Flesh and Blood'),
];

Card cardById(String id) => cards.firstWhere((c) => c.id == id, orElse: () => throw Exception('unknown card $id'));

/// Everything you own (card id -> total copies). Binders select from this pool.
final Map<String, int> defaultCollection = {
  'zard': 3, 'pidgeot': 1, 'garde': 1, 'iono': 1, 'lugia': 1, 'mew': 1, 'pika': 1, 'zapdos': 1,
  'moonbreon': 1, 'giratina': 2, 'rayquaza': 1, 'cleffa': 1,
  'sheoldred': 1, 'onering': 1, 'ragavan': 1, 'bowmasters': 2, 'atraxa': 1, 'fable': 1,
  'luffy': 1, 'shanks': 1, 'zoro': 1, 'nami': 1,
  'estrike': 1, 'cnc': 2, 'skullcap': 1, 'tunic': 1,
};

/// A community member's published binder, used by binder compare
class CommunityBinder {
  final String owner;
  final double rating;
  final int trades;
  final double distanceMi;
  final String binderName;
  /// cards Dana owns spares of (available to trade away)
  final List<String> spares;
  /// cards Dana needs for her sets
  final List<String> needs;
  const CommunityBinder({
    required this.owner,
    required this.rating,
    required this.trades,
    required this.distanceMi,
    required this.binderName,
    required this.spares,
    required this.needs,
  });
}

const communityBinder = CommunityBinder(
  owner: 'Dana R.',
  rating: 4.8,
  trades: 122,
  distanceMi: 2.1,
  binderName: 'Moonbreon shrine',
  spares: ['iono', 'mew'],
  needs: ['zard', 'giratina'],
);

/// Duplicates you own beyond the binder copy (quantity of spares per card id)
const Map<String, int> mySpares = {'zard': 2, 'giratina': 1};

/// Cards that would fill gaps in your sets
const List<String> myNeeds = ['iono', 'mew'];

/// Buyers publicly looking for cards — the seller side of the wishlist loop
final List<WantedPost> wantedSeed = [
  const WantedPost(id: 'w1', cardId: 'zard', premium: 0.03, minsAgo: 8, status: WantedStatus.open, buyer: Buyer(name: 'Maria T.', rating: 5.0, trades: 64)),
  const WantedPost(id: 'w2', cardId: 'sheoldred', premium: 0.05, minsAgo: 25, status: WantedStatus.open, buyer: Buyer(name: 'Alex K.', rating: 4.9, trades: 37)),
  const WantedPost(id: 'w3', cardId: 'moonbreon', premium: -0.02, minsAgo: 51, status: WantedStatus.open, buyer: Buyer(name: 'Dana R.', rating: 4.8, trades: 122)),
  const WantedPost(id: 'w4', cardId: 'giratina', premium: 0.04, minsAgo: 76, status: WantedStatus.open, buyer: Buyer(name: 'Maria T.', rating: 5.0, trades: 64)),
];

/// Community marketplace feed — prices resolve against the live ticker at render time
final List<MarketListing> marketSeed = [
  const MarketListing(id: 'm1', kind: MarketKind.card, cardIds: ['iono'], condition: Condition.nm, discount: 0.04, seller: Buyer(name: 'Dana R.', rating: 4.8, trades: 122), minsAgo: 12, status: MarketStatus.available),
  const MarketListing(id: 'm2', kind: MarketKind.card, cardIds: ['moonbreon'], condition: Condition.lp, discount: 0.09, seller: Buyer(name: 'Alex K.', rating: 4.9, trades: 37), minsAgo: 34, status: MarketStatus.available),
  const MarketListing(id: 'm3', kind: MarketKind.binder, cardIds: ['garde', 'pika', 'mew', 'cleffa', 'zapdos'], binderName: 'Starter value page', condition: Condition.nm, discount: 0.06, seller: Buyer(name: 'Dana R.', rating: 4.8, trades: 122), minsAgo: 47, status: MarketStatus.available),
  const MarketListing(id: 'm4', kind: MarketKind.card, cardIds: ['rayquaza'], condition: Condition.nm, discount: -0.03, seller: Buyer(name: 'Maria T.', rating: 5.0, trades: 64), minsAgo: 63, status: MarketStatus.available),
  const MarketListing(id: 'm5', kind: MarketKind.card, cardIds: ['cleffa'], condition: Condition.nm, discount: 0.12, seller: Buyer(name: 'Alex K.', rating: 4.9, trades: 37), minsAgo: 71, status: MarketStatus.available),
  const MarketListing(id: 'm6', kind: MarketKind.binder, cardIds: ['lugia', 'giratina', 'pidgeot'], binderName: '151 chase trio', condition: Condition.nm, discount: 0.02, seller: Buyer(name: 'Maria T.', rating: 5.0, trades: 64), minsAgo: 88, status: MarketStatus.available),
  const MarketListing(id: 'm7', kind: MarketKind.card, cardIds: ['ragavan'], condition: Condition.nm, discount: 0.07, seller: Buyer(name: 'Alex K.', rating: 4.9, trades: 37), minsAgo: 94, status: MarketStatus.available),
  const MarketListing(id: 'm8', kind: MarketKind.binder, cardIds: ['sheoldred', 'atraxa', 'fable'], binderName: 'Modern staples page', condition: Condition.nm, discount: 0.05, seller: Buyer(name: 'Dana R.', rating: 4.8, trades: 122), minsAgo: 102, status: MarketStatus.available),
  const MarketListing(id: 'm9', kind: MarketKind.card, cardIds: ['nami'], condition: Condition.nm, discount: 0.06, seller: Buyer(name: 'Maria T.', rating: 5.0, trades: 64), minsAgo: 115, status: MarketStatus.available),
  const MarketListing(id: 'm10', kind: MarketKind.card, cardIds: ['tunic'], condition: Condition.nm, discount: 0.04, seller: Buyer(name: 'Alex K.', rating: 4.9, trades: 37), minsAgo: 130, status: MarketStatus.available),
];
