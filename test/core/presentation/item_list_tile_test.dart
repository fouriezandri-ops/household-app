import 'dart:async';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:household_app/core/data/image_upload_service.dart';
import 'package:household_app/core/data/repositories/household_repository.dart';
import 'package:household_app/core/data/repositories/items_repository.dart';
import 'package:household_app/core/domain/entities/item.dart';
import 'package:household_app/core/domain/entities/list_type.dart';
import 'package:household_app/core/presentation/widgets/item_list_tile.dart';
import 'package:household_app/core/providers/firestore_providers.dart';
import 'package:household_app/core/providers/storage_providers.dart';

class _FakeImageUploadService implements ImageUploadService {
  final deletedItemIds = <String>[];

  @override
  Future<String> uploadItemImage(String itemId, List<int> bytes) async => 'https://example.com';

  @override
  Future<void> deleteItemImage(String itemId) async => deletedItemIds.add(itemId);
}

void main() {
  testWidgets('swiping open and tapping Move opens the move-between-lists sheet', (tester) async {
    final firestore = FakeFirebaseFirestore();
    final itemsRepository = ItemsRepository(firestore: firestore, householdId: 'test-household');
    final item = Item(
      id: 'item-1',
      listType: ListType.grocery,
      title: 'Milk',
      addedBy: 'member-1',
      dateAdded: DateTime.now(),
    );
    await itemsRepository.set(item.id, item);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          itemsRepositoryProvider.overrideWithValue(itemsRepository),
          householdRepositoryProvider.overrideWithValue(
            HouseholdRepository(firestore: firestore, householdId: 'test-household'),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(body: ItemListTile(item: item, onTap: () {})),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final slidableContext = tester.element(find.text('Milk'));
    // Deliberately not awaited: openEndActionPane()'s Future only resolves
    // once its animation finishes, which only happens as pumpAndSettle
    // below drives frames — awaiting it directly here would deadlock.
    unawaited(Slidable.of(slidableContext)!.openEndActionPane());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Move'));
    await tester.pumpAndSettle();

    expect(find.text('Move "Milk" to…'), findsOneWidget);
  });

  testWidgets('deleting an item with a photo also deletes its Storage image', (tester) async {
    final firestore = FakeFirebaseFirestore();
    final itemsRepository = ItemsRepository(firestore: firestore, householdId: 'test-household');
    final fakeImageUploadService = _FakeImageUploadService();
    final item = Item(
      id: 'item-1',
      listType: ListType.wishlist,
      title: 'Espresso machine',
      addedBy: 'member-1',
      dateAdded: DateTime.now(),
      imageUrl: 'https://example.com/espresso.jpg',
    );
    await itemsRepository.set(item.id, item);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          itemsRepositoryProvider.overrideWithValue(itemsRepository),
          householdRepositoryProvider.overrideWithValue(
            HouseholdRepository(firestore: firestore, householdId: 'test-household'),
          ),
          imageUploadServiceProvider.overrideWithValue(fakeImageUploadService),
        ],
        child: MaterialApp(
          home: Scaffold(body: ItemListTile(item: item, onTap: () {})),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final slidableContext = tester.element(find.text('Espresso machine'));
    unawaited(Slidable.of(slidableContext)!.openEndActionPane());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(await itemsRepository.getById(item.id), isNull);
    expect(fakeImageUploadService.deletedItemIds, [item.id]);
  });
}
