import '../../../collection/domain/entities/collection_item.dart';
import '../../domain/entities/listing.dart';

class ListingModel extends Listing {
  ListingModel({
    required super.id,
    required super.catalogCardId,
    required super.condition,
    required super.price,
    required super.fees,
    required super.markets,
    required super.status,
  });

  factory ListingModel.fromJson(Map<String, dynamic> map) {
    return ListingModel(
      id: map['id'],
      catalogCardId: map['catalogCardId'],
      condition: CardConditionApiValue.fromApiValue(map['condition']),
      price: (map['price'] as num).toDouble(),
      fees: (map['fees'] as num? ?? 0).toDouble(),
      markets: (map['markets'] as List? ?? []).map((e) => e as String).toList(),
      status: map['status'],
    );
  }
}
