import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/entities/item_filter.dart';
import '../domain/entities/list_type.dart';

part 'list_filter_providers.g.dart';

/// One filter-state notifier shared by every list screen, keyed by
/// [ListType] — replaces five otherwise byte-for-byte identical
/// `XFilterController` classes (grocery/packing/admin/products/wishlist)
/// that differed only in their generated name.
@riverpod
class ListFilterController extends _$ListFilterController {
  @override
  ItemFilterState build(ListType listType) => const ItemFilterState();

  void update(ItemFilterState value) => state = value;
}
