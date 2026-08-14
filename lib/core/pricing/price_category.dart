import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/local_storage.dart' as storage;

const _storageKey = 'priceCat';

enum PriceCategory { tcgPlayer, cardMarket, cardKingdom }

extension PriceCategoryLabel on PriceCategory {
  String get label => switch (this) {
    PriceCategory.tcgPlayer => 'tcg price',
    PriceCategory.cardMarket => 'card market price',
    PriceCategory.cardKingdom => 'card kindom price',
  };
}

class PriceCategoryNotifier extends StateNotifier<PriceCategory> {
  PriceCategoryNotifier() : super(PriceCategory.tcgPlayer) {
    _restore();
  }

  Future<void> _restore() async {
    final saved = await storage.load<String>(_storageKey, (v) => v as String);
    if (saved == null) return;
    state = PriceCategory.values.firstWhere(
      (c) => c.name == saved,
      orElse: () => state,
    );
  }

  Future<void> select(PriceCategory category) async {
    state = category;
    await storage.save(_storageKey, category.name);
  }
}

final priceCategoryProvider =
    StateNotifierProvider<PriceCategoryNotifier, PriceCategory>(
      (ref) => PriceCategoryNotifier(),
    );
