import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:household_app/core/data/repositories/items_repository.dart';
import 'package:household_app/core/data/repositories/trips_repository.dart';
import 'package:household_app/core/domain/entities/item.dart';
import 'package:household_app/core/domain/entities/list_type.dart';
import 'package:household_app/core/domain/entities/trip.dart';
import 'package:household_app/core/providers/firestore_providers.dart';
import 'package:household_app/features/move_between_lists/presentation/widgets/move_item_sheet.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late ItemsRepository itemsRepository;
  late TripsRepository tripsRepository;

  List<Override> overrides() => [
    itemsRepositoryProvider.overrideWithValue(itemsRepository),
    tripsRepositoryProvider.overrideWithValue(tripsRepository),
  ];

  setUp(() {
    firestore = FakeFirebaseFirestore();
    itemsRepository = ItemsRepository(
      firestore: firestore,
      householdId: 'test-household',
    );
    tripsRepository = TripsRepository(
      firestore: firestore,
      householdId: 'test-household',
    );
  });

  testWidgets(
    'moving a wishlist item to Products to Buy carries over store/price',
    (tester) async {
      final id = await itemsRepository.add(
        Item(
          id: '',
          listType: ListType.wishlist,
          title: 'Espresso machine',
          addedBy: 'member-1',
          dateAdded: DateTime.now(),
          details: const ItemDetails(store: 'Williams Sonoma', price: 450),
        ),
      );
      final item = (await itemsRepository.getById(id))!;

      await tester.pumpWidget(
        ProviderScope(
          overrides: overrides(),
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () => showMoveItemSheet(context, item),
                    child: const Text('Open'),
                  );
                },
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Products to Buy'), findsOneWidget);
      await tester.tap(find.text('Products to Buy'));
      await tester.pumpAndSettle();

      final moved = await itemsRepository.getById(id);
      expect(moved!.listType, ListType.productsToBuy);
      expect(moved.details.store, 'Williams Sonoma');
      expect(moved.details.price, 450);
      expect(moved.details.desiredQuantity, isNull);
      expect(moved.history, hasLength(1));
      expect(moved.history.single.listType, ListType.productsToBuy);
    },
  );

  testWidgets(
    'moving an item to Packing opens the trip picker and sets tripId',
    (tester) async {
      final tripId = await tripsRepository.add(
        Trip(
          id: '',
          name: 'Japan 2027',
          createdBy: 'member-1',
          createdAt: DateTime.now(),
        ),
      );
      final id = await itemsRepository.add(
        Item(
          id: '',
          listType: ListType.grocery,
          title: 'Sunscreen',
          addedBy: 'member-1',
          dateAdded: DateTime.now(),
        ),
      );
      final item = (await itemsRepository.getById(id))!;

      await tester.pumpWidget(
        ProviderScope(
          overrides: overrides(),
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () => showMoveItemSheet(context, item),
                    child: const Text('Open'),
                  );
                },
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Packing'));
      await tester.pumpAndSettle();

      expect(find.text('Japan 2027'), findsOneWidget);
      await tester.tap(find.text('Japan 2027'));
      await tester.pumpAndSettle();

      final moved = await itemsRepository.getById(id);
      expect(moved!.listType, ListType.packing);
      expect(moved.details.tripId, tripId);
    },
  );
}
