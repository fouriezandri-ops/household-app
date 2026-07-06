import 'item.dart';

/// Which subset of a list is currently shown — combinable, per milestone
/// 14: an optional "not completed" toggle AND any number of selected
/// categories (categories are OR'd together; the two dimensions are
/// AND'd). Shared across all five lists via one family controller,
/// `ListFilterController` (`lib/core/providers/list_filter_providers.dart`),
/// keyed by `ListType`.
class ItemFilterState {
  const ItemFilterState({this.notCompletedOnly = false, this.categories = const {}});

  final bool notCompletedOnly;
  final Set<String> categories;

  /// True when no filter is active — i.e. "All".
  bool get isEmpty => !notCompletedOnly && categories.isEmpty;

  ItemFilterState clear() => const ItemFilterState();

  ItemFilterState toggleNotCompletedOnly() {
    return ItemFilterState(notCompletedOnly: !notCompletedOnly, categories: categories);
  }

  ItemFilterState toggleCategory(String category) {
    final updated = Set<String>.of(categories);
    if (!updated.remove(category)) updated.add(category);
    return ItemFilterState(notCompletedOnly: notCompletedOnly, categories: updated);
  }
}

List<Item> applyItemFilter(List<Item> items, ItemFilterState filter) {
  return items.where((item) {
    if (filter.notCompletedOnly && item.completed) return false;
    if (filter.categories.isNotEmpty && !filter.categories.contains(item.category)) return false;
    return true;
  }).toList();
}
