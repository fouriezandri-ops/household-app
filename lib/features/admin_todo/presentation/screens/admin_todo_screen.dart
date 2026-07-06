import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Placeholder — built out in the Admin List milestone. Links to a sample
/// item to exercise the reserved `/home/admin/:itemId` deep-link route
/// ahead of FCM (milestone 15).
class AdminTodoScreen extends StatelessWidget {
  const AdminTodoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin To-Do')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => context.push('/home/admin/sample-item'),
          child: const Text('Open sample item'),
        ),
      ),
    );
  }
}
