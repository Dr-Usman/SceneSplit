// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$expenseListHash() => r'55895e319d6e87da7d662e66a482ffbec8aa8c87';

/// See also [ExpenseList].
@ProviderFor(ExpenseList)
final expenseListProvider =
    AutoDisposeStreamNotifierProvider<ExpenseList, List<ExpenseModel>>.internal(
      ExpenseList.new,
      name: r'expenseListProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$expenseListHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ExpenseList = AutoDisposeStreamNotifier<List<ExpenseModel>>;
String _$groupExpensesHash() => r'f876bebe5074572c9b946821bfa04cab83afef14';

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

abstract class _$GroupExpenses
    extends BuildlessAutoDisposeStreamNotifier<List<ExpenseModel>> {
  late final String groupId;

  Stream<List<ExpenseModel>> build(String groupId);
}

/// See also [GroupExpenses].
@ProviderFor(GroupExpenses)
const groupExpensesProvider = GroupExpensesFamily();

/// See also [GroupExpenses].
class GroupExpensesFamily extends Family<AsyncValue<List<ExpenseModel>>> {
  /// See also [GroupExpenses].
  const GroupExpensesFamily();

  /// See also [GroupExpenses].
  GroupExpensesProvider call(String groupId) {
    return GroupExpensesProvider(groupId);
  }

  @override
  GroupExpensesProvider getProviderOverride(
    covariant GroupExpensesProvider provider,
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
  String? get name => r'groupExpensesProvider';
}

/// See also [GroupExpenses].
class GroupExpensesProvider
    extends
        AutoDisposeStreamNotifierProviderImpl<
          GroupExpenses,
          List<ExpenseModel>
        > {
  /// See also [GroupExpenses].
  GroupExpensesProvider(String groupId)
    : this._internal(
        () => GroupExpenses()..groupId = groupId,
        from: groupExpensesProvider,
        name: r'groupExpensesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$groupExpensesHash,
        dependencies: GroupExpensesFamily._dependencies,
        allTransitiveDependencies:
            GroupExpensesFamily._allTransitiveDependencies,
        groupId: groupId,
      );

  GroupExpensesProvider._internal(
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
  Stream<List<ExpenseModel>> runNotifierBuild(
    covariant GroupExpenses notifier,
  ) {
    return notifier.build(groupId);
  }

  @override
  Override overrideWith(GroupExpenses Function() create) {
    return ProviderOverride(
      origin: this,
      override: GroupExpensesProvider._internal(
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
  AutoDisposeStreamNotifierProviderElement<GroupExpenses, List<ExpenseModel>>
  createElement() {
    return _GroupExpensesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupExpensesProvider && other.groupId == groupId;
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
mixin GroupExpensesRef
    on AutoDisposeStreamNotifierProviderRef<List<ExpenseModel>> {
  /// The parameter `groupId` of this provider.
  String get groupId;
}

class _GroupExpensesProviderElement
    extends
        AutoDisposeStreamNotifierProviderElement<
          GroupExpenses,
          List<ExpenseModel>
        >
    with GroupExpensesRef {
  _GroupExpensesProviderElement(super.provider);

  @override
  String get groupId => (origin as GroupExpensesProvider).groupId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
