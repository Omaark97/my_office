import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../domain/received_date.dart';
import '../../domain/transaction.dart';
import '../../domain/transaction_draft.dart';
import '../../domain/transaction_type.dart';
import '../formatters.dart';
import '../load_error_message.dart';
import '../text_direction.dart';
import '../transaction_icons.dart';
import '../transaction_providers.dart';
import '../widgets/transaction_type_picker.dart';

class TransactionFormScreen extends ConsumerStatefulWidget {
  const TransactionFormScreen({super.key, this.initial});

  final Transaction? initial;

  @override
  ConsumerState<TransactionFormScreen> createState() =>
      _TransactionFormScreenState();
}

class _TransactionFormScreenState extends ConsumerState<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _typeFieldKey = GlobalKey<FormFieldState<TransactionType>>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late DateTime _receivedDay;
  bool _saving = false;

  bool get _isEditing => widget.initial != null;

  DateTime get _today => calendarDay(ref.read(clockProvider)());

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _nameController = TextEditingController(text: initial?.clientName ?? '');
    _phoneController = TextEditingController(text: initial?.clientPhone ?? '');
    _receivedDay = initial != null ? calendarDay(initial.dateReceived) : _today;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _receivedDay,
      firstDate: earliestReceivedDay,
      lastDate: _today,
    );
    if (picked != null) setState(() => _receivedDay = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final draft = TransactionDraft(
      type: _typeFieldKey.currentState!.value!,
      clientName: _nameController.text,
      clientPhone: _phoneController.text,
      dateReceived: receivedDateFor(_receivedDay),
    );
    final notifier = ref.read(transactionListProvider.notifier);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _saving = true);
    try {
      final initial = widget.initial;
      if (initial != null) {
        await notifier.updateDetails(initial.id, draft);
        if (!mounted) return;
        messenger.showSnackBar(const SnackBar(content: Text('Changes saved')));
        context.pop();
      } else {
        final id = await notifier.addTransaction(draft);
        if (!mounted) return;
        context.pushReplacement(AppRoutes.transaction(id));
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            loadErrorMessage(
              error,
              fallback: 'Could not save the transaction. Please try again.',
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Transaction' : 'New Transaction'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionCard(
                title: 'CLIENT',
                children: [
                  TextFormField(
                    controller: _nameController,
                    enabled: !_saving,
                    textDirection: textDirectionFor(_nameController.text),
                    textCapitalization: TextCapitalization.words,
                    autocorrect: false,
                    textInputAction: TextInputAction.next,
                    inputFormatters: [LengthLimitingTextInputFormatter(100)],
                    decoration: const InputDecoration(
                      labelText: 'Client name',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    onChanged: (_) => setState(() {}),
                    validator: (value) => isValidClientName(value ?? '')
                        ? null
                        : "Enter the client's name",
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _phoneController,
                    enabled: !_saving,
                    textDirection: TextDirection.ltr,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp('[0-9\u0660-\u0669\u06F0-\u06F9+()\\- ]'),
                      ),
                      LengthLimitingTextInputFormatter(25),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Phone (optional)',
                      hintText: '03 123 456',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'TRANSACTION',
                children: [
                  FormField<TransactionType>(
                    key: _typeFieldKey,
                    initialValue: widget.initial?.type,
                    validator: (type) =>
                        type == null ? 'Choose a transaction type' : null,
                    builder: (field) {
                      final type = field.value;
                      return InkWell(
                        borderRadius: BorderRadius.circular(4),
                        onTap: _saving
                            ? null
                            : () async {
                                final picked = await showTransactionTypePicker(
                                  context,
                                  selected: type,
                                );
                                if (picked != null) field.didChange(picked);
                              },
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Transaction type',
                            prefixIcon: Icon(
                              type?.icon ?? Icons.category_outlined,
                              color: Colors.teal,
                            ),
                            suffixIcon: const Icon(Icons.expand_more),
                            errorText: field.errorText,
                          ),
                          child: Text(
                            type?.label ?? 'Choose a type',
                            style: type == null
                                ? TextStyle(color: Colors.grey.shade500)
                                : null,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    borderRadius: BorderRadius.circular(4),
                    onTap: _saving ? null : _pickDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date received',
                        prefixIcon: Icon(
                          Icons.calendar_today,
                          color: Colors.teal,
                        ),
                        suffixIcon: Icon(Icons.edit_calendar_outlined),
                      ),
                      child: Text(formatDate(_receivedDay)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.teal.shade200,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _isEditing ? 'Save Changes' : 'Save Transaction',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}
