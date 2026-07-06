// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$pinRepositoryHash() => r'21b54ba6135acb4cc69ec5f2af502b762b7e2314';

/// See also [pinRepository].
@ProviderFor(pinRepository)
final pinRepositoryProvider = AutoDisposeProvider<PinRepository>.internal(
  pinRepository,
  name: r'pinRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$pinRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PinRepositoryRef = AutoDisposeProviderRef<PinRepository>;
String _$authControllerHash() => r'e644d56ee2457ad664940d8a9a7d59b3efbad665';

/// Drives the PIN gate: whether a PIN exists, and whether it's currently
/// unlocked for this session.
///
/// Copied from [AuthController].
@ProviderFor(AuthController)
final authControllerProvider =
    AutoDisposeAsyncNotifierProvider<AuthController, AuthStatus>.internal(
      AuthController.new,
      name: r'authControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$authControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AuthController = AutoDisposeAsyncNotifier<AuthStatus>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
