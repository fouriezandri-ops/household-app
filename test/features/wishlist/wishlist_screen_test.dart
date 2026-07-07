import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:household_app/core/data/repositories/household_repository.dart';
import 'package:household_app/core/data/repositories/items_repository.dart';
import 'package:household_app/core/domain/entities/item.dart';
import 'package:household_app/core/domain/entities/list_type.dart';
import 'package:household_app/core/providers/firestore_providers.dart';
import 'package:household_app/features/household/presentation/providers/current_member_provider.dart';
import 'package:household_app/features/wishlist/presentation/screens/wishlist_screen.dart';

class _FakeCurrentMemberController extends CurrentMemberController {
  @override
  Future<String?> build() async => 'member-1';
}

void main() {
  late FakeFirebaseFirestore firestore;
  late ItemsRepository itemsRepository;

  List<Override> overrides() => [
    itemsRepositoryProvider.overrideWithValue(itemsRepository),
    householdRepositoryProvider.overrideWithValue(
      HouseholdRepository(firestore: firestore, householdId: 'test-household'),
    ),
    currentMemberControllerProvider.overrideWith(_FakeCurrentMemberController.new),
  ];

  setUp(() {
    firestore = FakeFirebaseFirestore();
    itemsRepository = ItemsRepository(firestore: firestore, householdId: 'test-household');
  });

  testWidgets('adding a wishlist item via the FAB shows it with its store and price', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(overrides: overrides(), child: const MaterialApp(home: WishlistScreen())),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(find.text('Add wishlist item'), findsOneWidget);
    // Desired quantity is a Products-to-Buy-only field.
    expect(find.widgetWithText(TextFormField, 'Quantity wanted'), findsNothing);

    await tester.enterText(find.widgetWithText(TextFormField, 'Item'), 'Espresso machine');
    await tester.enterText(find.widgetWithText(TextFormField, 'Store'), 'Williams Sonoma');
    await tester.enterText(find.widgetWithText(TextFormField, 'Price'), '450');
    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Save'));
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    expect(find.text('Espresso machine'), findsOneWidget);
    expect(find.textContaining('R450.00'), findsOneWidget);
    expect(find.textContaining('Williams Sonoma'), findsOneWidget);
  });

  testWidgets('the "Not received" chip hides completed items', (tester) async {
    await itemsRepository.add(
      Item(
        id: '',
        listType: ListType.wishlist,
        title: 'Espresso machine',
        addedBy: 'member-1',
        dateAdded: DateTime.now(),
      ),
    );
    await itemsRepository.add(
      Item(
        id: '',
        listType: ListType.wishlist,
        title: 'Stand mixer',
        addedBy: 'member-1',
        dateAdded: DateTime.now(),
        completed: true,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(overrides: overrides(), child: const MaterialApp(home: WishlistScreen())),
    );
    await tester.pumpAndSettle();

    expect(find.text('Espresso machine'), findsOneWidget);
    expect(find.text('Stand mixer'), findsOneWidget);

    await tester.tap(find.text('Not received'));
    await tester.pumpAndSettle();

    expect(find.text('Espresso machine'), findsOneWidget);
    expect(find.text('Stand mixer'), findsNothing);
  });
}
