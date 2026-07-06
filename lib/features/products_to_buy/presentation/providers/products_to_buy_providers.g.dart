// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'products_to_buy_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$productsToBuyItemsHash() =>
    r'b51d941c50d59149f411eae24057bcd0e61c7898';

/// See also [productsToBuyItems].
@ProviderFor(productsToBuyItems)
final productsToBuyItemsProvider =
    AutoDisposeStreamProvider<List<Item>>.internal(
      productsToBuyItems,
      name: r'productsToBuyItemsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$productsToBuyItemsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ProductsToBuyItemsRef = AutoDisposeStreamProviderRef<List<Item>>;
String _$productsToBuyFilterControllerHash() =>
    r'efbc6b1bfbd7cd8e7171d1a7153912b294f96f14';

/// See also [ProductsToBuyFilterController].
@ProviderFor(ProductsToBuyFilterController)
final productsToBuyFilterControllerProvider =
    AutoDisposeNotifierProvider<
      ProductsToBuyFilterController,
      ItemFilterState
    >.internal(
      ProductsToBuyFilterController.new,
      name: r'productsToBuyFilterControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$productsToBuyFilterControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ProductsToBuyFilterController = AutoDisposeNotifier<ItemFilterState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
