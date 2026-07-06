import 'package:flutter/material.dart';

import '../../../../core/domain/entities/item.dart';
import '../../../../core/domain/entities/list_type.dart';
import '../../../../core/presentation/widgets/shoppable_item_sheet.dart';

/// Wishlist has no `desiredQuantity` — that's Products to Buy only.
Future<void> showAddEditWishlistItemSheet(BuildContext context, {Item? existing}) {
  return showAddEditShoppableItemSheet(
    context,
    listType: ListType.wishlist,
    itemTypeLabel: 'wishlist item',
    fieldLabel: 'Item',
    showDesiredQuantity: false,
    existing: existing,
  );
}
