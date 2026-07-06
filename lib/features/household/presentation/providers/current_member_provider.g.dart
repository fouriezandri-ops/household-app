// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'current_member_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$memberSelectionRepositoryHash() =>
    r'ef2e5ad651a0ef0675d91f1796736f52231457c4';

/// See also [memberSelectionRepository].
@ProviderFor(memberSelectionRepository)
final memberSelectionRepositoryProvider =
    AutoDisposeProvider<MemberSelectionRepository>.internal(
      memberSelectionRepository,
      name: r'memberSelectionRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$memberSelectionRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MemberSelectionRepositoryRef =
    AutoDisposeProviderRef<MemberSelectionRepository>;
String _$householdMembersHash() => r'fdc76d93515248c8766977d985c7d457c36b035a';

/// The two household members, seeding `/households/default` and their
/// `/users/{uid}` docs on first read if they don't exist yet (see
/// [HouseholdRepository.ensureSeeded]).
///
/// Copied from [householdMembers].
@ProviderFor(householdMembers)
final householdMembersProvider =
    AutoDisposeStreamProvider<List<HouseholdMember>>.internal(
      householdMembers,
      name: r'householdMembersProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$householdMembersHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HouseholdMembersRef =
    AutoDisposeStreamProviderRef<List<HouseholdMember>>;
String _$currentMemberControllerHash() =>
    r'cd72cec715fdfeb95a01241efb88396ba99c34c4';

/// Which household member this device belongs to — a local preference set
/// once via [PickMemberScreen], not identity/auth.
///
/// Copied from [CurrentMemberController].
@ProviderFor(CurrentMemberController)
final currentMemberControllerProvider =
    AutoDisposeAsyncNotifierProvider<CurrentMemberController, String?>.internal(
      CurrentMemberController.new,
      name: r'currentMemberControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$currentMemberControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CurrentMemberController = AutoDisposeAsyncNotifier<String?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
