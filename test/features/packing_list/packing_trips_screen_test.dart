import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:household_app/core/data/repositories/trips_repository.dart';
import 'package:household_app/core/providers/firestore_providers.dart';
import 'package:household_app/features/household/presentation/providers/current_member_provider.dart';
import 'package:household_app/features/packing_list/presentation/screens/packing_trips_screen.dart';

class _FakeCurrentMemberController extends CurrentMemberController {
  @override
  Future<String?> build() async => 'member-1';
}

void main() {
  testWidgets('creating a trip via the FAB shows it in the list', (tester) async {
    final firestore = FakeFirebaseFirestore();
    final tripsRepository = TripsRepository(firestore: firestore, householdId: 'test-household');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tripsRepositoryProvider.overrideWithValue(tripsRepository),
          currentMemberControllerProvider.overrideWith(_FakeCurrentMemberController.new),
        ],
        child: const MaterialApp(home: PackingTripsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No trips yet — add one to start packing'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'Trip name'), 'Japan 2027');
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    expect(find.text('Japan 2027'), findsOneWidget);
  });
}
