import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/firestore_providers.dart';
import '../widgets/add_edit_admin_item_sheet.dart';
import 'admin_todo_screen.dart';

/// The reserved deep-link target for a single admin item (e.g. from a push
/// notification, milestone 15). Per the navigation design: shows the admin
/// list underneath (for back-navigation continuity) and auto-opens the
/// edit sheet on top once the item loads. If the item no longer exists,
/// this just shows the list — no error state to build for a deep link
/// that can't resolve.
class AdminItemDetailScreen extends ConsumerStatefulWidget {
  const AdminItemDetailScreen({super.key, required this.itemId});

  final String itemId;

  @override
  ConsumerState<AdminItemDetailScreen> createState() => _AdminItemDetailScreenState();
}

class _AdminItemDetailScreenState extends ConsumerState<AdminItemDetailScreen> {
  bool _hasOpenedSheet = false;

  @override
  Widget build(BuildContext context) {
    ref.listen(itemByIdProvider(widget.itemId), (previous, next) {
      final item = next.value;
      if (item != null && !_hasOpenedSheet) {
        _hasOpenedSheet = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) showAddEditAdminItemSheet(context, existing: item);
        });
      }
    });

    return const AdminTodoScreen();
  }
}
