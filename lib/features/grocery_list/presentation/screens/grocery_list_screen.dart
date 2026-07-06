import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/grocery_filter.dart';
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
          final categories = items
              .map((item) => item.category)
              .whereType<String>()
              .toSet()
              .toList()
            ..sort();
          final filtered = applyGroceryFilter(items, filter);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChip(
                        label: 'All',
                        selected: filter is GroceryFilterAll,
                        onSelected: () => ref
                            .read(groceryFilterControllerProvider.notifier)
                            .select(const GroceryFilterAll()),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Not purchased',
                        selected: filter is GroceryFilterNotPurchased,
                        onSelected: () => ref
                            .read(groceryFilterControllerProvider.notifier)
                            .select(const GroceryFilterNotPurchased()),
                      ),
                      for (final category in categories) ...[
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: category,
                          selected: filter is GroceryFilterCategory && filter.category == category,
                          onSelected: () => ref
                              .read(groceryFilterControllerProvider.notifier)
                              .select(GroceryFilterCategory(category)),
                        ),
                      ],
                    ],
                  ),
                ),
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

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.selected, required this.onSelected});

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(label: Text(label), selected: selected, onSelected: (_) => onSelected());
  }
}
