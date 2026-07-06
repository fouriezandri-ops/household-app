import 'item.dart';

/// Which subset of a list is currently shown. A single active filter (not
/// combinable) — matches the wireframe's filter-chip row for each list.
/// Combining filters (e.g. "not completed" + a category) is scoped to the
/// dedicated Filters milestone. Shared across all five lists — each has its
/// own `XFilterController` (see `grocery_list_providers.dart` for the
/// pattern), but the filter values and the logic to apply them are common.
sealed class ItemFilter {
  const ItemFilter();
}

class ItemFilterAll extends ItemFilter {
  const ItemFilterAll();
}

class ItemFilterNotCompleted extends ItemFilter {
  const ItemFilterNotCompleted();
}

class ItemFilterCategory extends ItemFilter {
  const ItemFilterCategory(this.category);

  final String category;
}

List<Item> applyItemFilter(List<Item> items, ItemFilter filter) {
  return switch (filter) {
    ItemFilterAll() => items,
    ItemFilterNotCompleted() => items.where((item) => !item.completed).toList(),
    ItemFilterCategory(:final category) =>
      items.where((item) => item.category == category).toList(),
  };
}
