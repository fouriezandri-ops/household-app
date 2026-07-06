import 'package:riverpod/riverpod.dart' show Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/domain/entities/item.dart';
import '../../../../core/domain/entities/item_filter.dart';
import '../../../../core/domain/entities/trip.dart';
import '../../../../core/providers/firestore_providers.dart';

part 'packing_list_providers.g.dart';

@riverpod
Stream<List<Trip>> trips(Ref ref) {
  return ref.watch(tripsRepositoryProvider).watchAllByStartDate();
}

@riverpod
Stream<Trip?> trip(Ref ref, String tripId) {
  return ref.watch(tripsRepositoryProvider).watchById(tripId);
}

@riverpod
Stream<List<Item>> packingItems(Ref ref, String tripId) {
  return ref.watch(itemsRepositoryProvider).watchByTripId(tripId);
}

@riverpod
class PackingFilterController extends _$PackingFilterController {
  @override
  ItemFilter build() => const ItemFilterAll();

  void select(ItemFilter filter) => state = filter;
}
