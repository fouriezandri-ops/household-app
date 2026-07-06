import 'package:flutter/material.dart';

/// Placeholder — built out in the Packing List milestone.
class PackingTripDetailScreen extends StatelessWidget {
  const PackingTripDetailScreen({super.key, required this.tripId});

  final String tripId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Trip: $tripId')),
      body: const Center(child: Text('Coming soon')),
    );
  }
}
