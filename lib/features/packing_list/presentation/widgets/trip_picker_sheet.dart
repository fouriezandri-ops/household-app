import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/packing_list_providers.dart';

/// Picks an existing trip, returning its ID (or null if the sheet was
/// dismissed without a choice). Used by the packing screen's own
/// trip-picker and by moving an item into Packing (which needs a trip to
/// put it in).
Future<String?> showTripPickerSheet(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    builder: (context) => const _TripPickerSheet(),
  );
}

class _TripPickerSheet extends ConsumerWidget {
  const _TripPickerSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripsAsync = ref.watch(tripsProvider);

    return SafeArea(
      child: tripsAsync.when(
        data: (trips) => trips.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(24),
                child: Text('No trips yet — create one from the Packing tab first.'),
              )
            : ListView(
                shrinkWrap: true,
                children: [
                  for (final trip in trips)
                    ListTile(
                      leading: const Icon(Icons.luggage_outlined),
                      title: Text(trip.name),
                      onTap: () => Navigator.of(context).pop(trip.id),
                    ),
                ],
              ),
        loading: () => const Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (error, stackTrace) => Padding(
          padding: const EdgeInsets.all(24),
          child: Text('Something went wrong: $error'),
        ),
      ),
    );
  }
}
