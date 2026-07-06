import 'package:flutter/material.dart';

/// Reserved deep-link target for a single admin item (e.g. from a push
/// notification, milestone 15). Placeholder until the Admin List milestone
/// wires in the real edit bottom sheet.
class AdminItemDetailScreen extends StatelessWidget {
  const AdminItemDetailScreen({super.key, required this.itemId});

  final String itemId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Item: $itemId')),
      body: const Center(child: Text('Coming soon')),
    );
  }
}
