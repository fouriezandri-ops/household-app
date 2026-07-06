import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/domain/entities/item_filter.dart';
import '../../../../core/presentation/widgets/item_filter_chip_row.dart';
import '../providers/products_to_buy_providers.dart';
import '../widgets/add_edit_product_sheet.dart';
import '../widgets/product_tile.dart';

class ProductsToBuyScreen extends ConsumerWidget {
  const ProductsToBuyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(productsToBuyItemsProvider);
    final filter = ref.watch(productsToBuyFilterControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Products to Buy')),
      body: itemsAsync.when(
        data: (items) {
          final filtered = applyItemFilter(items, filter);

          return Column(
            children: [
              ItemFilterChipRow(
                items: items,
                selected: filter,
                notCompletedLabel: 'Not bought',
                onChanged: (newFilter) =>
                    ref.read(productsToBuyFilterControllerProvider.notifier).update(newFilter),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? const Center(child: Text('Nothing here yet'))
                    : ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) => ProductTile(item: filtered[index]),
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Something went wrong: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddEditProductSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
