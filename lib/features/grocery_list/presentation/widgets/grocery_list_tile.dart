import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../../core/domain/entities/item.dart';
import '../../../../core/providers/firestore_providers.dart';
import '../../../household/presentation/providers/current_member_provider.dart';
import 'add_edit_grocery_item_sheet.dart';

class GroceryListTile extends ConsumerWidget {
  const GroceryListTile({super.key, required this.item});

  final Item item;

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete item?'),
        content: Text('"${item.title}" will be removed for both of you.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      await ref.read(itemsRepositoryProvider).delete(item.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(householdMembersProvider);
    final addedByName = membersAsync.maybeWhen(
      data: (members) {
        final matches = members.where((member) => member.uid == item.addedBy);
        return matches.isEmpty ? null : matches.first.displayName;
      },
      orElse: () => null,
    );

    final subtitleParts = [
      if (item.details.quantity != null)
        '${item.details.quantity}${item.details.unit != null ? ' ${item.details.unit}' : ''}',
      if (item.category != null) item.category!,
    ];

    return Slidable(
      key: ValueKey(item.id),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: (context) => _confirmDelete(context, ref),
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Theme.of(context).colorScheme.onError,
            icon: Icons.delete_outline,
            label: 'Delete',
          ),
        ],
      ),
      child: ListTile(
        leading: Checkbox(
          value: item.completed,
          onChanged: (value) => ref.read(itemsRepositoryProvider).updateFields(item.id, {
            'completed': value ?? false,
            'dateCompleted': (value ?? false) ? Timestamp.fromDate(DateTime.now()) : null,
          }),
        ),
        title: Text(
          item.title,
          style: item.completed
              ? const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey)
              : null,
        ),
        subtitle: subtitleParts.isEmpty ? null : Text(subtitleParts.join(' · ')),
        trailing: addedByName == null ? null : Chip(label: Text(addedByName)),
        onTap: () => showAddEditGroceryItemSheet(context, existing: item),
      ),
    );
  }
}
