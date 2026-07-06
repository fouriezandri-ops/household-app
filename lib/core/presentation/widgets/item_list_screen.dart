import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/item.dart';
import '../../domain/entities/item_filter.dart';
import '../../domain/entities/list_type.dart';
import '../../providers/firestore_providers.dart';
import '../../providers/list_filter_providers.dart';
import 'item_filter_chip_row.dart';

/// Shared screen for the four lists whose items are scoped by `listType`
/// alone — Grocery, Admin, Products to Buy, Wishlist. Packing isn't part
/// of this: it's scoped by trip instead, and needs trip-specific chrome
/// (the trip name in the app bar, an edit-trip action), so it keeps its
/// own `PackingTripDetailScreen`.
class ItemListScreen extends ConsumerWidget {
  const ItemListScreen({
    super.key,
    required this.title,
    required this.listType,
    required this.notCompletedLabel,
    required this.tileBuilder,
    required this.onAddPressed,
  });

  final String title;
  final ListType listType;
  final String notCompletedLabel;
  final Widget Function(Item item) tileBuilder;
  final VoidCallback onAddPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(itemsByListTypeProvider(listType));
    final filter = ref.watch(listFilterControllerProvider(listType));

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: itemsAsync.when(
        data: (items) {
          final filtered = applyItemFilter(items, filter);

          return Column(
            children: [
              ItemFilterChipRow(
                items: items,
                selected: filter,
                notCompletedLabel: notCompletedLabel,
                onChanged: (newFilter) =>
                    ref.read(listFilterControllerProvider(listType).notifier).update(newFilter),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? const Center(child: Text('Nothing here yet'))
                    : ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) => tileBuilder(filtered[index]),
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Something went wrong: $error')),
      ),
      floatingActionButton: FloatingActionButton(onPressed: onAddPressed, child: const Icon(Icons.add)),
    );
  }
}
