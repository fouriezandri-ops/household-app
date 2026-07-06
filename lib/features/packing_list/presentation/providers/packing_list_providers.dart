import 'package:riverpod/riverpod.dart' show Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/domain/entities/item.dart';
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

// Packing's filter uses the shared listFilterControllerProvider(ListType.packing)
// (lib/core/providers/list_filter_providers.dart) rather than its own
// controller — it's scoped by list type just like the other four lists,
// even though its items stream (below) is additionally scoped by trip.
@riverpod
Stream<List<Item>> packingItems(Ref ref, String tripId) {
  return ref.watch(itemsRepositoryProvider).watchByTripId(tripId);
}
