import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/l10n_extensions.dart';
import '../../core/l10n/localize_error.dart';
import '../../database/app_database.dart';
import '../../providers/data_providers.dart';
import '../../providers/database_provider.dart';
import '../../repositories/user_repository.dart';
import '../../shared/widgets/app_card.dart';
import 'widgets/person_row.dart';

class PeopleScreen extends ConsumerStatefulWidget {
  const PeopleScreen({super.key});

  @override
  ConsumerState<PeopleScreen> createState() => _PeopleScreenState();
}

class _PeopleScreenState extends ConsumerState<PeopleScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _addPerson() async {
    final l10n = context.l10n;
    final name = await showPersonNameDialog(
      context,
      title: l10n.peopleAddPerson,
      hint: l10n.peopleAddHint,
    );
    if (name == null || name.isEmpty || !mounted) return;
    try {
      await createUser(ref.read(databaseProvider), name);
    } on UserNameTakenException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(localizeError(context, e))));
      }
    }
  }

  Future<void> _editPerson(User person) async {
    final l10n = context.l10n;
    final name = await showPersonNameDialog(
      context,
      title: l10n.peopleEditName,
      hint: person.name,
      initialValue: person.name,
    );
    if (name == null || name.isEmpty || name == person.name || !mounted) {
      return;
    }
    try {
      await updateUserName(ref.read(databaseProvider), person.id, name);
    } on UserNameTakenException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(localizeError(context, e))));
      }
    }
  }

  Future<void> _deletePerson(User person) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ctx.l10n.peopleDeleteTitle),
        content: Text(ctx.l10n.peopleDeleteBody(person.name)),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text(ctx.l10n.commonCancel),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text(ctx.l10n.commonDelete),
                ),
              ),
            ],
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await deleteUser(ref.read(databaseProvider), person.id);
    } on UserDeleteBlockedException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(localizeError(context, e))));
      }
    }
  }

  List<User> _filteredUsers(List<User> users) {
    final query = _searchController.text.trim().toLowerCase();
    final sorted = [...users]
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    if (query.isEmpty) return sorted;
    return sorted
        .where((user) => user.name.toLowerCase().contains(query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final allUsers = ref.watch(usersStreamProvider).value ?? [];
    final filteredUsers = _filteredUsers(allUsers);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.peopleTitle),
        actions: [
          IconButton(
            onPressed: _addPerson,
            icon: const Icon(Icons.person_add_alt_1_outlined),
            tooltip: l10n.peopleAddPerson,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Text(
            l10n.peopleIntro,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: l10n.peopleSearchHint,
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _searchController.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                    ),
            ),
            onChanged: (_) => setState(() {}),
            textInputAction: TextInputAction.search,
          ),
          const SizedBox(height: 16),
          if (allUsers.isEmpty)
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Text(
                l10n.peopleEmpty,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            )
          else if (filteredUsers.isEmpty)
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Row(
                children: [
                  Icon(
                    Icons.search_off_rounded,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.peopleNoMatch,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  for (var i = 0; i < filteredUsers.length; i++) ...[
                    PersonRow(
                      user: filteredUsers[i],
                      onEdit: () => _editPerson(filteredUsers[i]),
                      onDelete: () => _deletePerson(filteredUsers[i]),
                    ),
                    if (i < filteredUsers.length - 1) const Divider(height: 1),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}
