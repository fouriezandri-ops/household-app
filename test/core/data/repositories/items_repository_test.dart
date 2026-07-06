import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:household_app/core/data/repositories/items_repository.dart';
import 'package:household_app/core/domain/entities/item.dart';
import 'package:household_app/core/domain/entities/list_type.dart';
import 'package:household_app/core/domain/entities/priority.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late ItemsRepository repository;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repository = ItemsRepository(firestore: firestore, householdId: 'test-household');
  });

  Item buildItem({
    required ListType listType,
    required String title,
    DateTime? dateAdded,
    ItemDetails details = const ItemDetails(),
  }) {
    return Item(
      id: '', // unknown until add() returns the generated doc ID.
      listType: listType,
      title: title,
      addedBy: 'member-1',
      dateAdded: dateAdded ?? DateTime.now(),
      details: details,
    );
  }

  test('add + getById round-trips through the Firestore converter', () async {
    final id = await repository.add(
      buildItem(
        listType: ListType.grocery,
        title: 'Milk',
        details: const ItemDetails(quantity: 2, unit: 'litres'),
      ),
    );

    final stored = await repository.getById(id);
    expect(stored, isNotNull);
    expect(stored!.title, 'Milk');
    expect(stored.listType, ListType.grocery);
    expect(stored.details.quantity, 2);
    expect(stored.details.unit, 'litres');
  });

  test('watchByListType only returns matching items, newest first', () async {
    await repository.add(
      buildItem(
        listType: ListType.grocery,
        title: 'Older',
        dateAdded: DateTime(2026, 1, 1),
      ),
    );
    await repository.add(
      buildItem(
        listType: ListType.grocery,
        title: 'Newer',
        dateAdded: DateTime(2026, 6, 1),
      ),
    );
    await repository.add(buildItem(listType: ListType.wishlist, title: 'Not grocery'));

    final groceryItems = await repository.watchByListType(ListType.grocery).first;

    expect(groceryItems.map((item) => item.title), ['Newer', 'Older']);
  });

  test('moveToList updates listType, optionally details, and appends history', () async {
    final id = await repository.add(
      buildItem(
        listType: ListType.wishlist,
        title: 'Headphones',
        details: const ItemDetails(price: 199.99, websiteUrl: 'https://example.com'),
      ),
    );

    await repository.moveToList(
      id,
      newListType: ListType.productsToBuy,
      newDetails: const ItemDetails(
        price: 199.99,
        websiteUrl: 'https://example.com',
        desiredQuantity: 1,
      ),
    );

    final moved = await repository.getById(id);
    expect(moved!.listType, ListType.productsToBuy);
    expect(moved.details.price, 199.99);
    expect(moved.details.desiredQuantity, 1);
    expect(moved.history, hasLength(1));
    expect(moved.history.single.listType, ListType.productsToBuy);
  });

  test('updateFields patches a single field without touching the rest', () async {
    final id = await repository.add(
      buildItem(listType: ListType.admin, title: 'Renew passport'),
    );

    await repository.updateFields(id, {'completed': true, 'priority': Priority.high.name});

    final updated = await repository.getById(id);
    expect(updated!.completed, isTrue);
    expect(updated.priority, Priority.high);
    expect(updated.title, 'Renew passport');
  });

  test('delete removes the document', () async {
    final id = await repository.add(buildItem(listType: ListType.grocery, title: 'Eggs'));
    await repository.delete(id);
    expect(await repository.getById(id), isNull);
  });
}
