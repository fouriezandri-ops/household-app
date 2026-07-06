import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _lists = [
    (title: 'Grocery', route: '/home/grocery', icon: Icons.local_grocery_store_outlined),
    (title: 'Packing', route: '/home/packing', icon: Icons.luggage_outlined),
    (title: 'Admin To-Do', route: '/home/admin', icon: Icons.checklist_outlined),
    (title: 'Products to Buy', route: '/home/products', icon: Icons.shopping_bag_outlined),
    (title: 'Wishlist', route: '/home/wishlist', icon: Icons.favorite_border),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: _lists
            .map(
              (list) => Card(
                child: ListTile(
                  leading: Icon(list.icon),
                  title: Text(list.title),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(list.route),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
