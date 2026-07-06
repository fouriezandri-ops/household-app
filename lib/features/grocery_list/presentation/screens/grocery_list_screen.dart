import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/domain/entities/item_filter.dart';
import '../../../../core/presentation/widgets/item_filter_chip_row.dart';
import '../providers/grocery_list_providers.dart';
import '../widgets/add_edit_grocery_item_sheet.dart';
import '../widgets/grocery_list_tile.dart';

class GroceryListScreen extends ConsumerWidget {
  const GroceryListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(groceryItemsProvider);
    final filter = ref.watch(groceryFilterControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Grocery')),
      body: itemsAsync.when(
        data: (items) {
          final filtered = applyItemFilter(items, filter);

          return Column(
            children: [
              ItemFilterChipRow(
                items: items,
                selected: filter,
                notCompletedLabel: 'Not purchased',
                onChanged: (newFilter) =>
                    ref.read(groceryFilterControllerProvider.notifier).update(newFilter),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? const Center(child: Text('Nothing here yet'))
                    : ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) => GroceryListTile(item: filtered[index]),
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Something went wrong: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddEditGroceryItemSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
