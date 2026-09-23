import 'package:flutter_bloc/flutter_bloc.dart';
import '../../storage/local_storage.dart' as storage;
import '../price_category.dart';
import 'price_category_event.dart';
import 'price_category_state.dart';

const _storageKey = 'priceCat';

class PriceCategoryBloc extends Bloc<PriceCategoryEvent, PriceCategoryState> {
  PriceCategoryBloc() : super(const PriceCategoryState.initial()) {
    on<RestorePriceCategory>(_onRestore);
    on<SelectPriceCategory>(_onSelect);
  }

  Future<void> _onRestore(
    RestorePriceCategory event,
    Emitter<PriceCategoryState> emit,
  ) async {
    final saved = await storage.load<String>(_storageKey, (v) => v as String);
    if (saved == null) return;
    final category = PriceCategory.values.firstWhere(
      (c) => c.name == saved,
      orElse: () => state.category,
    );
    emit(PriceCategoryState(category));
  }

  Future<void> _onSelect(
    SelectPriceCategory event,
    Emitter<PriceCategoryState> emit,
  ) async {
    emit(PriceCategoryState(event.category));
    await storage.save(_storageKey, event.category.name);
  }
}
