import 'package:flutter/material.dart';

import '../../../../core/domain/entities/list_type.dart';
import '../../../../core/presentation/widgets/item_list_screen.dart';
import '../widgets/add_edit_admin_item_sheet.dart';
import '../widgets/admin_todo_tile.dart';

class AdminTodoScreen extends StatelessWidget {
  const AdminTodoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ItemListScreen(
      title: 'Admin To-Do',
      listType: ListType.admin,
      notCompletedLabel: 'Not done',
      tileBuilder: (item) => AdminTodoTile(item: item),
      onAddPressed: () => showAddEditAdminItemSheet(context),
    );
  }
}
