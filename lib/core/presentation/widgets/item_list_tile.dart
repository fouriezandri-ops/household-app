import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../features/household/presentation/providers/current_member_provider.dart';
import '../../../features/move_between_lists/presentation/widgets/move_item_sheet.dart';
import '../../domain/entities/item.dart';
import '../../providers/firestore_providers.dart';

/// Common row for any list: a completion checkbox (strikethrough + greyed
/// when done, per decision #4), an "added by" chip, swipe-left to reveal
/// **Move** and **Delete** (the latter behind a confirmation dialog), and
/// tap to edit.
///
/// [subtitleParts] are joined with " · "; each list decides what's
/// relevant (grocery: quantity/unit + category; packing: just category).
class ItemListTile extends ConsumerWidget {
  const ItemListTile({
    super.key,
    required this.item,
    required this.onTap,
    this.subtitleParts = const [],
  });

  final Item item;
  final VoidCallback onTap;
  final List<String> subtitleParts;

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete item?'),
        content: Text('"${item.title}" will be removed for both of you.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
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

    return Slidable(
      key: ValueKey(item.id),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.5,
        children: [
          SlidableAction(
            onPressed: (context) => showMoveItemSheet(context, item),
            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
            icon: Icons.swap_horiz,
            label: 'Move',
          ),
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
        onTap: onTap,
      ),
    );
  }
}
