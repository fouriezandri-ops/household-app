import 'package:flutter_test/flutter_test.dart';
import 'package:household_app/core/domain/entities/item.dart';
import 'package:household_app/core/domain/entities/list_type.dart';
import 'package:household_app/features/grocery_list/domain/entities/grocery_filter.dart';
import 'package:household_app/features/grocery_list/presentation/providers/grocery_list_providers.dart';

void main() {
  Item item({required String title, bool completed = false, String? category}) {
    return Item(
      id: title,
      listType: ListType.grocery,
      title: title,
      addedBy: 'member-1',
      dateAdded: DateTime(2026),
      completed: completed,
      category: category,
    );
  }

  final items = [
    item(title: 'Milk', category: 'Dairy'),
    item(title: 'Eggs', category: 'Dairy', completed: true),
    item(title: 'Bread', category: 'Bakery'),
  ];

  test('GroceryFilterAll returns every item', () {
    expect(applyGroceryFilter(items, const GroceryFilterAll()), items);
  });

  test('GroceryFilterNotPurchased excludes completed items', () {
    final result = applyGroceryFilter(items, const GroceryFilterNotPurchased());
    expect(result.map((item) => item.title), ['Milk', 'Bread']);
  });

  test('GroceryFilterCategory only returns matching items', () {
    final result = applyGroceryFilter(items, const GroceryFilterCategory('Dairy'));
    expect(result.map((item) => item.title), ['Milk', 'Eggs']);
  });
}
