import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/domain/entities/item.dart';
import '../../../../core/domain/entities/list_type.dart';
import '../../../../core/presentation/list_type_icons.dart';
import '../../../../core/providers/firestore_providers.dart';
import '../../../packing_list/presentation/widgets/trip_picker_sheet.dart';

/// Lists the other four lists as move targets for [item]. Moving into
/// Packing needs a trip, so that target opens the trip picker as a second
/// step; every other target moves immediately. Per decision #5 this is
/// reached from a list row's swipe-left "Move" action (see
/// `lib/core/presentation/widgets/item_list_tile.dart`).
Future<void> showMoveItemSheet(BuildContext context, Item item) {
  return showModalBottomSheet<void>(
    context: context,
    builder: (context) => MoveItemSheet(item: item),
  );
}

class MoveItemSheet extends ConsumerWidget {
  const MoveItemSheet({super.key, required this.item});

  final Item item;

  Future<void> _moveTo(BuildContext context, WidgetRef ref, ListType target) async {
    if (target == ListType.packing) {
      final tripId = await showTripPickerSheet(context);
      if (tripId == null || !context.mounted) return;
      await ref
          .read(itemsRepositoryProvider)
          .moveToList(
            item.id,
            newListType: target,
            newDetails: ItemDetails(tripId: tripId),
            newPriority: item.priorityForListType(target),
          );
    } else {
      await ref
          .read(itemsRepositoryProvider)
          .moveToList(
            item.id,
            newListType: target,
            newDetails: item.details.filterForListType(target),
            newPriority: item.priorityForListType(target),
          );
    }
    if (context.mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final targets = ListType.values.where((listType) => listType != item.listType).toList();

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Move "${item.title}" to…',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          for (final target in targets)
            ListTile(
              leading: Icon(target.icon),
              title: Text(target.displayName),
              onTap: () => _moveTo(context, ref, target),
            ),
        ],
      ),
    );
  }
}
