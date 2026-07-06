import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/domain/entities/item_filter.dart';
import '../../../../core/presentation/widgets/item_filter_chip_row.dart';
import '../providers/wishlist_providers.dart';
import '../widgets/add_edit_wishlist_item_sheet.dart';
import '../widgets/wishlist_tile.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(wishlistItemsProvider);
    final filter = ref.watch(wishlistFilterControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Wishlist')),
      body: itemsAsync.when(
        data: (items) {
          final filtered = applyItemFilter(items, filter);

          return Column(
            children: [
              ItemFilterChipRow(
                items: items,
                selected: filter,
                notCompletedLabel: 'Not received',
                onSelected: (newFilter) =>
                    ref.read(wishlistFilterControllerProvider.notifier).select(newFilter),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? const Center(child: Text('Nothing here yet'))
                    : ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) => WishlistTile(item: filtered[index]),
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Something went wrong: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddEditWishlistItemSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
