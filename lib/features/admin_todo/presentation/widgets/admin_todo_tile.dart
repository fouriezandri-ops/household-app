import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/domain/entities/item.dart';
import '../../../../core/presentation/widgets/item_list_tile.dart';
import '../../../household/presentation/providers/current_member_provider.dart';
import 'add_edit_admin_item_sheet.dart';

class AdminTodoTile extends ConsumerWidget {
  const AdminTodoTile({super.key, required this.item});

  final Item item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(householdMembersProvider);
    final assignedToName = membersAsync.maybeWhen(
      data: (members) {
        final assignedTo = item.details.assignedTo;
        if (assignedTo == null) return null;
        final matches = members.where((member) => member.uid == assignedTo);
        return matches.isEmpty ? null : matches.first.displayName;
      },
      orElse: () => null,
    );

    final subtitleParts = [
      if (item.details.dueDate != null) 'Due ${_formatDate(item.details.dueDate!)}',
      if (item.priority != null) '${item.priority!.name} priority',
      if (assignedToName != null) 'Assigned to $assignedToName',
      if (item.category != null) item.category!,
    ];

    return ItemListTile(
      item: item,
      subtitleParts: subtitleParts,
      onTap: () => showAddEditAdminItemSheet(context, existing: item),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
