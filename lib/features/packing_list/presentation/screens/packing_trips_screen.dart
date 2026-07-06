import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Trip picker shown at `/home/packing`. Full trip CRUD (backed by
/// `/households/{householdId}/trips`) lands in the Packing List milestone —
/// this establishes the route shape and the tap-through to a trip's items.
class PackingTripsScreen extends StatelessWidget {
  const PackingTripsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Packing')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => context.push('/home/packing/sample-trip'),
          child: const Text('Open sample trip'),
        ),
      ),
    );
  }
}
