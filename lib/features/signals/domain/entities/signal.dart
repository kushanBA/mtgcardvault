enum SignalVerdict { sell, watch }

extension SignalVerdictApiValue on SignalVerdict {
  String get apiValue => switch (this) {
    SignalVerdict.sell => 'SELL',
    SignalVerdict.watch => 'WATCH',
  };

  static SignalVerdict fromApiValue(String value) => switch (value) {
    'SELL' => SignalVerdict.sell,
    _ => SignalVerdict.watch,
  };
}

class Signal {
  final String id;
  final String catalogCardId;
  final String name;
  final String setName;
  final String imageUrl;
  final double price;
  final SignalVerdict verdict;
  final double confidence;
  final String reason;
  final double? changePercent7d;
  final double? changePercent30d;

  /// Daily prices, oldest first, ~1 month — for the sparkline under the card.
  final List<double> priceHistory;

  Signal({
    required this.id,
    required this.catalogCardId,
    required this.name,
    required this.setName,
    required this.imageUrl,
    required this.price,
    required this.verdict,
    required this.confidence,
    required this.reason,
    this.changePercent7d,
    this.changePercent30d,
    required this.priceHistory,
  });
}
