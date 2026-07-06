// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_todo_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$adminItemsHash() => r'dec1c78355829576a6dc6aff31ec3abba3bb9710';

/// See also [adminItems].
@ProviderFor(adminItems)
final adminItemsProvider = AutoDisposeStreamProvider<List<Item>>.internal(
  adminItems,
  name: r'adminItemsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$adminItemsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AdminItemsRef = AutoDisposeStreamProviderRef<List<Item>>;
String _$adminFilterControllerHash() =>
    r'd333e4b9a749f9a2c3b1c9859f4872864e609880';

/// See also [AdminFilterController].
@ProviderFor(AdminFilterController)
final adminFilterControllerProvider =
    AutoDisposeNotifierProvider<
      AdminFilterController,
      ItemFilterState
    >.internal(
      AdminFilterController.new,
      name: r'adminFilterControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$adminFilterControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AdminFilterController = AutoDisposeNotifier<ItemFilterState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
