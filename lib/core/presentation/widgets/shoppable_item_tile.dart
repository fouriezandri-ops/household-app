import 'package:flutter/material.dart';

import '../../domain/entities/item.dart';
import 'item_list_tile.dart';

/// Shared row for Products to Buy and Wishlist — same subtitle shape for
/// both; `desiredQuantity` just never appears on a wishlist item.
class ShoppableItemTile extends StatelessWidget {
  const ShoppableItemTile({super.key, required this.item, required this.onTap});

  final Item item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final details = item.details;
    final subtitleParts = [
      if (details.price != null) 'R${details.price!.toStringAsFixed(2)}',
      if (details.store != null) details.store!,
      if (details.desiredQuantity != null && details.desiredQuantity != 1)
        'Qty ${details.desiredQuantity}',
      if (item.category != null) item.category!,
    ];

    return ItemListTile(item: item, subtitleParts: subtitleParts, onTap: onTap);
  }
}
