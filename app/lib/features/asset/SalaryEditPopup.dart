import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/db/WealthtrackerRepository.dart';
import '../../core/models/Month.dart';
import '../../core/sync/WealthtrackerSync.dart' as WealthtrackerSync;
import '../../l10n/l10n.dart';
import '../Providers.dart';

class SalaryEditPopup extends StatefulWidget {
  final WidgetRef ref;
  final DateTime date;
  final Month? initialSalary;

  const SalaryEditPopup({
    super.key,
    required this.ref,
    required this.date,
    this.initialSalary,
  });

  @override
  State<SalaryEditPopup> createState() => _SalaryEditPopupState();
}

class _SalaryEditPopupState extends State<SalaryEditPopup> {
  late TextEditingController _positionController;
  late TextEditingController _companyController;
  late TextEditingController _salaryController;
  late TextEditingController _bonusController;
  late TextEditingController _commentController;

  @override
  void initState() {
    super.initState();
    final s = widget.initialSalary;
    _positionController = TextEditingController(text: s?.position ?? '');
    _companyController = TextEditingController(text: s?.company ?? '');
    _salaryController = TextEditingController(
        text: s?.salary != null ? s!.salary.toString() : '');
    _bonusController = TextEditingController(
        text: s?.bonus != null ? s!.bonus.toString() : '');
    _commentController = TextEditingController(text: s?.salaryComment ?? '');
  }

  @override
  void dispose() {
    _positionController.dispose();
    _companyController.dispose();
    _salaryController.dispose();
    _bonusController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final repo = await widget.ref.read(wealthtrackerRepositoryProvider.future);
    final yearMonth = widget.date.year * 100 + widget.date.month;
    final existing = await repo.comments.loadByMonth(yearMonth);
    final comment = Month(
      id: existing?.id ?? WealthtrackerRepository.generateId(),
      yearMonth: yearMonth,
      comment: existing?.comment ?? '',
      salary: double.tryParse(_salaryController.text),
      bonus: double.tryParse(_bonusController.text),
      position: _positionController.text.trim().isEmpty
          ? null
          : _positionController.text.trim(),
      company: _companyController.text.trim().isEmpty
          ? null
          : _companyController.text.trim(),
      salaryComment: _commentController.text.trim().isEmpty
          ? null
          : _commentController.text.trim(),
    );
    await repo.comments.save(comment);
    WealthtrackerSync.uploadComment(widget.ref, comment);
    if (mounted) Navigator.pop(context, true);
  }

  Future<void> _delete() async {
    final s = widget.initialSalary;
    if (s == null) return;
    final repo = await widget.ref.read(wealthtrackerRepositoryProvider.future);
    // Clear salary fields, preserve comment text
    final cleared = Month(
      id: s.id,
      yearMonth: s.yearMonth,
      comment: s.comment,
    );
    await repo.comments.save(cleared);
    WealthtrackerSync.uploadComment(widget.ref, cleared);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('MMMM yyyy').format(widget.date);
    final hasExisting = widget.initialSalary?.hasSalaryData == true;

    return AlertDialog(
      title: Text(context.l10n.salaryFor(formattedDate)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _positionController,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      label: Text(context.l10n.position),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _companyController,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      label: Text('Company'),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _salaryController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^[0-9]+\.?[0-9]*$')),
                    ],
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      label: Text(context.l10n.salary),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _bonusController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^[0-9]+\.?[0-9]*$')),
              ],
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                label: Text(context.l10n.bonus),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _commentController,
              keyboardType: TextInputType.multiline,
              minLines: 3,
              maxLines: 6,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                label: Text(context.l10n.commentLabel),
              ),
            ),
          ],
        ),
      ),
      actions: [
        if (hasExisting)
          TextButton(
            onPressed: _delete,
            child: Text(
              context.l10n.delete,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(context.l10n.cancel),
        ),
        TextButton(
          onPressed: _save,
          child: Text(context.l10n.save),
        ),
      ],
    );
  }
}
