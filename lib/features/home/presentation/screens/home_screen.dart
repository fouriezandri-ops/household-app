import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/domain/entities/list_type.dart';
import '../../../../core/presentation/list_type_icons.dart';
import '../../../../core/presentation/widgets/async_error_view.dart';
import '../../../../core/providers/firestore_providers.dart';
import '../../domain/list_stats.dart';
import '../widgets/quick_add_sheet.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const _routes = {
    ListType.grocery: '/home/grocery',
    ListType.packing: '/home/packing',
    ListType.admin: '/home/admin',
    ListType.productsToBuy: '/home/products',
    ListType.wishlist: '/home/wishlist',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(allItemsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: itemsAsync.when(
        data: (items) {
          final stats = computeListStats(items);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (final listType in ListType.values)
                _HomeListCard(
                  listType: listType,
                  stats: stats[listType]!,
                  onTap: () => context.push(_routes[listType]!),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => AsyncErrorView(error: error),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showQuickAddSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _HomeListCard extends StatelessWidget {
  const _HomeListCard({required this.listType, required this.stats, required this.onTap});

  final ListType listType;
  final ListStats stats;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final subtitleParts = [
      '${stats.total} ${stats.total == 1 ? 'item' : 'items'}',
      '${stats.completed} completed',
      if (stats.mostRecentTitle != null) 'Latest: ${stats.mostRecentTitle}',
    ];

    return Card(
      child: ListTile(
        leading: Icon(listType.icon),
        title: Text(listType.displayName),
        subtitle: Text(subtitleParts.join(' · ')),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
