import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/packing_list_providers.dart';
import '../widgets/add_edit_trip_sheet.dart';

/// Trip picker at `/home/packing`. Tapping a trip opens its packing items
/// at `/home/packing/:tripId`.
class PackingTripsScreen extends ConsumerWidget {
  const PackingTripsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripsAsync = ref.watch(tripsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Packing')),
      body: tripsAsync.when(
        data: (trips) => trips.isEmpty
            ? const Center(child: Text('No trips yet — add one to start packing'))
            : ListView.builder(
                itemCount: trips.length,
                itemBuilder: (context, index) {
                  final trip = trips[index];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.luggage_outlined),
                      title: Text(trip.name),
                      subtitle: trip.destination == null ? null : Text(trip.destination!),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/home/packing/${trip.id}'),
                    ),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Something went wrong: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddEditTripSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
