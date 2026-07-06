import 'package:flutter/material.dart';

import '../../../../core/domain/entities/item.dart';
import '../../../../core/presentation/widgets/item_list_tile.dart';
import 'add_edit_grocery_item_sheet.dart';

class GroceryListTile extends StatelessWidget {
  const GroceryListTile({super.key, required this.item});

  final Item item;

  @override
  Widget build(BuildContext context) {
    final subtitleParts = [
      if (item.details.quantity != null)
        '${item.details.quantity}${item.details.unit != null ? ' ${item.details.unit}' : ''}',
      if (item.category != null) item.category!,
    ];

    return ItemListTile(
      item: item,
      subtitleParts: subtitleParts,
      onTap: () => showAddEditGroceryItemSheet(context, existing: item),
    );
  }
}
