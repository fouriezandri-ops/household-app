import 'package:riverpod/riverpod.dart' show Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/domain/entities/item.dart';
import '../../../../core/domain/entities/item_filter.dart';
import '../../../../core/domain/entities/list_type.dart';
import '../../../../core/providers/firestore_providers.dart';

part 'admin_todo_providers.g.dart';

@riverpod
Stream<List<Item>> adminItems(Ref ref) {
  return ref.watch(itemsRepositoryProvider).watchByListType(ListType.admin);
}

@riverpod
class AdminFilterController extends _$AdminFilterController {
  @override
  ItemFilter build() => const ItemFilterAll();

  void select(ItemFilter filter) => state = filter;
}
