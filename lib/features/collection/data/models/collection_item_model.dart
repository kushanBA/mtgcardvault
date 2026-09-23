import '../../domain/entities/collection_item.dart';

class CollectionCatalogCardModel extends CollectionCatalogCard {
  CollectionCatalogCardModel({
    required super.id,
    required super.name,
    required super.game,
    required super.setCode,
    required super.setName,
    required super.number,
    required super.imageUrl,
    super.price,
    super.dayOpenPrice,
    super.usdPrice,
    super.eurPrice,
    super.tcgPlayerPrice,
    super.cardMarketPrice,
    super.cardKingdomPrice,
  });

  factory CollectionCatalogCardModel.fromJson(Map<String, dynamic> map) {
    return CollectionCatalogCardModel(
      id: map['id'],
      name: map['name'],
      game: map['game'],
      setCode: map['setCode'],
      setName: map['setName'],
      number: map['number'],
      imageUrl: map['imageUrl'],
      price: (map['price'] as num?)?.toDouble(),
      dayOpenPrice: (map['dayOpenPrice'] as num?)?.toDouble(),
      usdPrice: (map['usdPrice'] as num?)?.toDouble(),
      eurPrice: (map['eurPrice'] as num?)?.toDouble(),
      tcgPlayerPrice: (map['tcgPlayerPrice'] as num?)?.toDouble(),
      cardMarketPrice: (map['cardMarketPrice'] as num?)?.toDouble(),
      cardKingdomPrice: (map['cardKingdomPrice'] as num?)?.toDouble(),
    );
  }
}

class CollectionItemModel extends CollectionItem {
  CollectionItemModel({
    required super.id,
    required super.catalogCardId,
    required super.quantity,
    super.condition,
    super.finish,
    required super.catalogCard,
  });

  factory CollectionItemModel.fromJson(Map<String, dynamic> map) {
    return CollectionItemModel(
      id: map['id'],
      catalogCardId: map['catalogCardId'],
      quantity: map['quantity'],
      condition: map['condition'] != null
          ? CardConditionApiValue.fromApiValue(map['condition'])
          : null,
      finish: map['finish'] != null
          ? CardFinishApiValue.fromApiValue(map['finish'])
          : null,
      catalogCard: CollectionCatalogCardModel.fromJson(map['catalogCard']),
    );
  }
}

class CollectionPageModel extends CollectionPage {
  CollectionPageModel({
    required super.items,
    required super.total,
    required super.page,
    required super.pageSize,
  });

  factory CollectionPageModel.fromJson(Map<String, dynamic> map) {
    return CollectionPageModel(
      items: (map['items'] as List)
          .map((i) => CollectionItemModel.fromJson(i as Map<String, dynamic>))
          .toList(),
      total: map['total'],
      page: map['page'],
      pageSize: map['pageSize'],
    );
  }
}
