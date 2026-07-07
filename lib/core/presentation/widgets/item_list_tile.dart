import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../features/household/presentation/providers/current_member_provider.dart';
import '../../../features/move_between_lists/presentation/widgets/move_item_sheet.dart';
import '../../domain/entities/item.dart';
import '../../providers/firestore_providers.dart';

enum _ItemAction { move, delete }

/// Common row for any list: a completion checkbox (strikethrough + greyed
/// when done, per decision #4), an "added by" chip, tap to edit, and
/// **Move**/**Delete** (the latter behind a confirmation dialog) reachable
/// two ways per decision #5 — swipe-left, or long-press for a context menu.
/// The long-press alternative exists because swipe-left can be unreliable
/// on real devices (e.g. it can compete with a phone's edge-swipe-back
/// gesture), and decision #5 always specified both.
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

  Future<void> _showContextMenu(BuildContext context, WidgetRef ref) async {
    final action = await showModalBottomSheet<_ItemAction>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.swap_horiz),
              title: const Text('Move'),
              onTap: () => Navigator.of(context).pop(_ItemAction.move),
            ),
            ListTile(
              leading: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
              title: Text('Delete', style: TextStyle(color: Theme.of(context).colorScheme.error)),
              onTap: () => Navigator.of(context).pop(_ItemAction.delete),
            ),
          ],
        ),
      ),
    );
    // The context menu sheet has already closed by the time a choice comes
    // back, so this context is safe to reuse for the next sheet/dialog —
    // but only after confirming it's still mounted (see the QuickAddSheet
    // fix, milestone 16, for why that check matters here).
    if (!context.mounted || action == null) return;
    switch (action) {
      case _ItemAction.move:
        showMoveItemSheet(context, item);
      case _ItemAction.delete:
        _confirmDelete(context, ref);
    }
  }

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
        onLongPress: () => _showContextMenu(context, ref),
      ),
    );
  }
}
