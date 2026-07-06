import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/domain/entities/item.dart';

part 'search_providers.g.dart';

@riverpod
class SearchQueryController extends _$SearchQueryController {
  @override
  String build() => '';

  void setQuery(String query) => state = query;
}

/// Case-insensitive substring match against title, category, and notes.
/// Small dataset (a household's worth of items, not thousands), so
/// filtering client-side is simpler than standing up a search index for
/// what's fundamentally a two-person app.
List<Item> searchItems(List<Item> items, String query) {
  final normalized = query.trim().toLowerCase();
  if (normalized.isEmpty) return const [];

  return items.where((item) {
    return item.title.toLowerCase().contains(normalized) ||
        (item.category?.toLowerCase().contains(normalized) ?? false) ||
        (item.notes?.toLowerCase().contains(normalized) ?? false);
  }).toList();
}
