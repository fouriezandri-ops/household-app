// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$allItemsHash() => r'c04f7ebe5e214c5adb706175a03ec05c6fad428a';

/// Every item across all five lists — search is the one screen that's
/// deliberately not scoped to a single `listType`.
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
String _$searchQueryControllerHash() =>
    r'efdf44744c02cf4858bc445ffebc268b9dfbb22e';

/// See also [SearchQueryController].
@ProviderFor(SearchQueryController)
final searchQueryControllerProvider =
    AutoDisposeNotifierProvider<SearchQueryController, String>.internal(
      SearchQueryController.new,
      name: r'searchQueryControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$searchQueryControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SearchQueryController = AutoDisposeNotifier<String>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
