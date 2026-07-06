import 'package:flutter_test/flutter_test.dart';
import 'package:household_app/core/domain/entities/item.dart';
import 'package:household_app/core/domain/entities/list_type.dart';
import 'package:household_app/features/home/domain/list_stats.dart';

void main() {
  Item item({
    required ListType listType,
    required String title,
    bool completed = false,
    required DateTime dateAdded,
  }) {
    return Item(
      id: title,
      listType: listType,
      title: title,
      addedBy: 'member-1',
      dateAdded: dateAdded,
      completed: completed,
    );
  }

  test('an empty list gets zeroed stats and no recent activity', () {
    final stats = computeListStats(const []);
    for (final listType in ListType.values) {
      expect(stats[listType]!.total, 0);
      expect(stats[listType]!.completed, 0);
      expect(stats[listType]!.mostRecentTitle, isNull);
    }
  });

  test('counts total and completed per list, and finds the most recent title', () {
    final items = [
      item(
        listType: ListType.grocery,
        title: 'Milk',
        dateAdded: DateTime(2026, 1, 1),
      ),
      item(
        listType: ListType.grocery,
        title: 'Eggs',
        completed: true,
        dateAdded: DateTime(2026, 6, 1),
      ),
      item(
        listType: ListType.wishlist,
        title: 'Espresso machine',
        dateAdded: DateTime(2026, 3, 1),
      ),
    ];

    final stats = computeListStats(items);

    expect(stats[ListType.grocery]!.total, 2);
    expect(stats[ListType.grocery]!.completed, 1);
    expect(stats[ListType.grocery]!.mostRecentTitle, 'Eggs');

    expect(stats[ListType.wishlist]!.total, 1);
    expect(stats[ListType.wishlist]!.completed, 0);
    expect(stats[ListType.wishlist]!.mostRecentTitle, 'Espresso machine');

    expect(stats[ListType.admin]!.total, 0);
  });
}
