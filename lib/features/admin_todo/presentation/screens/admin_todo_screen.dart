import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/domain/entities/item_filter.dart';
import '../../../../core/presentation/widgets/item_filter_chip_row.dart';
import '../providers/admin_todo_providers.dart';
import '../widgets/add_edit_admin_item_sheet.dart';
import '../widgets/admin_todo_tile.dart';

class AdminTodoScreen extends ConsumerWidget {
  const AdminTodoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(adminItemsProvider);
    final filter = ref.watch(adminFilterControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Admin To-Do')),
      body: itemsAsync.when(
        data: (items) {
          final filtered = applyItemFilter(items, filter);

          return Column(
            children: [
              ItemFilterChipRow(
                items: items,
                selected: filter,
                notCompletedLabel: 'Not done',
                onSelected: (newFilter) =>
                    ref.read(adminFilterControllerProvider.notifier).select(newFilter),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? const Center(child: Text('Nothing here yet'))
                    : ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) => AdminTodoTile(item: filtered[index]),
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Something went wrong: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddEditAdminItemSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
