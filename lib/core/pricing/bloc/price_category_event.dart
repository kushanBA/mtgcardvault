import 'package:equatable/equatable.dart';
import '../price_category.dart';

sealed class PriceCategoryEvent extends Equatable {
  const PriceCategoryEvent();

  @override
  List<Object?> get props => [];
}

class RestorePriceCategory extends PriceCategoryEvent {
  const RestorePriceCategory();
}

class SelectPriceCategory extends PriceCategoryEvent {
  final PriceCategory category;
  const SelectPriceCategory(this.category);

  @override
  List<Object?> get props => [category];
}
