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
import 'package:household_app/features/products_to_buy/presentation/screens/products_to_buy_screen.dart';

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

  testWidgets('adding a product via the FAB shows it with its store and price', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides(),
        child: const MaterialApp(home: ProductsToBuyScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'Product'), 'Headphones');
    await tester.enterText(find.widgetWithText(TextFormField, 'Store'), 'Amazon');
    await tester.enterText(find.widgetWithText(TextFormField, 'Price'), '199.99');
    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Save'));
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    expect(find.text('Headphones'), findsOneWidget);
    expect(find.textContaining('\$199.99'), findsOneWidget);
    expect(find.textContaining('Amazon'), findsOneWidget);
  });

  testWidgets('the "Not bought" chip hides completed items', (tester) async {
    await itemsRepository.add(
      Item(
        id: '',
        listType: ListType.productsToBuy,
        title: 'Headphones',
        addedBy: 'member-1',
        dateAdded: DateTime.now(),
      ),
    );
    await itemsRepository.add(
      Item(
        id: '',
        listType: ListType.productsToBuy,
        title: 'Blender',
        addedBy: 'member-1',
        dateAdded: DateTime.now(),
        completed: true,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides(),
        child: const MaterialApp(home: ProductsToBuyScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Headphones'), findsOneWidget);
    expect(find.text('Blender'), findsOneWidget);

    await tester.tap(find.text('Not bought'));
    await tester.pumpAndSettle();

    expect(find.text('Headphones'), findsOneWidget);
    expect(find.text('Blender'), findsNothing);
  });

  testWidgets('an item with an imageUrl shows a thumbnail', (tester) async {
    await itemsRepository.add(
      Item(
        id: '',
        listType: ListType.productsToBuy,
        title: 'Headphones',
        addedBy: 'member-1',
        dateAdded: DateTime.now(),
        imageUrl: 'https://example.com/headphones.jpg',
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides(),
        child: const MaterialApp(home: ProductsToBuyScreen()),
      ),
    );
    await tester.pump();

    expect(find.byType(Image), findsOneWidget);
  });
}
