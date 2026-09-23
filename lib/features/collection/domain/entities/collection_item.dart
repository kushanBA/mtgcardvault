import '../../../../core/pricing/price_category.dart';

enum CardCondition { nm, lp, mp, hp, dmg }

extension CardConditionApiValue on CardCondition {
  String get apiValue => switch (this) {
    CardCondition.nm => 'NM',
    CardCondition.lp => 'LP',
    CardCondition.mp => 'MP',
    CardCondition.hp => 'HP',
    CardCondition.dmg => 'DMG',
  };

  static CardCondition fromApiValue(String value) => switch (value) {
    'NM' => CardCondition.nm,
    'LP' => CardCondition.lp,
    'MP' => CardCondition.mp,
    'HP' => CardCondition.hp,
    _ => CardCondition.dmg,
  };
}

enum CardFinish { normal, foil, holo, reverseHolo, etched }

extension CardFinishApiValue on CardFinish {
  String get apiValue => switch (this) {
    CardFinish.normal => 'NORMAL',
    CardFinish.foil => 'FOIL',
    CardFinish.holo => 'HOLO',
    CardFinish.reverseHolo => 'REVERSE_HOLO',
    CardFinish.etched => 'ETCHED',
  };

  static CardFinish fromApiValue(String value) => switch (value) {
    'FOIL' => CardFinish.foil,
    'HOLO' => CardFinish.holo,
    'REVERSE_HOLO' => CardFinish.reverseHolo,
    'ETCHED' => CardFinish.etched,
    _ => CardFinish.normal,
  };
}

class CollectionCatalogCard {
  final String id;
  final String name;
  final String game;
  final String setCode;
  final String setName;
  final String number;
  final String imageUrl;
  final double? price;
  final double? dayOpenPrice;
  final double? usdPrice;
  final double? eurPrice;
  final double? tcgPlayerPrice;
  final double? cardMarketPrice;
  final double? cardKingdomPrice;

  CollectionCatalogCard({
    required this.id,
    required this.name,
    required this.game,
    required this.setCode,
    required this.setName,
    required this.number,
    required this.imageUrl,
    this.price,
    this.dayOpenPrice,
    this.usdPrice,
    this.eurPrice,
    this.tcgPlayerPrice,
    this.cardMarketPrice,
    this.cardKingdomPrice,
  });
}

extension CollectionCatalogCardPricing on CollectionCatalogCard {
  /// The price for the market the person picked in Profile settings — falls
  /// back to the flat `price` field when that specific market's price isn't
  /// in the catalog for this card.
  double? priceFor(PriceCategory category) =>
      switch (category) {
        PriceCategory.tcgPlayer => tcgPlayerPrice,
        PriceCategory.usd => usdPrice,
        PriceCategory.cardKingdom => cardKingdomPrice,
      } ??
      price;
}

class CollectionItem {
  final String id;
  final String catalogCardId;
  final int quantity;
  final CardCondition? condition;
  final CardFinish? finish;
  final CollectionCatalogCard catalogCard;

  CollectionItem({
    required this.id,
    required this.catalogCardId,
    required this.quantity,
    this.condition,
    this.finish,
    required this.catalogCard,
  });
}

class CollectionPage {
  final List<CollectionItem> items;
  final int total;
  final int page;
  final int pageSize;

  CollectionPage({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
  });
}
