import 'package:flutter_test/flutter_test.dart';
import 'package:household_app/core/domain/entities/item.dart';
import 'package:household_app/core/domain/entities/list_type.dart';

void main() {
  // Every field set, so each assertion below proves the irrelevant ones
  // were actually dropped rather than just never having been set.
  const details = ItemDetails(
    quantity: 2,
    unit: 'litres',
    tripId: 'trip-1',
    description: 'Renew before expiry',
    assignedTo: 'member-1',
    store: 'Amazon',
    websiteUrl: 'https://example.com',
    price: 19.99,
    desiredQuantity: 3,
  );

  test('moving to grocery keeps only quantity/unit', () {
    final result = details.filterForListType(ListType.grocery);
    expect(result.quantity, 2);
    expect(result.unit, 'litres');
    expect(result.tripId, isNull);
    expect(result.store, isNull);
    expect(result.price, isNull);
  });

  test('moving to packing keeps only tripId', () {
    final result = details.filterForListType(ListType.packing);
    expect(result.tripId, 'trip-1');
    expect(result.quantity, isNull);
    expect(result.store, isNull);
  });

  test('moving to admin keeps only description/dueDate/assignedTo', () {
    final result = details.filterForListType(ListType.admin);
    expect(result.description, 'Renew before expiry');
    expect(result.assignedTo, 'member-1');
    expect(result.tripId, isNull);
    expect(result.store, isNull);
  });

  test('moving to productsToBuy keeps store/websiteUrl/price/desiredQuantity', () {
    final result = details.filterForListType(ListType.productsToBuy);
    expect(result.store, 'Amazon');
    expect(result.websiteUrl, 'https://example.com');
    expect(result.price, 19.99);
    expect(result.desiredQuantity, 3);
    expect(result.tripId, isNull);
  });

  test('moving to wishlist keeps store/websiteUrl/price but not desiredQuantity', () {
    final result = details.filterForListType(ListType.wishlist);
    expect(result.store, 'Amazon');
    expect(result.websiteUrl, 'https://example.com');
    expect(result.price, 19.99);
    expect(result.desiredQuantity, isNull);
  });
}
