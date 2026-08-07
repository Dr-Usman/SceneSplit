import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/l10n_extensions.dart';
import '../../core/l10n/localize_error.dart';
import '../../database/app_database.dart';
import '../../providers/data_providers.dart';
import '../../providers/database_provider.dart';
import '../../providers/person_detail_provider.dart';
import '../../repositories/user_repository.dart';
import '../../shared/widgets/app_card.dart';
import 'person_detail_screen.dart';
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
    final sceneCounts = ref.watch(personSceneCountProvider);
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
          else ...[
            if (filteredUsers.any((u) => !u.isCurrentUser)) ...[
              Row(
                children: [
                  Icon(
                    Icons.swipe_left_rounded,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.peopleSwipeHint,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  for (var i = 0; i < filteredUsers.length; i++) ...[
                    PersonRow(
                      user: filteredUsers[i],
                      subtitle: l10n.peopleSceneCount(
                        sceneCounts[filteredUsers[i].id] ?? 0,
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                PersonDetailScreen(userId: filteredUsers[i].id),
                          ),
                        );
                      },
                      onEdit: () => editPerson(context, ref, filteredUsers[i]),
                      onDelete: () =>
                          deletePerson(context, ref, filteredUsers[i]),
                    ),
                    if (i < filteredUsers.length - 1) const Divider(height: 1),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
