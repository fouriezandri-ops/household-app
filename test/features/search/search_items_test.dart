import 'package:flutter_test/flutter_test.dart';
import 'package:household_app/core/domain/entities/item.dart';
import 'package:household_app/core/domain/entities/list_type.dart';
import 'package:household_app/features/search/presentation/providers/search_providers.dart';

void main() {
  Item item({required String title, String? category, String? notes}) {
    return Item(
      id: title,
      listType: ListType.grocery,
      title: title,
      addedBy: 'member-1',
      dateAdded: DateTime(2026),
      category: category,
      notes: notes,
    );
  }

  final items = [
    item(title: 'Milk', category: 'Dairy'),
    item(title: 'Bread', notes: 'Sourdough please'),
    item(title: 'Passport renewal'),
  ];

  test('empty query returns no results', () {
    expect(searchItems(items, ''), isEmpty);
    expect(searchItems(items, '   '), isEmpty);
  });

  test('matches title case-insensitively', () {
    expect(searchItems(items, 'milk').map((item) => item.title), ['Milk']);
    expect(searchItems(items, 'PASS').map((item) => item.title), ['Passport renewal']);
  });

  test('matches category and notes too', () {
    expect(searchItems(items, 'dairy').map((item) => item.title), ['Milk']);
    expect(searchItems(items, 'sourdough').map((item) => item.title), ['Bread']);
  });

  test('no match returns an empty list', () {
    expect(searchItems(items, 'nonexistent'), isEmpty);
  });
}
