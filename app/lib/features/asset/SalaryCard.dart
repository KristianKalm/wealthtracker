import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kryptic_core/kryptic_core.dart';

import '../../core/models/Salary.dart';
import '../../l10n/l10n.dart';

class SalaryCard extends StatelessWidget {
  final KrypticColors colors;
  final Salary? salary;
  final VoidCallback onTap;
  final VoidCallback? onCopyPreviousMonth;

  const SalaryCard({
    super.key,
    required this.colors,
    required this.salary,
    required this.onTap,
    this.onCopyPreviousMonth,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.cardBackgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: salary == null ? _emptyContent(context) : _filledContent(context),
      ),
    );
  }

  Widget _emptyContent(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.work_outline, size: 18, color: colors.secondaryText),
        const SizedBox(width: 8),
        Text(
          context.l10n.addSalary,
          style: TextStyle(color: colors.secondaryText, fontSize: 14),
        ),
        if (onCopyPreviousMonth != null) ...[
          const Spacer(),
          TextButton(
            onPressed: onCopyPreviousMonth,
            style: TextButton.styleFrom(
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              context.l10n.copyPreviousMonth,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ],
    );
  }

  Widget _filledContent(BuildContext context) {
    final s = salary!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.work_outline, size: 16, color: colors.secondaryText),
            const SizedBox(width: 6),
            Text(
              context.l10n.salary,
              style: TextStyle(
                color: colors.primaryText,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            if (s.company != null && s.company!.isNotEmpty)
              Text(
                s.company!,
                style: TextStyle(color: colors.secondaryText, fontSize: 13),
              ),
            if (s.position != null && s.position!.isNotEmpty) ...[
              if (s.company != null && s.company!.isNotEmpty)
                Text(' · ', style: TextStyle(color: colors.secondaryText, fontSize: 13)),
              Text(
                s.position!,
                style: TextStyle(color: colors.secondaryText, fontSize: 13),
              ),
            ],
            if (onCopyPreviousMonth != null) ...[
              const SizedBox(width: 8),
              TextButton(
                onPressed: onCopyPreviousMonth,
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  context.l10n.copyPreviousMonth,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ],
        ),
        if (s.netSalary != null || s.grossSalary != null || s.bonusNet != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              if (s.netSalary != null)
                _salaryRow(context, context.l10n.netSalary, s.netSalary!),
              if (s.netSalary != null && s.grossSalary != null)
                const SizedBox(width: 24),
              if (s.grossSalary != null)
                _salaryRow(context, context.l10n.grossSalary, s.grossSalary!),
              if (s.bonusNet != null && (s.netSalary != null || s.grossSalary != null))
                const SizedBox(width: 24),
              if (s.bonusNet != null)
                _salaryRow(context, context.l10n.bonusNet, s.bonusNet!),
            ],
          ),
        ],
        if (s.comment != null && s.comment!.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            s.comment!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: colors.secondaryText, fontSize: 13),
          ),
        ],
      ],
    );
  }

  Widget _salaryRow(BuildContext context, String label, double value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          NumberFormat.compact().format(value),
          style: TextStyle(
            color: colors.primaryText,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: colors.secondaryText, fontSize: 11),
        ),
      ],
    );
  }
}
