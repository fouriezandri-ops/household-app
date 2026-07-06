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
  ];

  test('ItemFilterAll returns every item', () {
    expect(applyItemFilter(items, const ItemFilterAll()), items);
  });

  test('ItemFilterNotCompleted excludes completed items', () {
    final result = applyItemFilter(items, const ItemFilterNotCompleted());
    expect(result.map((item) => item.title), ['Milk', 'Bread']);
  });

  test('ItemFilterCategory only returns matching items', () {
    final result = applyItemFilter(items, const ItemFilterCategory('Dairy'));
    expect(result.map((item) => item.title), ['Milk', 'Eggs']);
  });
}
