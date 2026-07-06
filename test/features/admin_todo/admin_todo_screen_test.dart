import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:household_app/core/data/repositories/household_repository.dart';
import 'package:household_app/core/data/repositories/items_repository.dart';
import 'package:household_app/core/domain/entities/item.dart';
import 'package:household_app/core/domain/entities/list_type.dart';
import 'package:household_app/core/providers/firestore_providers.dart';
import 'package:household_app/features/admin_todo/presentation/screens/admin_todo_screen.dart';
import 'package:household_app/features/household/presentation/providers/current_member_provider.dart';

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

  testWidgets('adding a to-do via the FAB shows it in the list', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides(),
        child: const MaterialApp(home: AdminTodoScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'Title'), 'Renew passport');
    await tester.tap(find.text('high'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    expect(find.text('Renew passport'), findsOneWidget);
    expect(find.textContaining('high priority'), findsOneWidget);
  });

  testWidgets('the "Not done" chip hides completed items', (tester) async {
    await itemsRepository.add(
      Item(id: '', listType: ListType.admin, title: 'Todo', addedBy: 'member-1', dateAdded: DateTime.now()),
    );
    await itemsRepository.add(
      Item(
        id: '',
        listType: ListType.admin,
        title: 'Done',
        addedBy: 'member-1',
        dateAdded: DateTime.now(),
        completed: true,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides(),
        child: const MaterialApp(home: AdminTodoScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Todo'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);

    await tester.tap(find.text('Not done'));
    await tester.pumpAndSettle();

    expect(find.text('Todo'), findsOneWidget);
    expect(find.text('Done'), findsNothing);
  });
}
