import 'package:riverpod/riverpod.dart' show Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/domain/entities/item.dart';
import '../../../../core/domain/entities/item_filter.dart';
import '../../../../core/domain/entities/list_type.dart';
import '../../../../core/providers/firestore_providers.dart';

part 'products_to_buy_providers.g.dart';

@riverpod
Stream<List<Item>> productsToBuyItems(Ref ref) {
  return ref.watch(itemsRepositoryProvider).watchByListType(ListType.productsToBuy);
}

@riverpod
class ProductsToBuyFilterController extends _$ProductsToBuyFilterController {
  @override
  ItemFilterState build() => const ItemFilterState();

  void update(ItemFilterState value) => state = value;
}
