import 'package:flutter/material.dart';

import '../../../../core/domain/entities/list_type.dart';
import '../../../../core/presentation/widgets/item_list_screen.dart';
import '../widgets/add_edit_wishlist_item_sheet.dart';
import '../widgets/wishlist_tile.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ItemListScreen(
      title: 'Wishlist',
      listType: ListType.wishlist,
      notCompletedLabel: 'Not received',
      tileBuilder: (item) => WishlistTile(item: item),
      onAddPressed: () => showAddEditWishlistItemSheet(context),
    );
  }
}
