// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_filter_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$listFilterControllerHash() =>
    r'54f1533ac3a6efb3c4b6c91232187af0393c12ae';

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

abstract class _$ListFilterController
    extends BuildlessAutoDisposeNotifier<ItemFilterState> {
  late final ListType listType;

  ItemFilterState build(ListType listType);
}

/// One filter-state notifier shared by every list screen, keyed by
/// [ListType] — replaces five otherwise byte-for-byte identical
/// `XFilterController` classes (grocery/packing/admin/products/wishlist)
/// that differed only in their generated name.
///
/// Copied from [ListFilterController].
@ProviderFor(ListFilterController)
const listFilterControllerProvider = ListFilterControllerFamily();

/// One filter-state notifier shared by every list screen, keyed by
/// [ListType] — replaces five otherwise byte-for-byte identical
/// `XFilterController` classes (grocery/packing/admin/products/wishlist)
/// that differed only in their generated name.
///
/// Copied from [ListFilterController].
class ListFilterControllerFamily extends Family<ItemFilterState> {
  /// One filter-state notifier shared by every list screen, keyed by
  /// [ListType] — replaces five otherwise byte-for-byte identical
  /// `XFilterController` classes (grocery/packing/admin/products/wishlist)
  /// that differed only in their generated name.
  ///
  /// Copied from [ListFilterController].
  const ListFilterControllerFamily();

  /// One filter-state notifier shared by every list screen, keyed by
  /// [ListType] — replaces five otherwise byte-for-byte identical
  /// `XFilterController` classes (grocery/packing/admin/products/wishlist)
  /// that differed only in their generated name.
  ///
  /// Copied from [ListFilterController].
  ListFilterControllerProvider call(ListType listType) {
    return ListFilterControllerProvider(listType);
  }

  @override
  ListFilterControllerProvider getProviderOverride(
    covariant ListFilterControllerProvider provider,
  ) {
    return call(provider.listType);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'listFilterControllerProvider';
}

/// One filter-state notifier shared by every list screen, keyed by
/// [ListType] — replaces five otherwise byte-for-byte identical
/// `XFilterController` classes (grocery/packing/admin/products/wishlist)
/// that differed only in their generated name.
///
/// Copied from [ListFilterController].
class ListFilterControllerProvider
    extends
        AutoDisposeNotifierProviderImpl<ListFilterController, ItemFilterState> {
  /// One filter-state notifier shared by every list screen, keyed by
  /// [ListType] — replaces five otherwise byte-for-byte identical
  /// `XFilterController` classes (grocery/packing/admin/products/wishlist)
  /// that differed only in their generated name.
  ///
  /// Copied from [ListFilterController].
  ListFilterControllerProvider(ListType listType)
    : this._internal(
        () => ListFilterController()..listType = listType,
        from: listFilterControllerProvider,
        name: r'listFilterControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$listFilterControllerHash,
        dependencies: ListFilterControllerFamily._dependencies,
        allTransitiveDependencies:
            ListFilterControllerFamily._allTransitiveDependencies,
        listType: listType,
      );

  ListFilterControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.listType,
  }) : super.internal();

  final ListType listType;

  @override
  ItemFilterState runNotifierBuild(covariant ListFilterController notifier) {
    return notifier.build(listType);
  }

  @override
  Override overrideWith(ListFilterController Function() create) {
    return ProviderOverride(
      origin: this,
      override: ListFilterControllerProvider._internal(
        () => create()..listType = listType,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        listType: listType,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<ListFilterController, ItemFilterState>
  createElement() {
    return _ListFilterControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ListFilterControllerProvider && other.listType == listType;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, listType.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ListFilterControllerRef
    on AutoDisposeNotifierProviderRef<ItemFilterState> {
  /// The parameter `listType` of this provider.
  ListType get listType;
}

class _ListFilterControllerProviderElement
    extends
        AutoDisposeNotifierProviderElement<
          ListFilterController,
          ItemFilterState
        >
    with ListFilterControllerRef {
  _ListFilterControllerProviderElement(super.provider);

  @override
  ListType get listType => (origin as ListFilterControllerProvider).listType;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
