import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:household_app/core/data/repositories/items_repository.dart';
import 'package:household_app/core/data/repositories/trips_repository.dart';
import 'package:household_app/core/domain/entities/trip.dart';
import 'package:household_app/core/providers/firestore_providers.dart';
import 'package:household_app/features/household/presentation/providers/current_member_provider.dart';
import 'package:household_app/features/home/presentation/widgets/quick_add_sheet.dart';

class _FakeCurrentMemberController extends CurrentMemberController {
  @override
  Future<String?> build() async => 'member-1';
}

void main() {
  late FakeFirebaseFirestore firestore;

  List<Override> overrides() => [
    itemsRepositoryProvider.overrideWithValue(
      ItemsRepository(firestore: firestore, householdId: 'test-household'),
    ),
    tripsRepositoryProvider.overrideWithValue(
      TripsRepository(firestore: firestore, householdId: 'test-household'),
    ),
    currentMemberControllerProvider.overrideWith(_FakeCurrentMemberController.new),
  ];

  setUp(() {
    firestore = FakeFirebaseFirestore();
  });

  testWidgets('picking Grocery opens the grocery add sheet directly', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides(),
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showQuickAddSheet(context),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Grocery'));
    await tester.pumpAndSettle();

    expect(find.text('Add grocery item'), findsOneWidget);
  });

  testWidgets('picking Packing opens the trip picker, then the packing add sheet', (
    tester,
  ) async {
    final tripsRepository = TripsRepository(firestore: firestore, householdId: 'test-household');
    await tripsRepository.add(
      Trip(id: '', name: 'Japan 2027', createdBy: 'member-1', createdAt: DateTime.now()),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides(),
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showQuickAddSheet(context),
                child: const Text('Open'),
              ),
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

    expect(find.text('Add packing item'), findsOneWidget);
  });
}
