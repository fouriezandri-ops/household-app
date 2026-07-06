import 'package:flutter/material.dart';

import '../../../../core/domain/entities/item.dart';
import '../../../../core/presentation/widgets/shoppable_item_tile.dart';
import 'add_edit_wishlist_item_sheet.dart';

class WishlistTile extends StatelessWidget {
  const WishlistTile({super.key, required this.item});

  final Item item;

  @override
  Widget build(BuildContext context) {
    return ShoppableItemTile(
      item: item,
      onTap: () => showAddEditWishlistItemSheet(context, existing: item),
    );
  }
}
