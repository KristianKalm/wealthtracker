import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../core/util/MoneyFormat.dart';
import '../../l10n/l10n.dart';

enum _AutofillMode { fixed, percentage, loan }

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

class _MaxValueFormatter extends TextInputFormatter {
  final int max;
  _MaxValueFormatter(this.max);

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final n = int.tryParse(newValue.text);
    if (n != null && n > max) return oldValue;
    return newValue;
  }
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
  bool _percentYearly = false;
  late TextEditingController _initialController;
  final _loanPrincipalController = TextEditingController();
  final _amountController = TextEditingController();
  final _contributionController = TextEditingController();
  final _monthsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initialController = TextEditingController(text: widget.startValue.toString());
    _initialController.addListener(_onFieldChanged);
    _loanPrincipalController.addListener(_onFieldChanged);
    _amountController.addListener(_onFieldChanged);
    _contributionController.addListener(_onFieldChanged);
    _monthsController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() => setState(() {});

  @override
  void dispose() {
    _initialController.removeListener(_onFieldChanged);
    _loanPrincipalController.removeListener(_onFieldChanged);
    _amountController.removeListener(_onFieldChanged);
    _contributionController.removeListener(_onFieldChanged);
    _monthsController.removeListener(_onFieldChanged);
    _initialController.dispose();
    _loanPrincipalController.dispose();
    _amountController.dispose();
    _contributionController.dispose();
    _monthsController.dispose();
    super.dispose();
  }


  int get _months => (int.tryParse(_monthsController.text) ?? 0).clamp(0, 360);

  Map<String, double> _calculate() {
    final result = <String, double>{};
    final n = _months;
    if (n <= 0) return result;
    final initialValue = double.tryParse(_initialController.text) ?? widget.startValue;

    if (_mode == _AutofillMode.loan) {
      final P = (double.tryParse(_loanPrincipalController.text) ?? 0).abs();
      final r = (double.tryParse(_amountController.text) ?? 0) / 100 / 12;
      final double M = r == 0
          ? roundMoney(P / n)
          : roundMoney(P * r * pow(1 + r, n) / (pow(1 + r, n) - 1));

      double balance = roundMoney(P);
      for (int i = 1; i <= n; i++) {
        final ym = addMonths(widget.startYearMonth, i);
        if (i == n) {
          balance = 0;
        } else {
          final interest = roundMoney(balance * r);
          final principal = M - interest;
          balance = roundMoney(balance - principal);
          if (balance < 0) balance = 0;
        }
        result[ym.toString()] = roundMoney(-balance);
      }
    } else if (_mode == _AutofillMode.fixed) {
      final amount = double.tryParse(_amountController.text) ?? 0;
      for (int i = 1; i <= n; i++) {
        final ym = addMonths(widget.startYearMonth, i);
        result[ym.toString()] = roundMoney(initialValue + amount * i);
      }
    } else {
      final yearlyRate = (double.tryParse(_amountController.text) ?? 0) / 100;
      final monthlyRate = _percentYearly
          ? pow(1 + yearlyRate, 1 / 12.0).toDouble() - 1
          : yearlyRate;
      final contribution = double.tryParse(_contributionController.text) ?? 0;
      double balance = initialValue;
      for (int i = 1; i <= n; i++) {
        final ym = addMonths(widget.startYearMonth, i);
        balance = roundMoney(balance * (1 + monthlyRate) + contribution);
        result[ym.toString()] = balance;
      }
    }
    return result;
  }

  double? _loanMonthlyPayment() {
    final n = _months;
    if (n <= 0) return null;
    final P = (double.tryParse(_loanPrincipalController.text) ?? 0).abs();
    if (P == 0) return null;
    final r = (double.tryParse(_amountController.text) ?? 0) / 100 / 12;
    return r == 0 ? roundMoney(P / n) : roundMoney(P * r * pow(1 + r, n) / (pow(1 + r, n) - 1));
  }

  double? _loanTotalWithInterest() {
    final n = _months;
    if (n <= 0) return null;
    final P = (double.tryParse(_loanPrincipalController.text) ?? 0).abs();
    if (P == 0) return null;
    final r = (double.tryParse(_amountController.text) ?? 0) / 100 / 12;
    final double M = r == 0
        ? roundMoney(P / n)
        : roundMoney(P * r * pow(1 + r, n) / (pow(1 + r, n) - 1));
    return roundMoney(-M * n);
  }

  void _apply() {
    final months = _months;
    if (months <= 0) return;
    final result = _calculate();
    if (_mode == _AutofillMode.loan) {
      final total = _loanTotalWithInterest();
      if (total != null) {
        result[widget.startYearMonth.toString()] = total;
      }
    } else {
      final initialValue = double.tryParse(_initialController.text) ?? widget.startValue;
      result[widget.startYearMonth.toString()] = roundMoney(initialValue);
    }
    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    final preview = _calculate();
    final monthFmt = DateFormat('MMM yyyy');

    return AlertDialog(
      title: Text(context.l10n.autofill),
      content: SizedBox(
        width: 320,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_mode != _AutofillMode.loan)
              TextField(
                controller: _initialController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  label: Text(context.l10n.autofillInitialAmount),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                    decimal: true, signed: true),
                inputFormatters: [_NumericFormatter()],
              ),
            if (_mode != _AutofillMode.loan) const SizedBox(height: 12),
            DropdownButtonFormField<_AutofillMode>(
              value: _mode,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: [
                DropdownMenuItem(
                  value: _AutofillMode.fixed,
                  child: Text(context.l10n.autofillFixed),
                ),
                DropdownMenuItem(
                  value: _AutofillMode.percentage,
                  child: Text(context.l10n.autofillPercentage),
                ),
                DropdownMenuItem(
                  value: _AutofillMode.loan,
                  child: Text(context.l10n.autofillLoan),
                ),
              ],
              onChanged: (v) => setState(() => _mode = v!),
            ),
            if (_mode == _AutofillMode.loan) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _loanPrincipalController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  label: Text(context.l10n.autofillLoanPrincipal),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                    decimal: true, signed: true),
                inputFormatters: [_NumericFormatter()],
              ),
            ],
            if (_mode == _AutofillMode.percentage) ...[
              const SizedBox(height: 10),
              SegmentedButton<bool>(
                segments: [
                  ButtonSegment(value: false, label: Text(context.l10n.autofillMonthly)),
                  ButtonSegment(value: true, label: Text(context.l10n.autofillYearly)),
                ],
                selected: {_percentYearly},
                onSelectionChanged: (s) => setState(() => _percentYearly = s.first),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _contributionController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  label: Text(context.l10n.autofillMonthlyContribution),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                    decimal: true, signed: true),
                inputFormatters: [_NumericFormatter()],
              ),
            ],
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                label: Text(switch (_mode) {
                  _AutofillMode.fixed => context.l10n.autofillAmountPerMonth,
                  _AutofillMode.percentage => _percentYearly
                      ? context.l10n.autofillRatePerYear
                      : context.l10n.autofillRatePerMonth,
                  _AutofillMode.loan => context.l10n.autofillLoanRate,
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
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, _MaxValueFormatter(360)],
            ),
            if (_mode == _AutofillMode.loan) ...[
              const SizedBox(height: 10),
              InputDecorator(
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  label: Text(context.l10n.autofillMonthlyPayment),
                ),
                child: Text(
                  _loanMonthlyPayment() != null ? formatMoney(_loanMonthlyPayment()!) : '—',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 10),
              InputDecorator(
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  label: Text(context.l10n.autofillTotalWithInterest),
                ),
                child: Text(
                  _loanTotalWithInterest() != null
                      ? formatMoney(_loanTotalWithInterest()!)
                      : '—',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
            // Below: preview values
            if (preview.isNotEmpty) ...[
              const SizedBox(height: 12),
              ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
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
                            formatMoney(e.value),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
              ),
            ],
          ],
        ),
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
