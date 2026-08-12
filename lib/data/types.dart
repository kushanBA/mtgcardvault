enum Condition { nm, lp, mp, hp }

extension ConditionLabel on Condition {
  String get code => switch (this) {
        Condition.nm => 'NM',
        Condition.lp => 'LP',
        Condition.mp => 'MP',
        Condition.hp => 'HP',
      };

  static Condition fromCode(String code) => switch (code) {
        'LP' => Condition.lp,
        'MP' => Condition.mp,
        'HP' => Condition.hp,
        _ => Condition.nm,
      };
}

class SoldRecord {
  final String source;
  final Condition condition;
  final String date;
  final double price;
  const SoldRecord({required this.source, required this.condition, required this.date, required this.price});
}

class Card {
  final String id;
  final String name;
  final String number;
  final String set;
  /// which TCG the card belongs to — binders only accept cards of their own game
  final String game;
  final String language;
  /// placeholder art color until real images are wired in
  final String art;
  /// market price at day open, used for 24h change
  final double dayOpen;
  /// current live market price (random-walked by the store ticker)
  final double price;
  /// 90-day daily price history, oldest first
  final List<double> history;
  final double gradedPsa9;
  final double gradedPsa10;
  final List<SoldRecord> recentSolds;

  const Card({
    required this.id,
    required this.name,
    required this.number,
    required this.set,
    required this.game,
    required this.language,
    required this.art,
    required this.dayOpen,
    required this.price,
    required this.history,
    required this.gradedPsa9,
    required this.gradedPsa10,
    required this.recentSolds,
  });

  Card copyWith({double? price}) => Card(
        id: id,
        name: name,
        number: number,
        set: set,
        game: game,
        language: language,
        art: art,
        dayOpen: dayOpen,
        price: price ?? this.price,
        history: history,
        gradedPsa9: gradedPsa9,
        gradedPsa10: gradedPsa10,
        recentSolds: recentSolds,
      );
}

class Pocket {
  /// null when the pocket is empty
  final String? cardId;
  /// price paid, for cost basis
  final double paid;
  const Pocket({this.cardId, this.paid = 0});

  Map<String, dynamic> toJson() => {'cardId': cardId, 'paid': paid};
  factory Pocket.fromJson(Map<String, dynamic> j) =>
      Pocket(cardId: j['cardId'] as String?, paid: (j['paid'] as num?)?.toDouble() ?? 0);
}

class Binder {
  final String id;
  final String name;
  /// binders are single-game: only cards of this game can be assigned
  final String game;
  final bool isPublic;
  /// always 9
  final List<Pocket> pockets;

  const Binder({required this.id, required this.name, required this.game, required this.isPublic, required this.pockets});

  Binder copyWith({String? name, String? game, bool? isPublic, List<Pocket>? pockets}) => Binder(
        id: id,
        name: name ?? this.name,
        game: game ?? this.game,
        isPublic: isPublic ?? this.isPublic,
        pockets: pockets ?? this.pockets,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'game': game,
        'isPublic': isPublic,
        'pockets': pockets.map((p) => p.toJson()).toList(),
      };
  factory Binder.fromJson(Map<String, dynamic> j) => Binder(
        id: j['id'] as String,
        name: j['name'] as String,
        game: j['game'] as String? ?? 'Pokémon',
        isPublic: j['isPublic'] as bool? ?? false,
        pockets: (j['pockets'] as List).map((p) => Pocket.fromJson(p as Map<String, dynamic>)).toList(),
      );
}

enum ListingStatus { active, sold }

class Listing {
  final String id;
  final String cardId;
  final Condition condition;
  final double price;
  final double fees;
  final List<String> markets;
  final String createdAt;
  final ListingStatus status;

  const Listing({
    required this.id,
    required this.cardId,
    required this.condition,
    required this.price,
    required this.fees,
    required this.markets,
    required this.createdAt,
    required this.status,
  });

  Listing copyWith({ListingStatus? status}) => Listing(
        id: id,
        cardId: cardId,
        condition: condition,
        price: price,
        fees: fees,
        markets: markets,
        createdAt: createdAt,
        status: status ?? this.status,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'cardId': cardId,
        'condition': condition.code,
        'price': price,
        'fees': fees,
        'markets': markets,
        'createdAt': createdAt,
        'status': status.name,
      };
  factory Listing.fromJson(Map<String, dynamic> j) => Listing(
        id: j['id'] as String,
        cardId: j['cardId'] as String,
        condition: ConditionLabel.fromCode(j['condition'] as String),
        price: (j['price'] as num).toDouble(),
        fees: (j['fees'] as num).toDouble(),
        markets: (j['markets'] as List).cast<String>(),
        createdAt: j['createdAt'] as String,
        status: (j['status'] as String) == 'sold' ? ListingStatus.sold : ListingStatus.active,
      );
}

