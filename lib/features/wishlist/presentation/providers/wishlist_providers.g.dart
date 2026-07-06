// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wishlist_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$wishlistItemsHash() => r'f8fc373aa283f1afbce9375d022fcbf1c4810fe4';

/// See also [wishlistItems].
@ProviderFor(wishlistItems)
final wishlistItemsProvider = AutoDisposeStreamProvider<List<Item>>.internal(
  wishlistItems,
  name: r'wishlistItemsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$wishlistItemsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WishlistItemsRef = AutoDisposeStreamProviderRef<List<Item>>;
String _$wishlistFilterControllerHash() =>
    r'4154692429a41bfb0ae98d8a3889b7ba9bbf86a7';

/// See also [WishlistFilterController].
@ProviderFor(WishlistFilterController)
final wishlistFilterControllerProvider =
    AutoDisposeNotifierProvider<
      WishlistFilterController,
      ItemFilterState
    >.internal(
      WishlistFilterController.new,
      name: r'wishlistFilterControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$wishlistFilterControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$WishlistFilterController = AutoDisposeNotifier<ItemFilterState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
