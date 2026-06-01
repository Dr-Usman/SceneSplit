import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/widgets/widgets.dart';
import '../../providers/providers.dart';
import '../../core/enums/group_type.dart';
import '../../models/user_model.dart';

class CreateGroupScreen extends ConsumerStatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  ConsumerState<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends ConsumerState<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  GroupType _selectedType = GroupType.custom;
  final Set<String> _selectedMemberIds = {};

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(userListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Group'),
        actions: [TextButton(onPressed: _saveGroup, child: const Text('Save'))],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CustomTextField(
              label: 'Group Name',
              hint: 'e.g., Trip to Paris',
              controller: _nameController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a group name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Description (Optional)',
              hint: 'What is this group for?',
              controller: _descriptionController,
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            Text(
              'Group Type',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: GroupType.values.map((type) {
                final isSelected = _selectedType == type;
                return ChoiceChip(
                  label: Text('${type.icon} ${type.displayName}'),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedType = type;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Text(
              'Add Members',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            usersAsync.when(
              loading: () => const LoadingIndicator(),
              error: (error, stack) => Text('Error: $error'),
              data: (users) {
                if (users.isEmpty) {
                  return const Text(
                    'No users available. Create users first.',
                    style: TextStyle(color: Colors.grey),
                  );
                }
                return Column(
                  children: users
                      .map((user) => _buildUserCheckbox(user))
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCheckbox(UserModel user) {
    final isSelected = _selectedMemberIds.contains(user.id);
    return CheckboxListTile(
      value: isSelected,
      onChanged: (value) {
        setState(() {
          if (value == true) {
            _selectedMemberIds.add(user.id);
          } else {
            _selectedMemberIds.remove(user.id);
          }
        });
      },
      title: Text(user.name),
      subtitle: user.email != null ? Text(user.email!) : null,
      secondary: AvatarWidget(name: user.name, radius: 16),
    );
  }

  void _saveGroup() async {
    if (!_formKey.currentState!.validate()) return;

    await ref
        .read(groupListProvider.notifier)
        .addGroup(
          name: _nameController.text,
          description: _descriptionController.text.isNotEmpty
              ? _descriptionController.text
              : null,
          type: _selectedType,
          memberIds: _selectedMemberIds.toList(),
        );

    if (mounted) {
      Navigator.pop(context);
    }
  }
}
