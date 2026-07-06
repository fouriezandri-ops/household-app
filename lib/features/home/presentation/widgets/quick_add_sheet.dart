import 'package:flutter/material.dart';

import '../../../../core/domain/entities/list_type.dart';
import '../../../../core/presentation/list_type_icons.dart';
import '../../../admin_todo/presentation/widgets/add_edit_admin_item_sheet.dart';
import '../../../grocery_list/presentation/widgets/add_edit_grocery_item_sheet.dart';
import '../../../packing_list/presentation/widgets/add_edit_packing_item_sheet.dart';
import '../../../packing_list/presentation/widgets/trip_picker_sheet.dart';
import '../../../products_to_buy/presentation/widgets/add_edit_product_sheet.dart';
import '../../../wishlist/presentation/widgets/add_edit_wishlist_item_sheet.dart';

/// Home's FAB: pick a list, then add straight to it without leaving Home.
/// The chooser only returns which list was picked — dispatching happens
/// here, against the *caller's* context, once the chooser has fully
/// closed (reusing a context mid-pop, from inside the chooser itself,
/// would reach into a widget that's being torn down).
Future<void> showQuickAddSheet(BuildContext context) async {
  final listType = await showModalBottomSheet<ListType>(
    context: context,
    builder: (context) => const QuickAddSheet(),
  );
  if (listType == null || !context.mounted) return;

  switch (listType) {
    case ListType.grocery:
      await showAddEditGroceryItemSheet(context);
    case ListType.packing:
      final tripId = await showTripPickerSheet(context);
      if (tripId == null || !context.mounted) return;
      await showAddEditPackingItemSheet(context, tripId: tripId);
    case ListType.admin:
      await showAddEditAdminItemSheet(context);
    case ListType.productsToBuy:
      await showAddEditProductSheet(context);
    case ListType.wishlist:
      await showAddEditWishlistItemSheet(context);
  }
}

class QuickAddSheet extends StatelessWidget {
  const QuickAddSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Add to…', style: Theme.of(context).textTheme.titleMedium),
          ),
          for (final listType in ListType.values)
            ListTile(
              leading: Icon(listType.icon),
              title: Text(listType.displayName),
              onTap: () => Navigator.of(context).pop(listType),
            ),
        ],
      ),
    );
  }
}
