import 'package:equatable/equatable.dart';
import '../price_category.dart';

class PriceCategoryState extends Equatable {
  final PriceCategory category;
  const PriceCategoryState(this.category);

  const PriceCategoryState.initial() : category = PriceCategory.tcgPlayer;

  @override
  List<Object?> get props => [category];
}
