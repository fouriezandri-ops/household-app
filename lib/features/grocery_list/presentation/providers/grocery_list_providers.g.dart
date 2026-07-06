// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grocery_list_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$groceryItemsHash() => r'adc0abdaa2cf27657ebac99f0ce20726e3465803';

/// See also [groceryItems].
@ProviderFor(groceryItems)
final groceryItemsProvider = AutoDisposeStreamProvider<List<Item>>.internal(
  groceryItems,
  name: r'groceryItemsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$groceryItemsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GroceryItemsRef = AutoDisposeStreamProviderRef<List<Item>>;
String _$groceryFilterControllerHash() =>
    r'350fff34bd960788a18631c38aca3b76b9834da0';

/// See also [GroceryFilterController].
@ProviderFor(GroceryFilterController)
final groceryFilterControllerProvider =
    AutoDisposeNotifierProvider<
      GroceryFilterController,
      ItemFilterState
    >.internal(
      GroceryFilterController.new,
      name: r'groceryFilterControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$groceryFilterControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$GroceryFilterController = AutoDisposeNotifier<ItemFilterState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
