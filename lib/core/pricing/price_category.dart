enum PriceCategory { tcgPlayer, usd, cardKingdom }

extension PriceCategoryLabel on PriceCategory {
  String get label => switch (this) {
    PriceCategory.tcgPlayer => 'tcg price',
    PriceCategory.usd => 'scryfall price',
    PriceCategory.cardKingdom => 'card kindom price',
  };
}
