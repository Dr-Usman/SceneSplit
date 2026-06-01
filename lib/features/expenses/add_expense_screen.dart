import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/widgets/widgets.dart';
import '../../providers/providers.dart';
import '../../core/enums/split_type.dart';
import '../../models/user_model.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(addExpenseFormProvider);
    final usersAsync = ref.watch(userListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Expense'),
        actions: [
          TextButton(
            onPressed: formState.isValid ? _saveExpense : null,
            child: const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CustomTextField(
              label: 'Description',
              hint: 'What was this expense for?',
              controller: _descriptionController,
              onChanged: (value) {
                ref.read(addExpenseFormProvider.notifier).setDescription(value);
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Amount',
              hint: '0.00',
              controller: _amountController,
              keyboardType: TextInputType.number,
              prefix: const Text('\$ '),
              onChanged: (value) {
                final amount = double.tryParse(value) ?? 0;
                ref.read(addExpenseFormProvider.notifier).setAmount(amount);
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an amount';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'Please enter a valid amount';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
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
                return DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Paid by',
                    border: OutlineInputBorder(),
                  ),
                  initialValue: formState.payerId,
                  items: users.map((user) {
                    return DropdownMenuItem(
                      value: user.id,
                      child: Text(user.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      ref
                          .read(addExpenseFormProvider.notifier)
                          .setPayerId(value);
                    }
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Split Type',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SegmentedButton<SplitType>(
              segments: SplitType.values.map((type) {
                return ButtonSegment(
                  value: type,
                  label: Text(type.displayName),
                );
              }).toList(),
              selected: {formState.splitType},
              onSelectionChanged: (selection) {
                if (selection.isNotEmpty) {
                  ref
                      .read(addExpenseFormProvider.notifier)
                      .setSplitType(selection.first);
                }
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Participants',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Select who should split this expense',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            usersAsync.when(
              loading: () => const LoadingIndicator(),
              error: (error, stack) => Text('Error: $error'),
              data: (users) {
                if (users.isEmpty) {
                  return const SizedBox.shrink();
                }
                return _buildParticipantList(users, formState);
              },
            ),
            if (formState.selectedParticipantIds.isNotEmpty) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Summary',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${formState.selectedParticipantIds.length} people × ${formState.equalSplitDisplay}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildParticipantList(
    List<UserModel> users,
    AddExpenseFormState formState,
  ) {
    return Column(
      children: users.map((user) {
        final isSelected = formState.selectedParticipantIds.contains(user.id);
        return CheckboxListTile(
          value: isSelected,
          onChanged: (value) {
            ref
                .read(addExpenseFormProvider.notifier)
                .toggleParticipant(user.id);
          },
          title: Text(user.name),
          subtitle: isSelected && formState.splitType == SplitType.equal
              ? Text(formState.equalSplitDisplay)
              : null,
          secondary: AvatarWidget(name: user.name, radius: 16),
        );
      }).toList(),
    );
  }

  void _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;

    final formState = ref.read(addExpenseFormProvider);
    final splits = ref.read(addExpenseFormProvider.notifier).buildSplits('');

    await ref
        .read(expenseListProvider.notifier)
        .addExpense(
          description: formState.description,
          amount: formState.amount,
          paidBy: formState.payerId!,
          groupId: formState.groupId,
          splitType: formState.splitType,
          splits: splits,
        );

    ref.read(addExpenseFormProvider.notifier).reset();

    if (mounted) {
      Navigator.pop(context);
    }
  }
}
