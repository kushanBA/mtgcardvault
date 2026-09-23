import '../../domain/entities/signal.dart';

class SignalModel extends Signal {
  SignalModel({
    required super.id,
    required super.catalogCardId,
    required super.name,
    required super.setName,
    required super.imageUrl,
    required super.price,
    required super.verdict,
    required super.confidence,
    required super.reason,
    super.changePercent7d,
    super.changePercent30d,
    required super.priceHistory,
  });

  factory SignalModel.fromJson(Map<String, dynamic> map) {
    return SignalModel(
      id: map['id'],
      catalogCardId: map['catalogCardId'],
      name: map['name'],
      setName: map['setName'],
      imageUrl: map['imageUrl'],
      price: (map['price'] as num).toDouble(),
      verdict: SignalVerdictApiValue.fromApiValue(map['verdict']),
      confidence: (map['confidence'] as num).toDouble(),
      reason: map['reason'],
      changePercent7d: (map['changePercent7d'] as num?)?.toDouble(),
      changePercent30d: (map['changePercent30d'] as num?)?.toDouble(),
      priceHistory: (map['priceHistory'] as List)
          .map((e) => (e as num).toDouble())
          .toList(),
    );
  }
}
