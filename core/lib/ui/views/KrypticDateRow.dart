import 'package:flutter/material.dart';

class KrypticDateRow extends StatelessWidget {
  final String title;
  final DateTime? date;
  final ValueChanged<DateTime?> onDatePicked;

  const KrypticDateRow({super.key, required this.title, required this.date, required this.onDatePicked});

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(context: context, initialDate: date ?? now, firstDate: DateTime(2000), lastDate: DateTime(2100));
    if (picked != null) {
      onDatePicked(picked);
    }
  }

  Future<void> _clearDate(BuildContext context) async {
    onDatePicked(null);
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: Text(date != null ? "${date!.toLocal()}".split(' ')[0] : 'No date selected'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FilledButton(child: const Icon(Icons.clear), onPressed: () => _clearDate(context)),
          SizedBox(width: 10),
          FilledButton(child: const Icon(Icons.calendar_today), onPressed: () => _pickDate(context)),
        ],
      ),
      onTap: () => _pickDate(context),
    );
  }
}
