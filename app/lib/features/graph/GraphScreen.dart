import 'dart:io' as io;
import 'dart:ui' as ui;

import 'package:file_saver/file_saver.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kryptic_core/kryptic_core.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/models/AssetGroup.dart';
import '../../core/models/Month.dart';
import '../../core/models/MyConf.dart';
import '../../l10n/l10n.dart';
import '../Providers.dart';
import '../asset/AssetListScreen.dart';
import '../navigation/WealthtrackerBottomNav.dart';

const _chartColors = [
  Colors.blue,
  Colors.orange,
  Colors.purple,
  Colors.teal,
  Colors.pink,
  Colors.cyan,
  Colors.amber,
  Colors.indigo,
  Colors.lime,
  Colors.deepOrange,
];

class GraphScreen extends ConsumerStatefulWidget {
  const GraphScreen({super.key});

  @override
  ConsumerState<GraphScreen> createState() => _GraphScreenState();
}

class _GraphScreenState extends ConsumerState<GraphScreen> {
  DateTime endDate = DateTime.now();
  DateTime startDate = DateTime(
    DateTime.now().year - 1,
    DateTime.now().month,
    DateTime.now().day,
  );

  /// Ordered list of asset names (stable order for stacking)
  List<String> assetNames = [];

  /// yearMonth index -> asset name -> value
  /// Every asset has an entry for every month (0 if absent)
  List<int> yearMonths = [];
  Map<String, List<double>> assetValues = {};

  static const _totalName = 'Total';
  Set<String> hiddenAssets = {};
  bool _initialLoad = true;
  bool _showGroups = false;
  List<AssetGroup> _allGroups = [];

  // Salary chart state
  List<Month> _salaryData = [];
  int? _birthYear;
  bool _salaryShowTotal = true;
  bool _salaryShowBonus = true;
  bool _salaryShowSalary = true;

  // Pie chart state
  DateTime pieDate = DateTime.now();
  List<MapEntry<String, double>> pieAssetData = [];
  List<MapEntry<String, double>> pieLiabilityData = [];
  int pieAssetTouchedIndex = -1;
  int pieLiabilityTouchedIndex = -1;
  List<MapEntry<String, double>> pieGroupData = [];
  int pieGroupTouchedIndex = -1;

  @override
  void initState() {
    super.initState();
    updateGraph();
    updatePie();
    _loadSalaryData();
  }

  DateTime _parseYearMonth(int yearMonth) {
    return DateTime(yearMonth ~/ 100, yearMonth % 100);
  }

  void updateGraph() async {
    final repo = await ref.read(wealthtrackerRepositoryProvider.future);
    final allAssets = await repo.assets.loadAll();
    final myConf = await repo.conf.load();
    _allGroups = myConf.assetGroups;

    final groupMap = <String, AssetGroup>{};
    for (var g in _allGroups) {
      groupMap[g.id] = g;
    }

    // Build month list
    final months = <int>[];
    DateTime date = DateTime(startDate.year, startDate.month);
    int limit = 0;
    while ((date.isBefore(endDate) ||
            (date.year == endDate.year && date.month == endDate.month)) &&
        limit < 120) {
      months.add(date.year * 100 + date.month);
      date = DateTime(date.year, date.month + 1);
      limit++;
    }

    // Resolve display name for each asset (group name or asset name)
    String displayName(a) {
      if (_showGroups && a.groupId != null && groupMap.containsKey(a.groupId)) {
        return groupMap[a.groupId]!.name;
      }
      return a.name;
    }

    // Collect unique names that have at least one value in range
    final lastMonth = months.isNotEmpty ? months.last : 0;
    final lastMonthValues = <String, double>{};
    for (var a in allAssets) {
      final name = displayName(a);
      for (var entry in a.monthlyValues.entries) {
        final ym = int.tryParse(entry.key);
        if (ym != null && months.contains(ym)) {
          lastMonthValues.putIfAbsent(name, () => 0);
          if (ym == lastMonth) {
            lastMonthValues[name] = (lastMonthValues[name] ?? 0) + entry.value;
          }
        }
      }
    }
    final names = lastMonthValues.keys.toList()
      ..sort(
        (a, b) => (lastMonthValues[b] ?? 0).compareTo(lastMonthValues[a] ?? 0),
      );

    // Build per-name value arrays (one entry per month, 0 if absent)
    final values = <String, List<double>>{};
    for (var name in names) {
      values[name] = List.filled(months.length, 0);
    }
    for (var a in allAssets) {
      final name = displayName(a);
      if (!values.containsKey(name)) continue;
      for (var entry in a.monthlyValues.entries) {
        final ym = int.tryParse(entry.key);
        if (ym != null) {
          final idx = months.indexOf(ym);
          if (idx >= 0) {
            values[name]![idx] += entry.value;
          }
        }
      }
    }

    // Compute total line
    final totalValues = List.filled(months.length, 0.0);
    for (var name in names) {
      for (var m = 0; m < months.length; m++) {
        totalValues[m] += values[name]![m];
      }
    }
    values[_totalName] = totalValues;
    final allNames = [_totalName, ...names];

    if (mounted) {
      setState(() {
        assetNames = allNames;
        yearMonths = months;
        assetValues = values;
        if (_initialLoad) {
          // Only Total visible on first load
          hiddenAssets = names.toSet();
          _initialLoad = false;
        } else {
          hiddenAssets.retainAll(allNames);
        }
      });
    }
  }

