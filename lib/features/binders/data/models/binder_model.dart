import '../../domain/entities/binder.dart';

class CatalogCardModel extends CatalogCard {
  CatalogCardModel({required super.id, required super.name, required super.imageUrl});

  factory CatalogCardModel.fromJson(Map<String, dynamic> map) {
    return CatalogCardModel(
      id: map['id'],
      name: map['name'],
      imageUrl: map['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'imageUrl': imageUrl};
}

class PocketModel extends Pocket {
  PocketModel({
    required super.position,
    super.catalogCardId,
    super.paid,
    super.catalogCard,
  });

  factory PocketModel.fromJson(Map<String, dynamic> map) {
    return PocketModel(
      position: map['position'],
      catalogCardId: map['catalogCardId'],
      paid: (map['paid'] as num?)?.toDouble(),
      catalogCard: map['catalogCard'] != null ? CatalogCardModel.fromJson(map['catalogCard']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'position': position,
    'catalogCardId': catalogCardId,
    'paid': paid,
    'catalogCard': catalogCard != null ? (catalogCard as CatalogCardModel).toJson() : null,
  };
}

class BinderModel extends Binder {
  BinderModel({
    required super.id,
    required super.name,
    required super.game,
    required super.isPublic,
    super.pockets,
  });

  factory BinderModel.fromJson(Map<String, dynamic> map) {
    return BinderModel(
      id: map['id'],
      name: map['name'],
      game: GameApiValue.fromApiValue(map['game']),
      isPublic: map['isPublic'],
      pockets: map['pockets'] != null
          ? (map['pockets'] as List).map((p) => PocketModel.fromJson(p as Map<String, dynamic>)).toList()
          : const [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'game': game.apiValue,
    'isPublic': isPublic,
    'pockets': pockets.map((p) => (p as PocketModel).toJson()).toList(),
  };
}

class PublicBindersPageModel extends PublicBindersPage {
  PublicBindersPageModel({
    required super.items,
    required super.total,
    required super.page,
    required super.pageSize,
  });

  factory PublicBindersPageModel.fromJson(Map<String, dynamic> map) {
    return PublicBindersPageModel(
      items: (map['items'] as List).map((b) => BinderModel.fromJson(b as Map<String, dynamic>)).toList(),
      total: map['total'],
      page: map['page'],
      pageSize: map['pageSize'],
    );
  }
}
