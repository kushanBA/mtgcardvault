import '../../domain/entities/card.dart';

class CardCatalogModel extends CardCatalog {
  CardCatalogModel({
    required super.name,
    required super.setName,
    required super.imageUrl,
    required super.usdPrice,
    required super.eurPrice,
    required super.tcgPlayerPrice,
    required super.cardMarketPrice,
    required super.cardKingdomPrice,
  });

  factory CardCatalogModel.fromJson(Map<String, dynamic> map) {
    return CardCatalogModel(
      name: map['name'],
      setName: map['setName'],
      imageUrl: map['imageUrl'],
      usdPrice: (map['usdPrice'] as num).toDouble(),
      eurPrice: (map['eurPrice'] as num).toDouble(),
      tcgPlayerPrice: (map['tcgPlayerPrice'] as num).toDouble(),
      cardMarketPrice: (map['cardMarketPrice'] as num).toDouble(),
      cardKingdomPrice: (map['cardKingdomPrice'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'setName': setName,
    'imageUrl': imageUrl,
    'usdPrice': usdPrice,
    'eurPrice': eurPrice,
    'tcgPlayerPrice': tcgPlayerPrice,
    'cardMarketPrice': cardMarketPrice,
    'cardKingdomPrice': cardKingdomPrice,
  };
}

class CardModel extends Card {
  CardModel({
    required super.scryfallId,
    super.catalogCardId,
    required super.title,
    required super.setName,
    required super.setCode,
    required super.cardNumber,
    required super.rarity,
    required super.typeLine,
    required super.artist,
    required super.image,
    required super.foil,
    required super.nonfoil,
    super.catalog,
  });

  factory CardModel.fromJson(Map<String, dynamic> map) {
    return CardModel(
      scryfallId: map['scryfallId'],
      catalogCardId: map['catalogCardId'],
      title: map['title'],
      setName: map['setName'],
      setCode: map['setCode'],
      cardNumber: map['cardNumber'],
      rarity: map['rarity'],
      typeLine: map['typeLine'],
      artist: map['artist'],
      image: map['image'],
      foil: map['foil'],
      nonfoil: map['nonfoil'],
      catalog: map['catalog'] != null ? CardCatalogModel.fromJson(map['catalog']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'scryfallId': scryfallId,
    'catalogCardId': catalogCardId,
    'title': title,
    'setName': setName,
    'setCode': setCode,
    'cardNumber': cardNumber,
    'rarity': rarity,
    'typeLine': typeLine,
    'artist': artist,
    'image': image,
    'foil': foil,
    'nonfoil': nonfoil,
    'catalog': catalog != null ? (catalog as CardCatalogModel).toJson() : null,
  };
}

class ScanModel extends Scan {
  ScanModel({
    required super.id,
    required super.source,
    required super.status,
    required super.createdAt,
  });

  factory ScanModel.fromJson(Map<String, dynamic> map) {
    return ScanModel(
      id: map['id'],
      source: map['source'],
      status: map['status'],
      createdAt: map['createdAt'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'source': source,
    'status': status,
    'createdAt': createdAt,
  };
}

class DetectionModel extends Detection {
  DetectionModel({
    required super.correctedTitle,
    required super.correctedSet,
    required super.correctedNumber,
    required super.correctedRarity,
    required super.isOldCard,
    required super.isToken,
  });

  factory DetectionModel.fromJson(Map<String, dynamic> map) {
    return DetectionModel(
      correctedTitle: map['corrected_title'],
      correctedSet: map['corrected_set'],
      correctedNumber: map['corrected_number'],
      correctedRarity: map['corrected_rarity'],
      isOldCard: map['is_old_card'],
      isToken: map['is_token'],
    );
  }

  Map<String, dynamic> toJson() => {
    'corrected_title': correctedTitle,
    'corrected_set': correctedSet,
    'corrected_number': correctedNumber,
    'corrected_rarity': correctedRarity,
    'is_old_card': isOldCard,
    'is_token': isToken,
  };
}

class CardScanResultModel extends CardScanResult {
  CardScanResultModel({
    required super.status,
    required super.scan,
    required super.card,
    required super.detection,
  });

  factory CardScanResultModel.fromJson(Map<String, dynamic> map) {
    return CardScanResultModel(
      status: map['status'],
      scan: ScanModel.fromJson(map['scan']),
      card: CardModel.fromJson(map['card']),
      detection: DetectionModel.fromJson(map['detection']),
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'scan': (scan as ScanModel).toJson(),
    'card': (card as CardModel).toJson(),
    'detection': (detection as DetectionModel).toJson(),
  };
}
