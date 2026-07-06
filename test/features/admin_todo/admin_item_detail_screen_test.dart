import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:household_app/core/data/repositories/household_repository.dart';
import 'package:household_app/core/data/repositories/items_repository.dart';
import 'package:household_app/core/domain/entities/item.dart';
import 'package:household_app/core/domain/entities/list_type.dart';
import 'package:household_app/core/providers/firestore_providers.dart';
import 'package:household_app/features/admin_todo/presentation/screens/admin_item_detail_screen.dart';
import 'package:household_app/features/household/presentation/providers/current_member_provider.dart';

class _FakeCurrentMemberController extends CurrentMemberController {
  @override
  Future<String?> build() async => 'member-1';
}

void main() {
  testWidgets('deep-linking to an item shows the list underneath and auto-opens the edit sheet', (
    tester,
  ) async {
    final firestore = FakeFirebaseFirestore();
    final itemsRepository = ItemsRepository(firestore: firestore, householdId: 'test-household');
    final itemId = await itemsRepository.add(
      Item(
        id: '',
        listType: ListType.admin,
        title: 'Renew passport',
        addedBy: 'member-1',
        dateAdded: DateTime.now(),
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          itemsRepositoryProvider.overrideWithValue(itemsRepository),
          householdRepositoryProvider.overrideWithValue(
            HouseholdRepository(firestore: firestore, householdId: 'test-household'),
          ),
          currentMemberControllerProvider.overrideWith(_FakeCurrentMemberController.new),
        ],
        child: MaterialApp(home: AdminItemDetailScreen(itemId: itemId)),
      ),
    );
    await tester.pumpAndSettle();

    // The admin list is visible underneath...
    expect(find.text('Renew passport'), findsWidgets);
    // ...and the edit sheet auto-opened on top of it.
    expect(find.text('Edit admin to-do'), findsOneWidget);
  });
}
