import 'package:flutter/material.dart';

import '../../../../core/domain/entities/list_type.dart';
import '../../../../core/presentation/widgets/item_list_screen.dart';
import '../widgets/add_edit_grocery_item_sheet.dart';
import '../widgets/grocery_list_tile.dart';

class GroceryListScreen extends StatelessWidget {
  const GroceryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ItemListScreen(
      title: 'Grocery',
      listType: ListType.grocery,
      notCompletedLabel: 'Not purchased',
      tileBuilder: (item) => GroceryListTile(item: item),
      onAddPressed: () => showAddEditGroceryItemSheet(context),
    );
  }
}
