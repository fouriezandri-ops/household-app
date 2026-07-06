import 'package:flutter/material.dart';

import '../../../../core/domain/entities/item.dart';
import '../../../../core/presentation/widgets/item_list_tile.dart';
import 'add_edit_product_sheet.dart';

class ProductTile extends StatelessWidget {
  const ProductTile({super.key, required this.item});

  final Item item;

  @override
  Widget build(BuildContext context) {
    final details = item.details;
    final subtitleParts = [
      if (details.price != null) '\$${details.price!.toStringAsFixed(2)}',
      if (details.store != null) details.store!,
      if (details.desiredQuantity != null && details.desiredQuantity != 1)
        'Qty ${details.desiredQuantity}',
      if (item.category != null) item.category!,
    ];

    return ItemListTile(
      item: item,
      subtitleParts: subtitleParts,
      onTap: () => showAddEditProductSheet(context, existing: item),
    );
  }
}
