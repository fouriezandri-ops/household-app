// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'packing_list_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$tripsHash() => r'1f26bdd70c38c0e7bb0fda6194ef67bfed1125b9';

/// See also [trips].
@ProviderFor(trips)
final tripsProvider = AutoDisposeStreamProvider<List<Trip>>.internal(
  trips,
  name: r'tripsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$tripsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TripsRef = AutoDisposeStreamProviderRef<List<Trip>>;
String _$tripHash() => r'a1d188d426e67334aacc2d150e07a8fccfbc67cd';

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

/// See also [trip].
@ProviderFor(trip)
const tripProvider = TripFamily();

/// See also [trip].
class TripFamily extends Family<AsyncValue<Trip?>> {
  /// See also [trip].
  const TripFamily();

  /// See also [trip].
  TripProvider call(String tripId) {
    return TripProvider(tripId);
  }

  @override
  TripProvider getProviderOverride(covariant TripProvider provider) {
    return call(provider.tripId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'tripProvider';
}

/// See also [trip].
class TripProvider extends AutoDisposeStreamProvider<Trip?> {
  /// See also [trip].
  TripProvider(String tripId)
    : this._internal(
        (ref) => trip(ref as TripRef, tripId),
        from: tripProvider,
        name: r'tripProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$tripHash,
        dependencies: TripFamily._dependencies,
        allTransitiveDependencies: TripFamily._allTransitiveDependencies,
        tripId: tripId,
      );

  TripProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.tripId,
  }) : super.internal();

  final String tripId;

  @override
  Override overrideWith(Stream<Trip?> Function(TripRef provider) create) {
    return ProviderOverride(
      origin: this,
      override: TripProvider._internal(
        (ref) => create(ref as TripRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        tripId: tripId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<Trip?> createElement() {
    return _TripProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TripProvider && other.tripId == tripId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, tripId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TripRef on AutoDisposeStreamProviderRef<Trip?> {
  /// The parameter `tripId` of this provider.
  String get tripId;
}

class _TripProviderElement extends AutoDisposeStreamProviderElement<Trip?>
    with TripRef {
  _TripProviderElement(super.provider);

  @override
  String get tripId => (origin as TripProvider).tripId;
}

String _$packingItemsHash() => r'b71dfa5f7e32253d6e7acfdc769c68faf8bc1286';

/// See also [packingItems].
@ProviderFor(packingItems)
const packingItemsProvider = PackingItemsFamily();

/// See also [packingItems].
class PackingItemsFamily extends Family<AsyncValue<List<Item>>> {
  /// See also [packingItems].
  const PackingItemsFamily();

  /// See also [packingItems].
  PackingItemsProvider call(String tripId) {
    return PackingItemsProvider(tripId);
  }

  @override
  PackingItemsProvider getProviderOverride(
    covariant PackingItemsProvider provider,
  ) {
    return call(provider.tripId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'packingItemsProvider';
}

/// See also [packingItems].
class PackingItemsProvider extends AutoDisposeStreamProvider<List<Item>> {
  /// See also [packingItems].
  PackingItemsProvider(String tripId)
    : this._internal(
        (ref) => packingItems(ref as PackingItemsRef, tripId),
        from: packingItemsProvider,
        name: r'packingItemsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$packingItemsHash,
        dependencies: PackingItemsFamily._dependencies,
        allTransitiveDependencies:
            PackingItemsFamily._allTransitiveDependencies,
        tripId: tripId,
      );

  PackingItemsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.tripId,
  }) : super.internal();

  final String tripId;

  @override
  Override overrideWith(
    Stream<List<Item>> Function(PackingItemsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PackingItemsProvider._internal(
        (ref) => create(ref as PackingItemsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        tripId: tripId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<Item>> createElement() {
    return _PackingItemsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PackingItemsProvider && other.tripId == tripId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, tripId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PackingItemsRef on AutoDisposeStreamProviderRef<List<Item>> {
  /// The parameter `tripId` of this provider.
  String get tripId;
}

class _PackingItemsProviderElement
    extends AutoDisposeStreamProviderElement<List<Item>>
    with PackingItemsRef {
  _PackingItemsProviderElement(super.provider);

  @override
  String get tripId => (origin as PackingItemsProvider).tripId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
