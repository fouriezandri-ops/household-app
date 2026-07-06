import 'package:flutter/material.dart';

import '../../domain/entities/item.dart';
import '../../domain/entities/item_filter.dart';

/// The "All / Not completed / one chip per category" row used at the top
/// of every list screen. [notCompletedLabel] varies by list ("Not
/// purchased" for grocery, "Not packed" for packing, ...).
class ItemFilterChipRow extends StatelessWidget {
  const ItemFilterChipRow({
    super.key,
    required this.items,
    required this.selected,
    required this.notCompletedLabel,
    required this.onSelected,
  });

  final List<Item> items;
  final ItemFilter selected;
  final String notCompletedLabel;
  final ValueChanged<ItemFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    final categories = items.map((item) => item.category).whereType<String>().toSet().toList()
      ..sort();
    // Bound to a local so `is` checks below promote reliably, rather than
    // depending on instance-field promotion rules.
    final currentFilter = selected;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _Chip(
              label: 'All',
              selected: currentFilter is ItemFilterAll,
              onSelected: () => onSelected(const ItemFilterAll()),
            ),
            const SizedBox(width: 8),
            _Chip(
              label: notCompletedLabel,
              selected: currentFilter is ItemFilterNotCompleted,
              onSelected: () => onSelected(const ItemFilterNotCompleted()),
            ),
            for (final category in categories) ...[
              const SizedBox(width: 8),
              _Chip(
                label: category,
                selected: currentFilter is ItemFilterCategory && currentFilter.category == category,
                onSelected: () => onSelected(ItemFilterCategory(category)),
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
    return ChoiceChip(label: Text(label), selected: selected, onSelected: (_) => onSelected());
  }
}
