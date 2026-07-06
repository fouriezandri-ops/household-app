import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:household_app/core/data/repositories/household_repository.dart';
import 'package:household_app/core/data/repositories/items_repository.dart';
import 'package:household_app/core/domain/entities/item.dart';
import 'package:household_app/core/domain/entities/list_type.dart';
import 'package:household_app/core/providers/firestore_providers.dart';
import 'package:household_app/features/search/presentation/screens/search_screen.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late ItemsRepository itemsRepository;

  List<Override> overrides() => [
    itemsRepositoryProvider.overrideWithValue(itemsRepository),
    householdRepositoryProvider.overrideWithValue(
      HouseholdRepository(firestore: firestore, householdId: 'test-household'),
    ),
  ];

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    itemsRepository = ItemsRepository(firestore: firestore, householdId: 'test-household');

    await itemsRepository.add(
      Item(
        id: '',
        listType: ListType.grocery,
        title: 'Milk',
        addedBy: 'member-1',
        dateAdded: DateTime.now(),
      ),
    );
    await itemsRepository.add(
      Item(
        id: '',
        listType: ListType.admin,
        title: 'Renew passport',
        addedBy: 'member-1',
        dateAdded: DateTime.now(),
      ),
    );
    await itemsRepository.add(
      Item(
        id: '',
        listType: ListType.wishlist,
        title: 'Espresso machine',
        addedBy: 'member-1',
        dateAdded: DateTime.now(),
      ),
    );
  });

  testWidgets('shows nothing until you type, then filters across all lists', (tester) async {
    await tester.pumpWidget(
      ProviderScope(overrides: overrides(), child: const MaterialApp(home: SearchScreen())),
    );
    await tester.pumpAndSettle();

    expect(find.text('Type to search across all your lists'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'passport');
    await tester.pumpAndSettle();

    expect(find.text('Renew passport'), findsOneWidget);
    expect(find.text('Admin To-Do'), findsOneWidget);
    expect(find.text('Milk'), findsNothing);
    expect(find.text('Espresso machine'), findsNothing);
  });

  testWidgets('tapping a result opens the right list\'s edit sheet', (tester) async {
    await tester.pumpWidget(
      ProviderScope(overrides: overrides(), child: const MaterialApp(home: SearchScreen())),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'espresso');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Espresso machine'));
    await tester.pumpAndSettle();

    expect(find.text('Edit wishlist item'), findsOneWidget);
  });
}
