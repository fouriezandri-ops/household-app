/// Which subset of the grocery list is currently shown. A single active
/// filter (not combinable) — matches the wireframe's filter-chip row.
/// Combining filters (e.g. "not purchased" + a category) is scoped to the
/// dedicated Filters milestone.
sealed class GroceryFilter {
  const GroceryFilter();
}

class GroceryFilterAll extends GroceryFilter {
  const GroceryFilterAll();
}

class GroceryFilterNotPurchased extends GroceryFilter {
  const GroceryFilterNotPurchased();
}

class GroceryFilterCategory extends GroceryFilter {
  const GroceryFilterCategory(this.category);

  final String category;
}
