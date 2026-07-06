import 'package:flutter/material.dart';

import '../../../../core/domain/entities/item.dart';
import '../../../../core/domain/entities/list_type.dart';
import '../../../../core/presentation/widgets/item_list_tile.dart';
import '../../../admin_todo/presentation/widgets/add_edit_admin_item_sheet.dart';
import '../../../grocery_list/presentation/widgets/add_edit_grocery_item_sheet.dart';
import '../../../packing_list/presentation/widgets/add_edit_packing_item_sheet.dart';
import '../../../products_to_buy/presentation/widgets/add_edit_product_sheet.dart';
import '../../../wishlist/presentation/widgets/add_edit_wishlist_item_sheet.dart';

/// A search result can be from any list, so unlike each list's own tile
/// (which knows its type at compile time) this dispatches to the right
/// add/edit sheet at runtime based on `item.listType`.
class SearchResultTile extends StatelessWidget {
  const SearchResultTile({super.key, required this.item});

  final Item item;

  void _openEditSheet(BuildContext context) {
    switch (item.listType) {
      case ListType.grocery:
        showAddEditGroceryItemSheet(context, existing: item);
      case ListType.packing:
        final tripId = item.details.tripId;
        if (tripId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("This item is missing its trip and can't be opened.")),
          );
          return;
        }
        showAddEditPackingItemSheet(context, tripId: tripId, existing: item);
      case ListType.admin:
        showAddEditAdminItemSheet(context, existing: item);
      case ListType.productsToBuy:
        showAddEditProductSheet(context, existing: item);
      case ListType.wishlist:
        showAddEditWishlistItemSheet(context, existing: item);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ItemListTile(
      item: item,
      subtitleParts: [item.listType.displayName, if (item.category != null) item.category!],
      onTap: () => _openEditSheet(context),
    );
  }
}
