// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$dashboardDataHash() => r'a99f9876121d94fecebd19e5f39d9404a1527d24';

/// See also [DashboardData].
@ProviderFor(DashboardData)
final dashboardDataProvider =
    AutoDisposeAsyncNotifierProvider<
      DashboardData,
      DashboardDataModel
    >.internal(
      DashboardData.new,
      name: r'dashboardDataProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$dashboardDataHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$DashboardData = AutoDisposeAsyncNotifier<DashboardDataModel>;
String _$groupDashboardHash() => r'89235436f62bf537f0cf5f0e7a486f433def2e6c';

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

abstract class _$GroupDashboard
    extends BuildlessAutoDisposeAsyncNotifier<DashboardDataModel> {
  late final String groupId;

  FutureOr<DashboardDataModel> build(String groupId);
}

/// See also [GroupDashboard].
@ProviderFor(GroupDashboard)
const groupDashboardProvider = GroupDashboardFamily();

/// See also [GroupDashboard].
class GroupDashboardFamily extends Family<AsyncValue<DashboardDataModel>> {
  /// See also [GroupDashboard].
  const GroupDashboardFamily();

  /// See also [GroupDashboard].
  GroupDashboardProvider call(String groupId) {
    return GroupDashboardProvider(groupId);
  }

  @override
  GroupDashboardProvider getProviderOverride(
    covariant GroupDashboardProvider provider,
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
  String? get name => r'groupDashboardProvider';
}

/// See also [GroupDashboard].
class GroupDashboardProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          GroupDashboard,
          DashboardDataModel
        > {
  /// See also [GroupDashboard].
  GroupDashboardProvider(String groupId)
    : this._internal(
        () => GroupDashboard()..groupId = groupId,
        from: groupDashboardProvider,
        name: r'groupDashboardProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$groupDashboardHash,
        dependencies: GroupDashboardFamily._dependencies,
        allTransitiveDependencies:
            GroupDashboardFamily._allTransitiveDependencies,
        groupId: groupId,
      );

  GroupDashboardProvider._internal(
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
  FutureOr<DashboardDataModel> runNotifierBuild(
    covariant GroupDashboard notifier,
  ) {
    return notifier.build(groupId);
  }

  @override
  Override overrideWith(GroupDashboard Function() create) {
    return ProviderOverride(
      origin: this,
      override: GroupDashboardProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<GroupDashboard, DashboardDataModel>
  createElement() {
    return _GroupDashboardProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupDashboardProvider && other.groupId == groupId;
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
mixin GroupDashboardRef
    on AutoDisposeAsyncNotifierProviderRef<DashboardDataModel> {
  /// The parameter `groupId` of this provider.
  String get groupId;
}

class _GroupDashboardProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          GroupDashboard,
          DashboardDataModel
        >
    with GroupDashboardRef {
  _GroupDashboardProviderElement(super.provider);

  @override
  String get groupId => (origin as GroupDashboardProvider).groupId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
