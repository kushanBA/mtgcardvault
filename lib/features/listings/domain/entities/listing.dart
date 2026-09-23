import '../../../collection/domain/entities/collection_item.dart';

class Listing {
  final String id;
  final String catalogCardId;
  final CardCondition condition;
  final double price;
  final double fees;
  final List<String> markets;
  final String status;

  Listing({
    required this.id,
    required this.catalogCardId,
    required this.condition,
    required this.price,
    required this.fees,
    required this.markets,
    required this.status,
  });
}
