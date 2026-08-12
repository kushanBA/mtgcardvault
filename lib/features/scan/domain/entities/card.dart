class CardCatalog {
  final String name;
  final String setName;
  final String imageUrl;
  final double usdPrice;
  final double eurPrice;
  final double tcgPlayerPrice;
  final double cardMarketPrice;
  final double cardKingdomPrice;

  CardCatalog({
    required this.name,
    required this.setName,
    required this.imageUrl,
    required this.usdPrice,
    required this.eurPrice,
    required this.tcgPlayerPrice,
    required this.cardMarketPrice,
    required this.cardKingdomPrice,
  });
}

class Card {
  final String scryfallId;

  /// Pass straight into Binders' `POST /binders/:id/pockets` to add this
  /// card to a binder. Only populated for MTG cards — null otherwise.
  final String? catalogCardId;
  final String title;
  final String setName;
  final String setCode;
  final String cardNumber;
  final String rarity;
  final String typeLine;
  final String artist;
  final String image;
  final bool foil;
  final bool nonfoil;

  /// Null if this card isn't in the price catalog yet.
  final CardCatalog? catalog;

  Card({
    required this.scryfallId,
    this.catalogCardId,
    required this.title,
    required this.setName,
    required this.setCode,
    required this.cardNumber,
    required this.rarity,
    required this.typeLine,
    required this.artist,
    required this.image,
    required this.foil,
    required this.nonfoil,
    this.catalog,
  });
}

class Scan {
  final String id;
  final String source;
  final String status;
  final String createdAt;

  Scan({
    required this.id,
    required this.source,
    required this.status,
    required this.createdAt,
  });
}

class Detection {
  final String correctedTitle;
  final String correctedSet;
  final String correctedNumber;
  final String correctedRarity;
  final bool isOldCard;
  final bool isToken;

  Detection({
    required this.correctedTitle,
    required this.correctedSet,
    required this.correctedNumber,
    required this.correctedRarity,
    required this.isOldCard,
    required this.isToken,
  });
}

class CardScanResult {
  final String status;
  final Scan scan;
  final Card card;
  final Detection detection;

  CardScanResult({
    required this.status,
    required this.scan,
    required this.card,
    required this.detection,
  });
}
