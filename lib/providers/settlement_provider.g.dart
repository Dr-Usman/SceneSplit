// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settlement_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$settlementListHash() => r'f0be9e454f1d7eb4c2d801713423280dfb3e4218';

/// See also [SettlementList].
@ProviderFor(SettlementList)
final settlementListProvider =
    AutoDisposeStreamNotifierProvider<
      SettlementList,
      List<SettlementModel>
    >.internal(
      SettlementList.new,
      name: r'settlementListProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$settlementListHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SettlementList = AutoDisposeStreamNotifier<List<SettlementModel>>;
String _$groupSettlementsHash() => r'ba5f1d4a14faa715dfff5b0ff5ad5af23604bc3d';

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

abstract class _$GroupSettlements
    extends BuildlessAutoDisposeStreamNotifier<List<SettlementModel>> {
  late final String groupId;

  Stream<List<SettlementModel>> build(String groupId);
}

/// See also [GroupSettlements].
@ProviderFor(GroupSettlements)
const groupSettlementsProvider = GroupSettlementsFamily();

/// See also [GroupSettlements].
class GroupSettlementsFamily extends Family<AsyncValue<List<SettlementModel>>> {
  /// See also [GroupSettlements].
  const GroupSettlementsFamily();

  /// See also [GroupSettlements].
  GroupSettlementsProvider call(String groupId) {
    return GroupSettlementsProvider(groupId);
  }

  @override
  GroupSettlementsProvider getProviderOverride(
    covariant GroupSettlementsProvider provider,
  ) {
    return call(provider.groupId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'groupSettlementsProvider';
}

/// See also [GroupSettlements].
class GroupSettlementsProvider
    extends
        AutoDisposeStreamNotifierProviderImpl<
          GroupSettlements,
          List<SettlementModel>
        > {
  /// See also [GroupSettlements].
  GroupSettlementsProvider(String groupId)
    : this._internal(
        () => GroupSettlements()..groupId = groupId,
        from: groupSettlementsProvider,
        name: r'groupSettlementsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$groupSettlementsHash,
        dependencies: GroupSettlementsFamily._dependencies,
        allTransitiveDependencies:
            GroupSettlementsFamily._allTransitiveDependencies,
        groupId: groupId,
      );

  GroupSettlementsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.groupId,
  }) : super.internal();

  final String groupId;

  @override
  Stream<List<SettlementModel>> runNotifierBuild(
    covariant GroupSettlements notifier,
  ) {
    return notifier.build(groupId);
  }

  @override
  Override overrideWith(GroupSettlements Function() create) {
    return ProviderOverride(
      origin: this,
      override: GroupSettlementsProvider._internal(
        () => create()..groupId = groupId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        groupId: groupId,
      ),
    );
  }

  @override
  AutoDisposeStreamNotifierProviderElement<
    GroupSettlements,
    List<SettlementModel>
  >
  createElement() {
    return _GroupSettlementsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupSettlementsProvider && other.groupId == groupId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, groupId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin GroupSettlementsRef
    on AutoDisposeStreamNotifierProviderRef<List<SettlementModel>> {
  /// The parameter `groupId` of this provider.
  String get groupId;
}

class _GroupSettlementsProviderElement
    extends
        AutoDisposeStreamNotifierProviderElement<
          GroupSettlements,
          List<SettlementModel>
        >
    with GroupSettlementsRef {
  _GroupSettlementsProviderElement(super.provider);

  @override
  String get groupId => (origin as GroupSettlementsProvider).groupId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
