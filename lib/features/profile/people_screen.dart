import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    final name = await showPersonNameDialog(
      context,
      title: 'Add person',
      hint: 'e.g. Alice',
    );
    if (name == null || name.isEmpty || !mounted) return;
    await createUser(ref.read(databaseProvider), name);
  }

  Future<void> _editPerson(User person) async {
    final name = await showPersonNameDialog(
      context,
      title: 'Edit name',
      hint: person.name,
      initialValue: person.name,
    );
    if (name == null || name.isEmpty || name == person.name || !mounted) {
      return;
    }
    await updateUserName(ref.read(databaseProvider), person.id, name);
  }

  Future<void> _deletePerson(User person) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete person?'),
        content: Text(
          'Remove ${person.name} from your people list? '
          'This cannot be undone.',
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Delete'),
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
        ).showSnackBar(SnackBar(content: Text(e.message)));
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
    final allUsers = ref.watch(usersStreamProvider).value ?? [];
    final filteredUsers = _filteredUsers(allUsers);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('People'),
        actions: [
          IconButton(
            onPressed: _addPerson,
            icon: const Icon(Icons.person_add_alt_1_outlined),
            tooltip: 'Add person',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Text(
            'Everyone added across your groups.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by name',
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
                'No people yet. Tap + to add someone.',
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
                      'No people match your search.',
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
                    if (i < filteredUsers.length - 1)
                      const Divider(height: 1),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}
