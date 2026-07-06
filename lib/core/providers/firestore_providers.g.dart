// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'firestore_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$firebaseFirestoreHash() => r'211c9d7cd91051da8adfacbf85a09b8bad1d41e8';

/// `FirebaseFirestore.instance` is already pointed at the emulator (or, in
/// release, real Cloud Firestore) by the time this is first read — see the
/// bootstrap in `main.dart`.
///
/// Copied from [firebaseFirestore].
@ProviderFor(firebaseFirestore)
final firebaseFirestoreProvider = Provider<FirebaseFirestore>.internal(
  firebaseFirestore,
  name: r'firebaseFirestoreProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$firebaseFirestoreHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FirebaseFirestoreRef = ProviderRef<FirebaseFirestore>;
String _$itemsRepositoryHash() => r'd47cd6fb6cb16990d6252f6d07a5bc72c3066c40';

/// See also [itemsRepository].
@ProviderFor(itemsRepository)
final itemsRepositoryProvider = Provider<ItemsRepository>.internal(
  itemsRepository,
  name: r'itemsRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$itemsRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ItemsRepositoryRef = ProviderRef<ItemsRepository>;
String _$tripsRepositoryHash() => r'39f8215385ff430cc2534c386cbd58ad90d5fa4a';

/// See also [tripsRepository].
@ProviderFor(tripsRepository)
final tripsRepositoryProvider = Provider<TripsRepository>.internal(
  tripsRepository,
  name: r'tripsRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$tripsRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TripsRepositoryRef = ProviderRef<TripsRepository>;
String _$householdRepositoryHash() =>
    r'8400d9f95bcb61737cc54915fff6ab1bb56eb7a4';

/// See also [householdRepository].
@ProviderFor(householdRepository)
final householdRepositoryProvider = Provider<HouseholdRepository>.internal(
  householdRepository,
  name: r'householdRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$householdRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HouseholdRepositoryRef = ProviderRef<HouseholdRepository>;
String _$itemByIdHash() => r'22d04ec3220e6a7c91409cb51253d5706383ccc5';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// A single item by ID, for deep links into a specific item (e.g. the
/// reserved `/home/admin/:itemId` route, ahead of FCM — milestone 15).
///
/// Copied from [itemById].
@ProviderFor(itemById)
const itemByIdProvider = ItemByIdFamily();

/// A single item by ID, for deep links into a specific item (e.g. the
/// reserved `/home/admin/:itemId` route, ahead of FCM — milestone 15).
///
/// Copied from [itemById].
class ItemByIdFamily extends Family<AsyncValue<Item?>> {
  /// A single item by ID, for deep links into a specific item (e.g. the
  /// reserved `/home/admin/:itemId` route, ahead of FCM — milestone 15).
  ///
  /// Copied from [itemById].
  const ItemByIdFamily();

  /// A single item by ID, for deep links into a specific item (e.g. the
  /// reserved `/home/admin/:itemId` route, ahead of FCM — milestone 15).
  ///
  /// Copied from [itemById].
  ItemByIdProvider call(String itemId) {
    return ItemByIdProvider(itemId);
  }

  @override
  ItemByIdProvider getProviderOverride(covariant ItemByIdProvider provider) {
    return call(provider.itemId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'itemByIdProvider';
}

/// A single item by ID, for deep links into a specific item (e.g. the
/// reserved `/home/admin/:itemId` route, ahead of FCM — milestone 15).
///
/// Copied from [itemById].
class ItemByIdProvider extends AutoDisposeStreamProvider<Item?> {
  /// A single item by ID, for deep links into a specific item (e.g. the
  /// reserved `/home/admin/:itemId` route, ahead of FCM — milestone 15).
  ///
  /// Copied from [itemById].
  ItemByIdProvider(String itemId)
    : this._internal(
        (ref) => itemById(ref as ItemByIdRef, itemId),
        from: itemByIdProvider,
        name: r'itemByIdProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$itemByIdHash,
        dependencies: ItemByIdFamily._dependencies,
        allTransitiveDependencies: ItemByIdFamily._allTransitiveDependencies,
        itemId: itemId,
      );

  ItemByIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.itemId,
  }) : super.internal();

  final String itemId;

  @override
  Override overrideWith(Stream<Item?> Function(ItemByIdRef provider) create) {
    return ProviderOverride(
      origin: this,
      override: ItemByIdProvider._internal(
        (ref) => create(ref as ItemByIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        itemId: itemId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<Item?> createElement() {
    return _ItemByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ItemByIdProvider && other.itemId == itemId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, itemId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ItemByIdRef on AutoDisposeStreamProviderRef<Item?> {
  /// The parameter `itemId` of this provider.
  String get itemId;
}

class _ItemByIdProviderElement extends AutoDisposeStreamProviderElement<Item?>
    with ItemByIdRef {
  _ItemByIdProviderElement(super.provider);

  @override
  String get itemId => (origin as ItemByIdProvider).itemId;
}

String _$allItemsHash() => r'c04f7ebe5e214c5adb706175a03ec05c6fad428a';

/// Every item across all five lists — used by Search (not scoped to a
/// single `listType` by design) and by Home's per-list stats cards.
///
/// Copied from [allItems].
@ProviderFor(allItems)
final allItemsProvider = AutoDisposeStreamProvider<List<Item>>.internal(
  allItems,
  name: r'allItemsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$allItemsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllItemsRef = AutoDisposeStreamProviderRef<List<Item>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
