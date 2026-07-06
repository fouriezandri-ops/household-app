import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/domain/entities/item.dart';
import '../../../../core/domain/entities/item_filter.dart';
import '../../../../core/presentation/widgets/item_filter_chip_row.dart';
import '../../../../core/presentation/widgets/item_list_tile.dart';
import '../providers/packing_list_providers.dart';
import '../widgets/add_edit_packing_item_sheet.dart';
import '../widgets/add_edit_trip_sheet.dart';

class PackingTripDetailScreen extends ConsumerWidget {
  const PackingTripDetailScreen({super.key, required this.tripId});

  final String tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripAsync = ref.watch(tripProvider(tripId));
    final itemsAsync = ref.watch(packingItemsProvider(tripId));
    final filter = ref.watch(packingFilterControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(tripAsync.value?.name ?? 'Packing'),
        actions: [
          if (tripAsync.value != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => showAddEditTripSheet(context, existing: tripAsync.value),
            ),
        ],
      ),
      body: itemsAsync.when(
        data: (items) {
          final filtered = applyItemFilter(items, filter);

          return Column(
            children: [
              ItemFilterChipRow(
                items: items,
                selected: filter,
                notCompletedLabel: 'Not packed',
                onChanged: (newFilter) =>
                    ref.read(packingFilterControllerProvider.notifier).update(newFilter),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? const Center(child: Text('Nothing packed yet'))
                    : ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) => _PackingItemTile(item: filtered[index]),
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Something went wrong: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddEditPackingItemSheet(context, tripId: tripId),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _PackingItemTile extends StatelessWidget {
  const _PackingItemTile({required this.item});

  final Item item;

  @override
  Widget build(BuildContext context) {
    return ItemListTile(
      item: item,
      subtitleParts: [if (item.category != null) item.category!],
      onTap: () => showAddEditPackingItemSheet(
        context,
        tripId: item.details.tripId!,
        existing: item,
      ),
    );
  }
}
