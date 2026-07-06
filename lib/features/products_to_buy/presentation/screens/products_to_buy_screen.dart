import 'package:flutter/material.dart';

import '../../../../core/domain/entities/list_type.dart';
import '../../../../core/presentation/widgets/item_list_screen.dart';
import '../widgets/add_edit_product_sheet.dart';
import '../widgets/product_tile.dart';

class ProductsToBuyScreen extends StatelessWidget {
  const ProductsToBuyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ItemListScreen(
      title: 'Products to Buy',
      listType: ListType.productsToBuy,
      notCompletedLabel: 'Not bought',
      tileBuilder: (item) => ProductTile(item: item),
      onAddPressed: () => showAddEditProductSheet(context),
    );
  }
}