class ScanResult {
  final Card card;
  final Condition estimatedCondition;
  final double confidence;
  const ScanResult({required this.card, required this.estimatedCondition, required this.confidence});
}

/// A buyer's public "I want this card" post — sellers see these and can offer their copy
class Buyer {
  final String name;
  final double rating;
  final int trades;
  const Buyer({required this.name, required this.rating, required this.trades});

  Map<String, dynamic> toJson() => {'name': name, 'rating': rating, 'trades': trades};
  factory Buyer.fromJson(Map<String, dynamic> j) =>
      Buyer(name: j['name'] as String, rating: (j['rating'] as num).toDouble(), trades: j['trades'] as int);
}

enum WantedStatus { open, offered }

class WantedPost {
  final String id;
  final String cardId;
  final Buyer buyer;
  /// fraction relative to live market the buyer will pay (0.03 = 3% over)
  final double premium;
  final int minsAgo;
  final WantedStatus status;

  const WantedPost({
    required this.id,
    required this.cardId,
    required this.buyer,
    required this.premium,
    required this.minsAgo,
    required this.status,
  });

  WantedPost copyWith({WantedStatus? status}) => WantedPost(
        id: id,
        cardId: cardId,
        buyer: buyer,
        premium: premium,
        minsAgo: minsAgo,
        status: status ?? this.status,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'cardId': cardId,
        'buyer': buyer.toJson(),
        'premium': premium,
        'minsAgo': minsAgo,
        'status': status.name,
      };
  factory WantedPost.fromJson(Map<String, dynamic> j) => WantedPost(
        id: j['id'] as String,
        cardId: j['cardId'] as String,
        buyer: Buyer.fromJson(j['buyer'] as Map<String, dynamic>),
        premium: (j['premium'] as num).toDouble(),
        minsAgo: j['minsAgo'] as int,
        status: (j['status'] as String) == 'offered' ? WantedStatus.offered : WantedStatus.open,
      );
}

enum MarketKind { card, binder }

enum MarketStatus { available, purchased, mine }

class MarketListing {
  final String id;
  final MarketKind kind;
  /// one card id for kind card; the lot's cards for kind binder
  final List<String> cardIds;
  final String? binderName;
  final Condition condition;
  /// fraction below live market (negative = priced above market)
  final double discount;
  final Buyer seller;
  final int minsAgo;
  final MarketStatus status;
  /// fixed asking price for your own listings
  final double? askPrice;

  const MarketListing({
    required this.id,
    required this.kind,
    required this.cardIds,
    this.binderName,
    required this.condition,
    required this.discount,
    required this.seller,
    required this.minsAgo,
    required this.status,
    this.askPrice,
  });

  MarketListing copyWith({MarketStatus? status}) => MarketListing(
        id: id,
        kind: kind,
        cardIds: cardIds,
        binderName: binderName,
        condition: condition,
        discount: discount,
        seller: seller,
        minsAgo: minsAgo,
        status: status ?? this.status,
        askPrice: askPrice,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'kind': kind.name,
        'cardIds': cardIds,
        'binderName': binderName,
        'condition': condition.code,
        'discount': discount,
        'seller': seller.toJson(),
        'minsAgo': minsAgo,
        'status': status.name,
        'askPrice': askPrice,
      };
  factory MarketListing.fromJson(Map<String, dynamic> j) => MarketListing(
        id: j['id'] as String,
        kind: (j['kind'] as String) == 'binder' ? MarketKind.binder : MarketKind.card,
        cardIds: (j['cardIds'] as List).cast<String>(),
        binderName: j['binderName'] as String?,
        condition: ConditionLabel.fromCode(j['condition'] as String),
        discount: (j['discount'] as num).toDouble(),
        seller: Buyer.fromJson(j['seller'] as Map<String, dynamic>),
        minsAgo: j['minsAgo'] as int,
        status: switch (j['status'] as String) {
          'purchased' => MarketStatus.purchased,
          'mine' => MarketStatus.mine,
          _ => MarketStatus.available,
        },
        askPrice: (j['askPrice'] as num?)?.toDouble(),
      );
}
