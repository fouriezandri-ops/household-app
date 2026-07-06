import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:household_app/core/data/repositories/household_repository.dart';
import 'package:household_app/core/data/repositories/items_repository.dart';
import 'package:household_app/core/data/repositories/trips_repository.dart';
import 'package:household_app/core/domain/entities/item.dart';
import 'package:household_app/core/domain/entities/list_type.dart';
import 'package:household_app/core/domain/entities/trip.dart';
import 'package:household_app/core/providers/firestore_providers.dart';
import 'package:household_app/features/household/presentation/providers/current_member_provider.dart';
import 'package:household_app/features/packing_list/presentation/screens/packing_trip_detail_screen.dart';

class _FakeCurrentMemberController extends CurrentMemberController {
  @override
  Future<String?> build() async => 'member-1';
}

void main() {
  late FakeFirebaseFirestore firestore;
  late ItemsRepository itemsRepository;
  late TripsRepository tripsRepository;
  late String tripId;

  List<Override> overrides() => [
    itemsRepositoryProvider.overrideWithValue(itemsRepository),
    tripsRepositoryProvider.overrideWithValue(tripsRepository),
    householdRepositoryProvider.overrideWithValue(
      HouseholdRepository(firestore: firestore, householdId: 'test-household'),
    ),
    currentMemberControllerProvider.overrideWith(_FakeCurrentMemberController.new),
  ];

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    itemsRepository = ItemsRepository(firestore: firestore, householdId: 'test-household');
    tripsRepository = TripsRepository(firestore: firestore, householdId: 'test-household');
    tripId = await tripsRepository.add(
      Trip(id: '', name: 'Japan 2027', createdBy: 'member-1', createdAt: DateTime.now()),
    );
  });

  testWidgets('shows the trip name and lets you add a packing item', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides(),
        child: MaterialApp(home: PackingTripDetailScreen(tripId: tripId)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Japan 2027'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'Item'), 'Passport');
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    expect(find.text('Passport'), findsOneWidget);
  });

  testWidgets('the "Not packed" chip hides completed items', (tester) async {
    await itemsRepository.add(
      Item(
        id: '',
        listType: ListType.packing,
        title: 'Passport',
        addedBy: 'member-1',
        dateAdded: DateTime.now(),
        details: ItemDetails(tripId: tripId),
      ),
    );
    await itemsRepository.add(
      Item(
        id: '',
        listType: ListType.packing,
        title: 'Sunscreen',
        addedBy: 'member-1',
        dateAdded: DateTime.now(),
        completed: true,
        details: ItemDetails(tripId: tripId),
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides(),
        child: MaterialApp(home: PackingTripDetailScreen(tripId: tripId)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Passport'), findsOneWidget);
    expect(find.text('Sunscreen'), findsOneWidget);

    await tester.tap(find.text('Not packed'));
    await tester.pumpAndSettle();

    expect(find.text('Passport'), findsOneWidget);
    expect(find.text('Sunscreen'), findsNothing);
  });
}
