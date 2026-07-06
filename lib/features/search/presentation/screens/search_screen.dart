import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/widgets/async_error_view.dart';
import '../../../../core/providers/firestore_providers.dart';
import '../providers/search_providers.dart';
import '../widgets/search_result_tile.dart';

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(searchQueryControllerProvider);
    final itemsAsync = ref.watch(allItemsProvider);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: false,
          decoration: const InputDecoration(
            hintText: 'Search all lists',
            border: InputBorder.none,
          ),
          onChanged: (value) => ref.read(searchQueryControllerProvider.notifier).setQuery(value),
        ),
      ),
      body: query.trim().isEmpty
          ? const Center(child: Text('Type to search across all your lists'))
          : itemsAsync.when(
              data: (items) {
                final results = searchItems(items, query);
                return results.isEmpty
                    ? const Center(child: Text('No matches'))
                    : ListView.builder(
                        itemCount: results.length,
                        itemBuilder: (context, index) => SearchResultTile(item: results[index]),
                      );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => AsyncErrorView(error: error),
            ),
    );
  }
}
