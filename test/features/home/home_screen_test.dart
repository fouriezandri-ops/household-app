import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:household_app/core/data/repositories/items_repository.dart';
import 'package:household_app/core/domain/entities/item.dart';
import 'package:household_app/core/domain/entities/list_type.dart';
import 'package:household_app/core/providers/firestore_providers.dart';
import 'package:household_app/features/home/presentation/screens/home_screen.dart';

void main() {
  testWidgets('shows item/completed counts and the most recent title per list', (tester) async {
    final firestore = FakeFirebaseFirestore();
    final itemsRepository = ItemsRepository(firestore: firestore, householdId: 'test-household');
    await itemsRepository.add(
      Item(
        id: '',
        listType: ListType.grocery,
        title: 'Milk',
        addedBy: 'member-1',
        dateAdded: DateTime(2026, 1, 1),
      ),
    );
    await itemsRepository.add(
      Item(
        id: '',
        listType: ListType.grocery,
        title: 'Eggs',
        addedBy: 'member-1',
        dateAdded: DateTime(2026, 6, 1),
        completed: true,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [itemsRepositoryProvider.overrideWithValue(itemsRepository)],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('2 items'), findsOneWidget);
    expect(find.textContaining('1 completed'), findsOneWidget);
    expect(find.textContaining('Latest: Eggs'), findsOneWidget);
    expect(find.textContaining('0 items'), findsNWidgets(4)); // the other four lists
  });
}