  void updatePie() async {
    final repo = await ref.read(wealthtrackerRepositoryProvider.future);
    final ymStr = '${pieDate.year * 100 + pieDate.month}';
    final allAssets = await repo.assets.loadAll();
    final myConf = await repo.conf.load();
    _allGroups = myConf.assetGroups;

    final groupMap = <String, AssetGroup>{};
    for (var g in _allGroups) {
      groupMap[g.id] = g;
    }

    // Aggregate values for the selected month (always by asset name, not group)
    final aggregated = <String, double>{};
    for (var a in allAssets) {
      final val = a.monthlyValues[ymStr];
      if (val != null) {
        aggregated[a.name] = (aggregated[a.name] ?? 0) + val;
      }
    }

    final monthEntries = aggregated.entries.toList();
    final positive = monthEntries.where((e) => e.value > 0).toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final negative = monthEntries.where((e) => e.value < 0).toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    // Aggregate by group (always, independent of toggle)
    final groupAggregated = <String, double>{};
    for (var a in allAssets) {
      final val = a.monthlyValues[ymStr];
      if (val != null) {
        final name = (a.groupId != null && groupMap.containsKey(a.groupId))
            ? groupMap[a.groupId]!.name
            : a.name;
        groupAggregated[name] = (groupAggregated[name] ?? 0) + val;
      }
    }
    final groupEntries =
        groupAggregated.entries.where((e) => e.value > 0).toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    if (mounted) {
      setState(() {
        pieAssetData = positive;
        pieLiabilityData = negative
            .map((e) => MapEntry(e.key, e.value.abs()))
            .toList();
        pieAssetTouchedIndex = -1;
        pieLiabilityTouchedIndex = -1;
        pieGroupData = groupEntries;
        pieGroupTouchedIndex = -1;
      });
    }
  }

  void _loadSalaryData() async {
    final repo = await ref.read(wealthtrackerRepositoryProvider.future);
    final myConf = await repo.conf.load();
    final comments = await repo.comments.loadAll();
    final salaryComments = comments.where((c) => c.hasSalaryData).toList();
    salaryComments.sort((a, b) => a.yearMonth.compareTo(b.yearMonth));
    if (mounted) {
      setState(() {
        _salaryData = salaryComments;
        _birthYear = _birthYearFromConf(myConf);
      });
    }
  }

  int? _birthYearFromConf(MyConf conf) {
    final birthday = conf.customConfigs['birthday'];
    if (birthday is! String) return null;
    return DateTime.tryParse(birthday)?.year;
  }

  String _ageForYear(int year) {
    final birthYear = _birthYear;
    if (birthYear == null) return '-';
    return (year - birthYear).toString();
  }

  // Months since year 2000, giving a linear time axis.
  int _toMonthIndex(int yearMonth) =>
      (yearMonth ~/ 100 - 2000) * 12 + (yearMonth % 100 - 1);

  DateTime _fromMonthIndex(int idx) => DateTime(2000 + idx ~/ 12, idx % 12 + 1);

