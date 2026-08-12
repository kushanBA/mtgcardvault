import 'dart:math';
import 'mock_db.dart';
import 'types.dart';

/// Interfaces the real algorithm will implement later.
/// The app only ever talks to these — swapping the mock for the real
/// recognition/pricing engine is a drop-in change here.
abstract class RecognitionService {
  /// Identify a card (and estimate condition) from a camera frame.
  Future<ScanResult> recognize();
}

abstract class PriceService {
  /// Suggested listing price and estimated days-to-sell at that price.
  ({double price, int daysToSell}) suggestListing(Card card, Condition condition);
  double get marketplaceFeeRate;
}

class MockRecognition implements RecognitionService {
  int _i = 0;
  final _order = ['zard', 'moonbreon', 'iono', 'lugia', 'giratina', 'mew'];
  final _rand = Random();

  @override
  Future<ScanResult> recognize() async {
    final id = _order[_i % _order.length];
    _i += 1;
    final card = cards.firstWhere((c) => c.id == id);
    const conditions = [Condition.nm, Condition.nm, Condition.nm, Condition.lp];
    await Future.delayed(const Duration(milliseconds: 1800));
    return ScanResult(
      card: card,
      estimatedCondition: conditions[_rand.nextInt(conditions.length)],
      confidence: 0.93 + _rand.nextDouble() * 0.06,
    );
  }
}

class MockPricing implements PriceService {
  @override
  double get marketplaceFeeRate => 0.05;

  @override
  ({double price, int daysToSell}) suggestListing(Card card, Condition condition) {
    final conditionFactor = switch (condition) {
      Condition.nm => 1.0,
      Condition.lp => 0.85,
      Condition.mp => 0.7,
      Condition.hp => 0.5,
    };
    final price = (card.price * conditionFactor * 0.98 * 100).round() / 100;
    return (price: price, daysToSell: 3);
  }
}

final RecognitionService recognition = MockRecognition();
final PriceService pricing = MockPricing();
