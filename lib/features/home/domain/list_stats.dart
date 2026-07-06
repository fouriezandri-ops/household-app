import '../../../core/domain/entities/item.dart';
import '../../../core/domain/entities/list_type.dart';

/// Per-list summary for a Home screen card, per the original wireframe
/// ("item count + completed count + recent activity").
class ListStats {
  const ListStats({required this.total, required this.completed, this.mostRecentTitle});

  final int total;
  final int completed;
  final String? mostRecentTitle;
}

/// Buckets [items] by list type and summarizes each — a pure function so
/// it's testable without touching Firestore.
Map<ListType, ListStats> computeListStats(List<Item> items) {
  return {
    for (final listType in ListType.values)
      listType: _statsFor(items.where((item) => item.listType == listType).toList()),
  };
}

ListStats _statsFor(List<Item> items) {
  if (items.isEmpty) return const ListStats(total: 0, completed: 0);

  final mostRecent = items.reduce(
    (a, b) => b.dateAdded.isAfter(a.dateAdded) ? b : a,
  );

  return ListStats(
    total: items.length,
    completed: items.where((item) => item.completed).length,
    mostRecentTitle: mostRecent.title,
  );
}