  Widget _buildSalaryChart(KrypticColors colors) {
    if (_salaryData.isEmpty) return const SizedBox.shrink();

    const salaryColor = Colors.orange;
    const bonusColor = Colors.green;
    const totalColor = Colors.blue;

    final salarySpots = <FlSpot>[];
    final bonusSpots = <FlSpot>[];
    final totalSpots = <FlSpot>[];

    final occupiedMonths = _salaryData
        .map((s) => _toMonthIndex(s.yearMonth))
        .toSet();

    for (final s in _salaryData) {
      final m = _toMonthIndex(s.yearMonth);
      final x = m.toDouble();
      final salary = s.salary ?? 0.0;
      final bonus = s.bonus ?? 0.0;
      final total = salary + bonus;

      if (!occupiedMonths.contains(m - 1)) {
        salarySpots.add(FlSpot(m - 1.0, 0));
        bonusSpots.add(FlSpot(m - 1.0, 0));
        totalSpots.add(FlSpot(m - 1.0, 0));
      }

      salarySpots.add(FlSpot(x, salary));
      bonusSpots.add(FlSpot(x, bonus));
      totalSpots.add(FlSpot(x, total));

      if (!occupiedMonths.contains(m + 1)) {
        final now = DateTime.now();
        final currentMonthIdx = _toMonthIndex(now.year * 100 + now.month);
        final trailingX = m + 1 <= currentMonthIdx ? m + 1 : currentMonthIdx;
        if (trailingX > m) {
          salarySpots.add(FlSpot(trailingX.toDouble(), 0));
          bonusSpots.add(FlSpot(trailingX.toDouble(), 0));
          totalSpots.add(FlSpot(trailingX.toDouble(), 0));
        }
      }
    }

    salarySpots.sort((a, b) => a.x.compareTo(b.x));
    bonusSpots.sort((a, b) => a.x.compareTo(b.x));
    totalSpots.sort((a, b) => a.x.compareTo(b.x));

    final now = DateTime.now();
    final currentMonthIdx = _toMonthIndex(now.year * 100 + now.month);
    final allX = _salaryData
        .map((s) => _toMonthIndex(s.yearMonth).toDouble())
        .toList();
    final minX = allX.first;
    final maxX = currentMonthIdx.toDouble();
    final range = (maxX - minX).clamp(1.0, double.infinity);
    final interval = (range / 6).ceilToDouble().clamp(1.0, double.infinity);

    LineChartBarData series(List<FlSpot> spots, Color color) =>
        LineChartBarData(
          spots: spots,
          isCurved: false,
          color: color,
          barWidth: 2,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, _, __, ___) =>
                FlDotCirclePainter(radius: 3, color: color, strokeWidth: 0),
          ),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            'Salary',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colors.primaryText,
            ),
          ),
        ),
        Container(
          height: 250,
          padding: const EdgeInsets.only(right: 16, top: 16),
          decoration: BoxDecoration(
            color: colors.cardBackgroundColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: LineChart(
            LineChartData(
              minX: minX - 1,
              maxX: maxX,
              lineBarsData: [
                if (_salaryShowSalary) series(salarySpots, salaryColor),
                if (_salaryShowBonus) series(bonusSpots, bonusColor),
                if (_salaryShowTotal) series(totalSpots, totalColor),
              ],
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: interval,
                    getTitlesWidget: (value, meta) {
                      final dt = _fromMonthIndex(value.round());
                      return GestureDetector(
                        onTap: () => Navigator.pushReplacement(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (_, __, ___) =>
                                AssetListScreen(initialDate: dt),
                            transitionDuration: Duration.zero,
                            reverseTransitionDuration: Duration.zero,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            DateFormat('MM/yy').format(dt),
                            style: TextStyle(
                              fontSize: 10,
                              color: colors.secondaryText,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 50,
                    getTitlesWidget: (value, meta) => Text(
                      NumberFormat.compact().format(value),
                      style: TextStyle(
                        fontSize: 10,
                        color: colors.secondaryText,
                      ),
                    ),
                  ),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) =>
                    FlLine(color: colors.inputBorder, strokeWidth: 0.5),
              ),
              borderData: FlBorderData(show: false),
              lineTouchData: LineTouchData(
                touchCallback:
                    (FlTouchEvent event, LineTouchResponse? response) {
                      if (event is FlTapUpEvent &&
                          response?.lineBarSpots != null &&
                          response!.lineBarSpots!.isNotEmpty) {
                        final dt = _fromMonthIndex(
                          response.lineBarSpots!.first.x.round(),
                        );
                        Navigator.pushReplacement(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (_, __, ___) =>
                                AssetListScreen(initialDate: dt),
                            transitionDuration: Duration.zero,
                            reverseTransitionDuration: Duration.zero,
                          ),
                        );
                      }
                    },
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (spots) {
                    final visibleLabels = [
                      if (_salaryShowSalary) 'Salary',
                      if (_salaryShowBonus) 'Bonus',
                      if (_salaryShowTotal) 'Total',
                    ];
                    return spots.map((spot) {
                      final dt = _fromMonthIndex(spot.x.round());
                      final label = spot.barIndex < visibleLabels.length
                          ? visibleLabels[spot.barIndex]
                          : '';
                      return LineTooltipItem(
                        '${DateFormat('MMM yyyy').format(dt)}\n$label: ${NumberFormat('#,##0').format(spot.y)}',
                        TextStyle(
                          color: spot.bar.color,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          children: [
            _salaryLegend(
              salaryColor,
              'Salary',
              _salaryShowSalary,
              () => setState(() => _salaryShowSalary = !_salaryShowSalary),
            ),
            _salaryLegend(
              bonusColor,
              'Bonus',
              _salaryShowBonus,
              () => setState(() => _salaryShowBonus = !_salaryShowBonus),
            ),
            _salaryLegend(
              totalColor,
              'Total',
              _salaryShowTotal,
              () => setState(() => _salaryShowTotal = !_salaryShowTotal),
            ),
          ],
        ),
      ],
    );
  }

  Widget _salaryLegend(
    Color color,
    String label,
    bool active,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: active ? color : Colors.transparent,
              border: Border.all(color: color, width: 1.5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: active ? null : Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildSalaryTable(KrypticColors colors) {
    if (_salaryData.isEmpty) return const SizedBox.shrink();

    final byYear = <int, List<Month>>{};
    for (final s in _salaryData) {
      byYear.putIfAbsent(s.yearMonth ~/ 100, () => []).add(s);
    }
    final years = byYear.keys.toList()..sort();

    double? prevYearly;
    String? prevPosition;
    double incomeActualTotal = 0;
    final rows = <DataRow>[];

    for (final year in years) {
      final salaries = byYear[year]!
        ..sort((a, b) => a.yearMonth.compareTo(b.yearMonth));

      final totalSalary = salaries.fold(0.0, (sum, s) => sum + (s.salary ?? 0));
      incomeActualTotal += totalSalary;
      final withSalary = salaries.where((s) => (s.salary ?? 0) != 0).toList();
      final yearly = withSalary.isEmpty
          ? 0.0
          : (withSalary.last.salary ?? 0) * 12;

      final age = _ageForYear(year);

      Color? changeColor;
      String changeStr = '-';
      if (prevYearly != null && prevYearly != 0) {
        final pct = (yearly - prevYearly) / prevYearly * 100;
        changeStr = '${pct >= 0 ? '+' : ''}${pct.toStringAsFixed(1)}%';
        changeColor = pct >= 0 ? Colors.green : Colors.red;
      }

      final position =
          salaries
              .lastWhere(
                (s) => s.position != null && s.position!.isNotEmpty,
                orElse: () => salaries.last,
              )
              .position ??
          '';
      final positionLabel = position.isNotEmpty && position != prevPosition
          ? position
          : '';
      if (position.isNotEmpty) prevPosition = position;

      rows.add(
        DataRow(
          cells: [
            DataCell(
              Text(
                year.toString(),
                style: TextStyle(color: colors.primaryText),
              ),
            ),
            DataCell(Text(age, style: TextStyle(color: colors.primaryText))),
            DataCell(
              Text(
                NumberFormat('#,##0').format(totalSalary),
                style: TextStyle(color: colors.primaryText),
              ),
            ),
            DataCell(
              Text(
                NumberFormat('#,##0').format(yearly),
                style: TextStyle(color: colors.primaryText),
              ),
            ),
            DataCell(
              Text(
                changeStr,
                style: TextStyle(color: changeColor ?? colors.primaryText),
              ),
            ),
            DataCell(
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 160),
                child: Text(
                  positionLabel,
                  style: TextStyle(color: colors.secondaryText),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      );

      prevYearly = yearly;
    }

    rows.add(
      DataRow(
        cells: [
          DataCell(
            Text(
              'Total',
              style: TextStyle(
                color: colors.primaryText,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const DataCell(Text('')),
          DataCell(
            Text(
              NumberFormat('#,##0').format(incomeActualTotal),
              style: TextStyle(
                color: colors.primaryText,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const DataCell(Text('')),
          const DataCell(Text('')),
          const DataCell(Text('')),
        ],
      ),
    );

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 8),
              child: Row(
                children: [
                  Text(
                    'Salary by Year',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colors.primaryText,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      Icons.download_outlined,
                      color: colors.secondaryText,
                      size: 20,
                    ),
                    onPressed: () => _exportSalaryTableToImage(colors),
                    tooltip: 'Export as image',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: colors.cardBackgroundColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 16,
                  headingTextStyle: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: colors.secondaryText,
                  ),
                  columns: const [
                    DataColumn(label: Text('Year')),
                    DataColumn(label: Text('Age'), numeric: true),
                    DataColumn(label: Text('Income\n(Actual)'), numeric: true),
                    DataColumn(
                      label: Text('Yearly\n(FullTime)'),
                      numeric: true,
                    ),
                    DataColumn(label: Text('Change')),
                    DataColumn(label: Text('Comment')),
                  ],
                  rows: rows,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _canvasDrawText(
    Canvas canvas,
    String text,
    Offset offset, {
    double fontSize = 14,
    Color color = const Color(0xFFFFFFFF),
    FontWeight fontWeight = FontWeight.normal,
    TextAlign textAlign = TextAlign.left,
    double maxWidth = 200,
  }) {
    final pb =
        ui.ParagraphBuilder(
            ui.ParagraphStyle(
              fontSize: fontSize,
              fontWeight: fontWeight,
              textAlign: textAlign,
            ),
          )
          ..pushStyle(ui.TextStyle(color: color))
          ..addText(text);
    final paragraph = pb.build()
      ..layout(ui.ParagraphConstraints(width: maxWidth));
    canvas.drawParagraph(paragraph, offset);
  }

  Future<void> _exportSalaryTableToImage(KrypticColors colors) async {
    final byYear = <int, List<Month>>{};
    for (final s in _salaryData) {
      byYear.putIfAbsent(s.yearMonth ~/ 100, () => []).add(s);
    }
    final years = byYear.keys.toList()..sort();
    if (years.isEmpty) return;

    const double canvasW = 1080;
    const double padH = 40;
    const double padV = 40;
    const double titleH = 70;
    const double headerH = 56;
    const double rowH = 44;
    const double footerH = 96;
    const double tableRadius = 18;

    final double canvasH =
        padV + titleH + headerH + years.length * rowH + footerH;
    const double tableX = padH;
    const double tableW = canvasW - padH * 2;

    // columns: (start x, width, header label, text alignment)
    final cols = [
      (x: padH + 24.0, w: 56.0, label: 'Year', align: TextAlign.left),
      (x: padH + 96.0, w: 48.0, label: 'Age', align: TextAlign.right),
      (
        x: padH + 180.0,
        w: 160.0,
        label: 'Income\n(Actual)',
        align: TextAlign.right,
      ),
      (
        x: padH + 360.0,
        w: 160.0,
        label: 'Yearly\n(FullTime)',
        align: TextAlign.right,
      ),
      (x: padH + 560.0, w: 110.0, label: 'Change', align: TextAlign.left),
      (x: padH + 680.0, w: 320.0, label: 'Comment', align: TextAlign.left),
    ];

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, canvasW, canvasH));

    canvas.drawRect(
      Rect.fromLTWH(0, 0, canvasW, canvasH),
      Paint()..color = colors.backgroundColor,
    );

    _canvasDrawText(
      canvas,
      'Salary by Year',
      Offset(padH, padV + (titleH - 28) / 2),
      fontSize: 28,
      color: colors.primaryText,
      fontWeight: FontWeight.bold,
      maxWidth: canvasW - padH * 2,
    );

    final headerY = padV + titleH;
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(tableX, headerY, tableW, headerH),
        topLeft: const Radius.circular(tableRadius),
        topRight: const Radius.circular(tableRadius),
      ),
      Paint()..color = const Color(0xFF31C8C8),
    );

    for (final col in cols) {
      _canvasDrawText(
        canvas,
        col.label,
        Offset(col.x, headerY + 8),
        fontSize: 12,
        color: colors.secondaryText,
        fontWeight: FontWeight.w600,
        textAlign: col.align,
        maxWidth: col.w,
      );
    }

    double? prevYearly;
    String? prevPosition;

    for (int i = 0; i < years.length; i++) {
      final year = years[i];
      final salaries = (byYear[year]!.toList())
        ..sort((a, b) => a.yearMonth.compareTo(b.yearMonth));

      final totalSalary = salaries.fold(0.0, (sum, s) => sum + (s.salary ?? 0));
      final withSalary = salaries.where((s) => (s.salary ?? 0) != 0).toList();
      final yearly = withSalary.isEmpty
          ? 0.0
          : (withSalary.last.salary ?? 0) * 12;
      final age = _ageForYear(year);

      Color changeColor = colors.primaryText;
      String changeStr = '-';
      if (prevYearly != null && prevYearly != 0) {
        final pct = (yearly - prevYearly) / prevYearly * 100;
        changeStr = '${pct >= 0 ? '+' : ''}${pct.toStringAsFixed(1)}%';
        changeColor = pct >= 0 ? colors.successColor : colors.errorColor;
      }

      final position =
          salaries
              .lastWhere(
                (s) => s.position != null && s.position!.isNotEmpty,
                orElse: () => salaries.last,
              )
              .position ??
          '';
      final positionLabel = position.isNotEmpty && position != prevPosition
          ? position
          : '';
      if (position.isNotEmpty) prevPosition = position;

      final rowY = padV + titleH + headerH + i * rowH;
      if (i.isEven) {
        canvas.drawRRect(
          RRect.fromRectAndCorners(
            Rect.fromLTWH(tableX, rowY, tableW, rowH),
            bottomLeft: i == years.length - 1
                ? const Radius.circular(tableRadius)
                : Radius.zero,
            bottomRight: i == years.length - 1
                ? const Radius.circular(tableRadius)
                : Radius.zero,
          ),
          Paint()..color = colors.cardBackgroundColor,
        );
      }

      final textY = rowY + (rowH - 14) / 2;
      _canvasDrawText(
        canvas,
        year.toString(),
        Offset(cols[0].x, textY),
        fontSize: 14,
        color: colors.primaryText,
        maxWidth: cols[0].w,
      );
      _canvasDrawText(
        canvas,
        age,
        Offset(cols[1].x, textY),
        fontSize: 14,
        color: colors.primaryText,
        textAlign: TextAlign.right,
        maxWidth: cols[1].w,
      );
      _canvasDrawText(
        canvas,
        NumberFormat('#,##0').format(totalSalary),
        Offset(cols[2].x, textY),
        fontSize: 14,
        color: colors.primaryText,
        textAlign: TextAlign.right,
        maxWidth: cols[2].w,
      );
      _canvasDrawText(
        canvas,
        NumberFormat('#,##0').format(yearly),
        Offset(cols[3].x, textY),
        fontSize: 14,
        color: colors.primaryText,
        textAlign: TextAlign.right,
        maxWidth: cols[3].w,
      );
      _canvasDrawText(
        canvas,
        changeStr,
        Offset(cols[4].x, textY),
        fontSize: 14,
        color: changeColor,
        maxWidth: cols[4].w,
      );
      _canvasDrawText(
        canvas,
        positionLabel,
        Offset(cols[5].x, textY),
        fontSize: 14,
        color: colors.secondaryText,
        maxWidth: cols[5].w,
      );

      prevYearly = yearly;
    }

    _canvasDrawText(
      canvas,
      'wealthtracker.app',
      Offset(canvasW - padH - 260, canvasH - padV - 28),
      fontSize: 22,
      color: colors.secondaryText,
      fontWeight: FontWeight.w600,
      textAlign: TextAlign.right,
      maxWidth: 260,
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(canvasW.toInt(), canvasH.toInt());
    picture.dispose();
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    final pngBytes = byteData!.buffer.asUint8List();

    if (!mounted) return;

    if (kIsWeb) {
      await FileSaver.instance.saveFile(
        name: 'salary_by_year.png',
        bytes: pngBytes,
        mimeType: MimeType.other,
      );
    } else {
      final dir = await getTemporaryDirectory();
      final file = io.File('${dir.path}/salary_by_year.png');
      await file.writeAsBytes(pngBytes);
      await Share.shareXFiles([XFile(file.path)], subject: 'Salary by Year');
      await file.delete();
    }
  }

  List<LineChartBarData> _buildLines(KrypticColors colors) {
    if (yearMonths.isEmpty || assetNames.isEmpty) return [];

    final visible = assetNames.where((n) => !hiddenAssets.contains(n)).toList();
    if (visible.isEmpty) return [];

    final lines = <LineChartBarData>[];
    for (var name in visible) {
      final color =
          _chartColors[assetNames.indexOf(name) % _chartColors.length];
      final spots = assetValues[name]!
          .asMap()
          .entries
          .map((e) => FlSpot(e.key.toDouble(), e.value))
          .toList();

      lines.add(
        LineChartBarData(
          spots: spots,
          isCurved: true,
          preventCurveOverShooting: true,
          color: color,
          barWidth: name == _totalName ? 3 : 2,
          dotData: const FlDotData(show: false),
        ),
      );
    }

    return lines;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = KrypticColors(isDark);
    String startDateFormatted = DateFormat('MMM yyyy').format(startDate);
    String endDateFormatted = DateFormat('MMM yyyy').format(endDate);

    return KrypticBaseScreen(
      extendBody: true,
      toolbar: KrypticToolbar(title: context.l10n.navGraph),
      bottomNavigation: WealthtrackerBottomNav(context, 1),
      content: Column(
        children: [
          // Assets / Groups toggle
          SegmentedButton<bool>(
            segments: [
              ButtonSegment(value: false, label: Text(context.l10n.assets)),
              ButtonSegment(value: true, label: Text(context.l10n.groups)),
            ],
            selected: {_showGroups},
            onSelectionChanged: (selection) {
              setState(() {
                _showGroups = selection.first;
                _initialLoad = true;
              });
              updateGraph();
              updatePie();
            },
          ),
          const SizedBox(height: 16),

          // Date range buttons
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8.0,
            runSpacing: 8.0,
            children: [
              OutlinedButton(
                onPressed: () {
                  showMonthPicker(
                    context: context,
                    firstDate: DateTime(DateTime.now().year - 10),
                    lastDate: DateTime.now(),
                    initialDate: startDate,
                    confirmWidget: Text(context.l10n.save),
                    cancelWidget: Text(context.l10n.cancel),
                  ).then((DateTime? date) {
                    if (date != null) {
                      setState(() => startDate = date);
                      updateGraph();
                    }
                  });
                },
                child: Text(context.l10n.graphFrom(startDateFormatted)),
              ),
              OutlinedButton(
                onPressed: () {
                  showMonthPicker(
                    context: context,
                    firstDate: DateTime(DateTime.now().year - 10),
                    lastDate: DateTime.now(),
                    initialDate: endDate,
                    confirmWidget: Text(context.l10n.save),
                    cancelWidget: Text(context.l10n.cancel),
                  ).then((DateTime? date) {
                    if (date != null) {
                      setState(() => endDate = date);
                      updateGraph();
                    }
                  });
                },
                child: Text(context.l10n.graphTo(endDateFormatted)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Chart
          if (yearMonths.isNotEmpty)
            Container(
              height: 300,
              padding: const EdgeInsets.only(right: 16, top: 16),
              decoration: BoxDecoration(
                color: colors.cardBackgroundColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: LineChart(
                LineChartData(
                  lineBarsData: _buildLines(colors),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: (yearMonths.length / 6).ceilToDouble().clamp(
                          1,
                          double.infinity,
                        ),
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= yearMonths.length)
                            return const SizedBox.shrink();
                          final dt = _parseYearMonth(yearMonths[index]);
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              DateFormat('MM/yy').format(dt),
                              style: TextStyle(
                                fontSize: 10,
                                color: colors.secondaryText,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            NumberFormat.compact().format(value),
                            style: TextStyle(
                              fontSize: 10,
                              color: colors.secondaryText,
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) =>
                        FlLine(color: colors.inputBorder, strokeWidth: 0.5),
                  ),
                  borderData: FlBorderData(show: false),
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) {
                        final visible = assetNames
                            .where((n) => !hiddenAssets.contains(n))
                            .toList();
                        return touchedSpots.map((spot) {
                          final name = spot.barIndex < visible.length
                              ? visible[spot.barIndex]
                              : '';
                          return LineTooltipItem(
                            '$name\n${NumberFormat('#,##0').format(spot.y)}',
                            TextStyle(
                              color: spot.bar.color,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),

          const SizedBox(height: 16),

          // Asset legend chips
          if (assetNames.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: assetNames.map((name) {
                final color =
                    _chartColors[assetNames.indexOf(name) %
                        _chartColors.length];
                return FilterChip(
                  avatar: CircleAvatar(backgroundColor: color, radius: 6),
                  label: Text(name),
                  selected: !hiddenAssets.contains(name),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        hiddenAssets.remove(name);
                      } else {
                        hiddenAssets.add(name);
                      }
                    });
                  },
                );
              }).toList(),
            ),

          const SizedBox(height: 32),

          // Pie chart section
          _buildPieSection(colors),

          const SizedBox(height: 32),

          // Salary chart
          _buildSalaryChart(colors),

          const SizedBox(height: 32),

          // Salary yearly table
          _buildSalaryTable(colors),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildPieSection(KrypticColors colors) {
    final pieDateFormatted = DateFormat('MMMM yyyy').format(pieDate);

    return Column(
      children: [
        // Shared month picker
        OutlinedButton(
          onPressed: () {
            showMonthPicker(
              context: context,
              firstDate: DateTime(DateTime.now().year - 10),
              lastDate: DateTime(DateTime.now().year + 1, 12),
              initialDate: pieDate,
              confirmWidget: Text(context.l10n.ok),
              cancelWidget: Text(context.l10n.cancel),
            ).then((DateTime? date) {
              if (date != null) {
                pieDate = date;
                updatePie();
              }
            });
          },
          child: Text(pieDateFormatted),
        ),
        const SizedBox(height: 16),

        Wrap(
          alignment: WrapAlignment.center,
          spacing: 24,
          runSpacing: 24,
          children: [
            _buildSinglePie(
              colors: colors,
              title: context.l10n.assets,
              data: pieAssetData,
              touchedIndex: pieAssetTouchedIndex,
              onTouch: (i) => setState(() => pieAssetTouchedIndex = i),
              emptyMessage: context.l10n.noAssetsThisMonth,
            ),
            _buildSinglePie(
              colors: colors,
              title: context.l10n.liabilities,
              data: pieLiabilityData,
              touchedIndex: pieLiabilityTouchedIndex,
              onTouch: (i) => setState(() => pieLiabilityTouchedIndex = i),
              emptyMessage: context.l10n.noLiabilitiesThisMonth,
            ),
            _buildSinglePie(
              colors: colors,
              title: context.l10n.groups,
              data: pieGroupData,
              touchedIndex: pieGroupTouchedIndex,
              onTouch: (i) => setState(() => pieGroupTouchedIndex = i),
              emptyMessage: context.l10n.noGroupsThisMonth,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSinglePie({
    required KrypticColors colors,
    required String title,
    required List<MapEntry<String, double>> data,
    required int touchedIndex,
    required void Function(int) onTouch,
    required String emptyMessage,
  }) {
    if (data.isEmpty) {
      return SizedBox(
        width: 250,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colors.primaryText,
              ),
            ),
            const SizedBox(height: 8),
            Text(emptyMessage, style: TextStyle(color: colors.secondaryText)),
          ],
        ),
      );
    }

    double total = 0;
    for (final e in data) {
      total += e.value;
    }

    return SizedBox(
      width: 250,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colors.primaryText,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: colors.cardBackgroundColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      onTouch(-1);
                      return;
                    }
                    onTouch(
                      pieTouchResponse.touchedSection!.touchedSectionIndex,
                    );
                  },
                ),
                sectionsSpace: 2,
                centerSpaceRadius: 30,
                sections: data.asMap().entries.map((entry) {
                  final i = entry.key;
                  final name = entry.value.key;
                  final value = entry.value.value;
                  final isTouched = i == touchedIndex;
                  final color = _chartColors[i % _chartColors.length];
                  final pct = total > 0 ? (value / total * 100) : 0;
                  return PieChartSectionData(
                    color: color,
                    value: value,
                    title: isTouched
                        ? '$name\n${NumberFormat('#,##0').format(value)}'
                        : '${pct.toStringAsFixed(0)}%',
                    radius: isTouched ? 55 : 45,
                    titleStyle: TextStyle(
                      fontSize: isTouched ? 11 : 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: data.asMap().entries.map((entry) {
              final i = entry.key;
              final name = entry.value.key;
              final value = entry.value.value;
              final color = _chartColors[i % _chartColors.length];
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$name: ${NumberFormat('#,##0').format(value)}',
                    style: TextStyle(fontSize: 11, color: colors.primaryText),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
