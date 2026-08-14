import '../../../../core/pricing/price_category.dart';

enum Game { pokemon, mtg, yugioh, lorcana, onePiece, fleshAndBlood, other }

extension GameApiValue on Game {
  String get apiValue => switch (this) {
    Game.pokemon => 'POKEMON',
    Game.mtg => 'MTG',
    Game.yugioh => 'YUGIOH',
    Game.lorcana => 'LORCANA',
    Game.onePiece => 'ONE_PIECE',
    Game.fleshAndBlood => 'FLESH_AND_BLOOD',
    Game.other => 'OTHER',
  };

  static Game fromApiValue(String value) => switch (value) {
    'POKEMON' => Game.pokemon,
    'MTG' => Game.mtg,
    'YUGIOH' => Game.yugioh,
    'LORCANA' => Game.lorcana,
    'ONE_PIECE' => Game.onePiece,
    'FLESH_AND_BLOOD' => Game.fleshAndBlood,
    _ => Game.other,
  };
}

extension GameLabel on Game {
  String get label => switch (this) {
    Game.pokemon => 'Pokémon',
    Game.mtg => 'Magic: The Gathering',
    Game.yugioh => 'Yu-Gi-Oh!',
    Game.lorcana => 'Disney Lorcana',
    Game.onePiece => 'One Piece',
    Game.fleshAndBlood => 'Flesh and Blood',
    Game.other => 'Other',
  };
}

class CatalogCard {
  final String id;
  final String name;
  final String imageUrl;
  final double? usdPrice;
  final double? eurPrice;
  final double? tcgPlayerPrice;
  final double? cardMarketPrice;
  final double? cardKingdomPrice;

  CatalogCard({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.usdPrice,
    this.eurPrice,
    this.tcgPlayerPrice,
    this.cardMarketPrice,
    this.cardKingdomPrice,
  });
}

extension CatalogCardPricing on CatalogCard {
  double? priceFor(PriceCategory category) => switch (category) {
    PriceCategory.tcgPlayer => tcgPlayerPrice,
    PriceCategory.cardMarket => cardMarketPrice,
    PriceCategory.cardKingdom => cardKingdomPrice,
  };
}

class Pocket {
  final int position;
  final String? catalogCardId;
  final double? paid;
  final CatalogCard? catalogCard;

  Pocket({
    required this.position,
    this.catalogCardId,
    this.paid,
    this.catalogCard,
  });

  bool get isEmpty => catalogCardId == null;
}

class Binder {
  final String id;
  final String name;
  final Game game;
  final bool isPublic;

  /// Always 9 once loaded via [getBinder]/[createBinder]/[updateBinder] —
  /// empty for binders returned by the list endpoints, which omit pockets.
  final List<Pocket> pockets;

  Binder({
    required this.id,
    required this.name,
    required this.game,
    required this.isPublic,
    this.pockets = const [],
  });
}

class PublicBindersPage {
  final List<Binder> items;
  final int total;
  final int page;
  final int pageSize;

  PublicBindersPage({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
  });
}
