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
    r'af45be8670f1d6ea4b7fce28d70d908cb7665662';

/// See also [GroceryFilterController].
@ProviderFor(GroceryFilterController)
final groceryFilterControllerProvider =
    AutoDisposeNotifierProvider<
      GroceryFilterController,
      GroceryFilter
    >.internal(
      GroceryFilterController.new,
      name: r'groceryFilterControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$groceryFilterControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$GroceryFilterController = AutoDisposeNotifier<GroceryFilter>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
