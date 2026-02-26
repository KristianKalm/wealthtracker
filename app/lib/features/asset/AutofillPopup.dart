import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../l10n/l10n.dart';

enum _AutofillMode { fixed, percentage, percentageYearly, loan }

int addMonths(int yearMonth, int months) {
  int year = yearMonth ~/ 100;
  int month = yearMonth % 100;
  month += months;
  while (month > 12) {
    month -= 12;
    year++;
  }
  while (month < 1) {
    month += 12;
    year--;
  }
  return year * 100 + month;
}

class _NumericFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final t = newValue.text;
    if (t.isEmpty || t == '-' || RegExp(r'^-?[0-9]+(\.[0-9]*)?$').hasMatch(t)) {
      return newValue;
    }
    return oldValue;
  }
}

class AutofillPopup extends StatefulWidget {
  final double startValue;
  final int startYearMonth;

  const AutofillPopup({
    super.key,
    required this.startValue,
    required this.startYearMonth,
  });

  static Future<Map<String, double>?> show(
    BuildContext context, {
    required double startValue,
    required int startYearMonth,
  }) {
    return showDialog<Map<String, double>>(
      context: context,
      builder: (ctx) => AutofillPopup(
        startValue: startValue,
        startYearMonth: startYearMonth,
      ),
    );
  }

  @override
  State<AutofillPopup> createState() => _AutofillPopupState();
}

class _AutofillPopupState extends State<AutofillPopup> {
  _AutofillMode _mode = _AutofillMode.fixed;
  final _amountController = TextEditingController();
  final _monthsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_onFieldChanged);
    _monthsController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() => setState(() {});

  @override
  void dispose() {
    _amountController.removeListener(_onFieldChanged);
    _monthsController.removeListener(_onFieldChanged);
    _amountController.dispose();
    _monthsController.dispose();
    super.dispose();
  }

  static double _round2(double v) => (v * 100).round() / 100;

  Map<String, double> _calculate() {
    final result = <String, double>{};
    final n = int.tryParse(_monthsController.text) ?? 0;
    if (n <= 0) return result;

    if (_mode == _AutofillMode.loan) {
      // Iterative amortization: round interest and balance each month,
      // matching how banks produce statements. Force last month to 0.
      final P = widget.startValue.abs();
      final sign = widget.startValue < 0 ? -1.0 : 1.0;
      final r = (double.tryParse(_amountController.text) ?? 0) / 100 / 12;

      final double M = r == 0
          ? _round2(P / n)
          : _round2(P * r * pow(1 + r, n) / (pow(1 + r, n) - 1));

      double balance = P;
      for (int i = 1; i <= n; i++) {
        final ym = addMonths(widget.startYearMonth, i);
        if (i == n) {
          balance = 0;
        } else {
          final interest = _round2(balance * r);
          final principal = M - interest;
          balance = _round2(balance - principal);
          if (balance < 0) balance = 0;
        }
        result[ym.toString()] = sign * balance;
      }
    } else {
      for (int i = 1; i <= n; i++) {
        final ym = addMonths(widget.startYearMonth, i);
        final double value;
        if (_mode == _AutofillMode.fixed) {
          value = widget.startValue +
              (double.tryParse(_amountController.text) ?? 0) * i;
        } else if (_mode == _AutofillMode.percentage) {
          final rate = (double.tryParse(_amountController.text) ?? 0) / 100;
          value = widget.startValue * pow(1 + rate, i).toDouble();
        } else {
          final yearlyRate = (double.tryParse(_amountController.text) ?? 0) / 100;
          value = widget.startValue * pow(1 + yearlyRate, i / 12.0).toDouble();
        }
        result[ym.toString()] = _round2(value);
      }
    }
    return result;
  }

  void _apply() {
    final months = int.tryParse(_monthsController.text) ?? 0;
    if (months <= 0) return;
    Navigator.pop(context, _calculate());
  }

  @override
  Widget build(BuildContext context) {
    final preview = _calculate();
    final monthFmt = DateFormat('MMM yyyy');
    final numFmt = NumberFormat('#,##0.00');

    return AlertDialog(
      title: Text(context.l10n.autofill),
      content: SizedBox(
        width: double.maxFinite,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left: inputs
            Expanded(
              flex: 5,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SegmentedButton<_AutofillMode>(
                    segments: [
                      ButtonSegment(
                        value: _AutofillMode.fixed,
                        label: Text(context.l10n.autofillFixed),
                      ),
                      ButtonSegment(
                        value: _AutofillMode.percentage,
                        label: Text(context.l10n.autofillPercentage),
                      ),
                      ButtonSegment(
                        value: _AutofillMode.percentageYearly,
                        label: Text(context.l10n.autofillPercentageYearly),
                      ),
                      ButtonSegment(
                        value: _AutofillMode.loan,
                        label: Text(context.l10n.autofillLoan),
                      ),
                    ],
                    selected: {_mode},
                    onSelectionChanged: (s) =>
                        setState(() => _mode = s.first),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _amountController,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      label: Text(switch (_mode) {
                        _AutofillMode.fixed =>
                          context.l10n.autofillAmountPerMonth,
                        _AutofillMode.percentage =>
                          context.l10n.autofillRatePerMonth,
                        _AutofillMode.percentageYearly =>
                          context.l10n.autofillRatePerYear,
                        _AutofillMode.loan =>
                          context.l10n.autofillLoanRate,
                      }),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true, signed: true),
                    inputFormatters: [_NumericFormatter()],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _monthsController,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      label: Text(context.l10n.autofillNumberOfMonths),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ],
              ),
            ),
            // Right: preview values
            if (preview.isNotEmpty) ...[
              const SizedBox(width: 16),
              Expanded(
                flex: 4,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 220),
                  child: ListView(
                    shrinkWrap: true,
                    children: preview.entries.map((e) {
                      final ym = int.parse(e.key);
                      final date = DateTime(ym ~/ 100, ym % 100);
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              monthFmt.format(date),
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              numFmt.format(e.value),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: Text(context.l10n.cancel),
        ),
        TextButton(
          onPressed: _apply,
          child: Text(context.l10n.confirm),
        ),
      ],
    );
  }
}
