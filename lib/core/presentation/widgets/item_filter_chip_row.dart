import 'package:flutter/material.dart';

import '../../domain/entities/item.dart';
import '../../domain/entities/item_filter.dart';

/// The "All / Not completed / one chip per category" row used at the top
/// of every list screen. [notCompletedLabel] varies by list ("Not
/// purchased" for grocery, "Not packed" for packing, ...). "Not completed"
/// and any number of categories are independently toggleable and combine
/// (AND'd) — "All" is a quick reset, not a separate stored state.
class ItemFilterChipRow extends StatelessWidget {
  const ItemFilterChipRow({
    super.key,
    required this.items,
    required this.selected,
    required this.notCompletedLabel,
    required this.onChanged,
  });

  final List<Item> items;
  final ItemFilterState selected;
  final String notCompletedLabel;
  final ValueChanged<ItemFilterState> onChanged;

  @override
  Widget build(BuildContext context) {
    final categories = items.map((item) => item.category).whereType<String>().toSet().toList()
      ..sort();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _Chip(
              label: 'All',
              selected: selected.isEmpty,
              onSelected: () => onChanged(selected.clear()),
            ),
            const SizedBox(width: 8),
            _Chip(
              label: notCompletedLabel,
              selected: selected.notCompletedOnly,
              onSelected: () => onChanged(selected.toggleNotCompletedOnly()),
            ),
            for (final category in categories) ...[
              const SizedBox(width: 8),
              _Chip(
                label: category,
                selected: selected.categories.contains(category),
                onSelected: () => onChanged(selected.toggleCategory(category)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.selected, required this.onSelected});

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return FilterChip(label: Text(label), selected: selected, onSelected: (_) => onSelected());
  }
}
