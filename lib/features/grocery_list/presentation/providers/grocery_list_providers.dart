import 'package:riverpod/riverpod.dart' show Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/domain/entities/item.dart';
import '../../../../core/domain/entities/list_type.dart';
import '../../../../core/providers/firestore_providers.dart';
import '../../domain/entities/grocery_filter.dart';

part 'grocery_list_providers.g.dart';

@riverpod
Stream<List<Item>> groceryItems(Ref ref) {
  return ref.watch(itemsRepositoryProvider).watchByListType(ListType.grocery);
}

@riverpod
class GroceryFilterController extends _$GroceryFilterController {
  @override
  GroceryFilter build() => const GroceryFilterAll();

  void select(GroceryFilter filter) => state = filter;
}

/// Applies the current [GroceryFilter] to a list of items — pulled out of
/// the screen so it's independently testable.
List<Item> applyGroceryFilter(List<Item> items, GroceryFilter filter) {
  return switch (filter) {
    GroceryFilterAll() => items,
    GroceryFilterNotPurchased() => items.where((item) => !item.completed).toList(),
    GroceryFilterCategory(:final category) =>
      items.where((item) => item.category == category).toList(),
  };
}
