import 'package:flutter_test/flutter_test.dart';
import 'package:household_app/core/domain/entities/item.dart';
import 'package:household_app/core/domain/entities/item_filter.dart';
import 'package:household_app/core/domain/entities/list_type.dart';

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
    item(title: 'Cheese', category: 'Dairy'),
  ];

  test('the empty (default) filter is "All" and returns every item', () {
    const filter = ItemFilterState();
    expect(filter.isEmpty, isTrue);
    expect(applyItemFilter(items, filter), items);
  });

  test('toggling notCompletedOnly excludes completed items', () {
    final filter = const ItemFilterState().toggleNotCompletedOnly();
    final result = applyItemFilter(items, filter);
    expect(result.map((item) => item.title), ['Milk', 'Bread', 'Cheese']);
  });

  test('toggling a category returns only matching items', () {
    final filter = const ItemFilterState().toggleCategory('Dairy');
    final result = applyItemFilter(items, filter);
    expect(result.map((item) => item.title), ['Milk', 'Eggs', 'Cheese']);
  });

  test('categories combine with OR — selecting two categories returns items in either', () {
    final filter = const ItemFilterState().toggleCategory('Dairy').toggleCategory('Bakery');
    final result = applyItemFilter(items, filter);
    expect(result, items); // every item is Dairy or Bakery here
  });

  test('notCompletedOnly and a category combine with AND', () {
    final filter = const ItemFilterState().toggleNotCompletedOnly().toggleCategory('Dairy');
    final result = applyItemFilter(items, filter);
    expect(result.map((item) => item.title), ['Milk', 'Cheese']);
  });

  test('toggling a category twice clears it', () {
    final filter = const ItemFilterState().toggleCategory('Dairy').toggleCategory('Dairy');
    expect(filter.categories, isEmpty);
    expect(filter.isEmpty, isTrue);
  });

  test('clear() resets both dimensions', () {
    final filter = const ItemFilterState().toggleNotCompletedOnly().toggleCategory('Dairy');
    expect(filter.clear().isEmpty, isTrue);
  });
}
