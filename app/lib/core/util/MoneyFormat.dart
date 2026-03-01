import 'package:intl/intl.dart';

const int kMoneyDecimals = 2;

double roundMoney(double v) => double.parse(v.toStringAsFixed(kMoneyDecimals));

final _moneyFmt = NumberFormat('#,##0.${'0' * kMoneyDecimals}');

String formatMoney(double v) => _moneyFmt.format(v);
