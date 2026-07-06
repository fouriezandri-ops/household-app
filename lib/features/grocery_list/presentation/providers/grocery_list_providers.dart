import 'package:riverpod/riverpod.dart' show Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/domain/entities/item.dart';
import '../../../../core/domain/entities/item_filter.dart';
import '../../../../core/domain/entities/list_type.dart';
import '../../../../core/providers/firestore_providers.dart';

part 'grocery_list_providers.g.dart';

@riverpod
Stream<List<Item>> groceryItems(Ref ref) {
  return ref.watch(itemsRepositoryProvider).watchByListType(ListType.grocery);
}

@riverpod
class GroceryFilterController extends _$GroceryFilterController {
  @override
  ItemFilterState build() => const ItemFilterState();

  void update(ItemFilterState value) => state = value;
}
