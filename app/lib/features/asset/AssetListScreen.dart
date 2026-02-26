import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kryptic_ui/kryptic_ui.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

import '../../core/db/WealthtrackerRepository.dart';
import '../../core/models/AssetGroup.dart';
import '../../core/models/AssetUiModel.dart';
import '../../core/models/MonthSummary.dart';
import '../../core/models/Tag.dart';
import '../../core/sync/WealthtrackerSync.dart' as WealthtrackerSync;
import '../../core/util/PercentTools.dart';
import '../../l10n/l10n.dart';
import '../Providers.dart';
import '../navigation/WealthtrackerBottomNav.dart';
import 'AssetEditPopup.dart';
import 'CommentPopup.dart';

class _AssetGroupDisplay {
  final String? groupId;
  final String? groupName;
  final num netValue;
  final List<AssetUiModel> assets;

  _AssetGroupDisplay({this.groupId, this.groupName, required this.netValue, required this.assets});
}

class AssetListScreen extends ConsumerStatefulWidget {
  const AssetListScreen({super.key});

  @override
  ConsumerState<AssetListScreen> createState() => _AssetListScreenState();
}

class _AssetListScreenState extends ConsumerState<AssetListScreen> {
  MonthSummary uiMonth = MonthSummary();
  DateTime date = DateTime.now();
  List<Tag> allTags = [];
  List<AssetGroup> allGroups = [];
  Set<String> selectedFilterTagIds = {};

  @override
  void initState() {
    super.initState();
    ServicesBinding.instance.keyboard.addHandler(_onKey);
    updateAssets();
    _syncIfStale();
  }

  Future<void> _syncIfStale() async {
    final prefs = ref.read(wealthtrackerPrefsProvider);
    final downloadValue = await prefs.get(WealthtrackerSync.LAST_DOWNLOAD_TIME);
    final uploadValue = await prefs.get(WealthtrackerSync.LAST_UPLOAD_TIME);
    final downloadTs = downloadValue != null ? int.tryParse(downloadValue) : null;
    final uploadTs = uploadValue != null ? int.tryParse(uploadValue) : null;
    int? lastTs;
    if (downloadTs != null && uploadTs != null) {
      lastTs = downloadTs > uploadTs ? downloadTs : uploadTs;
    } else {
      lastTs = downloadTs ?? uploadTs;
    }
    if (lastTs == null) return;
    final nowTs = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
    if (nowTs - lastTs > 20 * 60) {
      await WealthtrackerSync.syncNow(ref);
      if (mounted) updateAssets();
    }
  }

  @override
  void dispose() {
    ServicesBinding.instance.keyboard.removeHandler(_onKey);
    super.dispose();
  }

  bool isPopupsOpen(BuildContext context) => ModalRoute.of(context)?.isCurrent != true;

  bool _onKey(KeyEvent event) {
    final key = event.logicalKey.keyLabel;
    if (event is KeyUpEvent && !isPopupsOpen(context)) {
      if (key == "Arrow Left") {
        date = DateTime(date.year, date.month - 1, date.day);
        updateAssets();
      } else if (key == "Arrow Right") {
        date = DateTime(date.year, date.month + 1, date.day);
        updateAssets();
      }
    }
    return false;
  }

  Future<MonthSummary> dbToUiMonth(WealthtrackerRepository repo) async {
    final ymStr = '${date.year * 100 + date.month}';
    var previousDay = DateTime(date.year, date.month - 1, date.day);
    final prevYmStr = '${previousDay.year * 100 + previousDay.month}';
    final yearMonth = date.year * 100 + date.month;

    final allAssets = await repo.assets.loadAll();
    final comment = await repo.comments.loadByMonth(yearMonth);

    var summary = MonthSummary();
    List<AssetUiModel> mAssets = [];
    List<AssetUiModel> suggestions = [];

    num totalCalc = 0;
    num yesterdayTotal = 0;

    // Calculate previous month total
    for (var asset in allAssets) {
      final prevVal = asset.monthlyValues[prevYmStr];
      if (prevVal != null) yesterdayTotal += prevVal;
    }
    summary.lastMonthSum = yesterdayTotal;

    for (var asset in allAssets) {
      final currentVal = asset.monthlyValues[ymStr];
      final prevVal = asset.monthlyValues[prevYmStr];

      if (currentVal != null) {
        // Asset has a value for the current month
        var change = currentVal - (prevVal ?? 0);
        var percent = getPercent((prevVal ?? 0).toDouble(), currentVal);
        totalCalc += currentVal;
        mAssets.add(AssetUiModel(
          yearMonth: yearMonth,
          name: asset.name,
          value: currentVal,
          lastMonthValue: prevVal ?? 0,
          change: change,
          percent: percent,
          tagIds: asset.tagIds,
          groupId: asset.groupId,
          addNew: false,
        ));
      } else if (prevVal != null) {
        // Asset has previous month value but no current → suggestion
        suggestions.add(AssetUiModel(
          yearMonth: yearMonth,
          name: asset.name,
          value: prevVal,
          lastMonthValue: prevVal,
          tagIds: asset.tagIds,
          groupId: asset.groupId,
          suggestion: true,
        ));
      }
    }

    mAssets.sort((a, b) => (b.value ?? 0.0).compareTo(a.value ?? 0.0));
    suggestions.sort((a, b) => (b.value ?? 0.0).compareTo(a.value ?? 0.0));
    mAssets.addAll(suggestions);

    summary.suggestions = suggestions;
    summary.assets = mAssets;
    summary.comment = comment?.comment;
    summary.currentMonthSum = totalCalc;
    summary.change = summary.currentMonthSum - summary.lastMonthSum;
    summary.percent = getPercent(summary.lastMonthSum.toDouble(), summary.currentMonthSum.toDouble());
    return summary;
  }

  void updateAssets() async {
    final repo = await ref.read(wealthtrackerRepositoryProvider.future);
    var month = await dbToUiMonth(repo);
    final myConf = await repo.conf.load();
    if (mounted) {
      setState(() {
        uiMonth = month;
        allTags = myConf.tags;
        allGroups = myConf.assetGroups;
      });
    }
  }

  Future<void> openDetailView(BuildContext context, AssetUiModel? item) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AssetEditPopup(
        ref: ref,
        currentAsset: item ?? AssetUiModel(yearMonth: (date.year * 100 + date.month), addNew: true),
      ),
    );
    if (result == true) {
      updateAssets();
    }
  }

  Future<void> openCommentPopup() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => CommentPopup(
        ref: ref,
        date: date,
        initialComment: uiMonth.comment ?? "",
      ),
    );
    if (result == true) {
      updateAssets();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = KrypticColors(isDark);
    String formattedDate = DateFormat('MMMM yyyy').format(date);

    return KrypticBaseScreen(
      extendBody: true,
      toolbar: KrypticToolbar(
        leftButton: ToolbarButton(
          icon: Icons.arrow_left,
          onPressed: () {
            date = DateTime(date.year, date.month - 1, date.day);
            updateAssets();
          },
          tooltip: context.l10n.previousMonth,
        ),
        title: formattedDate,
        onTitleTap: () {
          showMonthPicker(
            context: context,
            firstDate: DateTime(DateTime.now().year - 10),
            lastDate: DateTime(DateTime.now().year + 1, 12),
            initialDate: date,
            confirmWidget: Text(context.l10n.ok),
            cancelWidget: Text(context.l10n.cancel),
          ).then((DateTime? picked) {
            if (picked != null) {
              date = picked;
              updateAssets();
            }
          });
        },
        rightButtons: [
          ToolbarButton(
            icon: Icons.arrow_right,
            onPressed: () {
              date = DateTime(date.year, date.month + 1, date.day);
              updateAssets();
            },
            tooltip: context.l10n.nextMonth,
          ),
          ToolbarButton(
            icon: uiMonth.comment == null || uiMonth.comment?.isEmpty == true
                ? Icons.note_outlined
                : Icons.note,
            onPressed: openCommentPopup,
            tooltip: context.l10n.commentTooltip,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButtonConfig(
        icon: Icons.add,
        onPressed: () {
          openDetailView(context, null);
        },
        tooltip: context.l10n.addAssetTooltip,
      ),
      bottomNavigation: WealthtrackerBottomNav(context, 0),
      centerContent: uiMonth.assets.isEmpty,
      content: uiMonth.assets.isEmpty
          ? KrypticEmptyView(
              isEmpty: true,
              icon: Icons.account_balance_outlined,
              title: context.l10n.noAssets,
              subtitle: context.l10n.noAssetsSubtitle,
            )
          : Column(
              children: [
                _summaryCard(colors, formattedDate),
                if (allTags.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _tagFilterBar(),
                ],
                const SizedBox(height: 8),
                ..._buildGroupedList(colors),
                const SizedBox(height: 100),
              ],
            ),
    );
  }

  List<AssetUiModel> get _filteredAssets {
    if (selectedFilterTagIds.isEmpty) return uiMonth.assets;
    return uiMonth.assets.where((asset) {
      return asset.tagIds.any((id) => selectedFilterTagIds.contains(id));
    }).toList();
  }

  List<_AssetGroupDisplay> get _groupedAssets {
    final assets = _filteredAssets;
    final groupMap = <String, AssetGroup>{};
    for (var g in allGroups) {
      groupMap[g.id] = g;
    }

    // Group assets by groupId
    final grouped = <String, List<AssetUiModel>>{};
    final standalone = <AssetUiModel>[];

    for (var asset in assets) {
      if (asset.groupId != null && groupMap.containsKey(asset.groupId)) {
        grouped.putIfAbsent(asset.groupId!, () => []).add(asset);
      } else {
        standalone.add(asset);
      }
    }

    final result = <_AssetGroupDisplay>[];

    // Build group displays
    for (var entry in grouped.entries) {
      final group = groupMap[entry.key]!;
      final groupAssets = entry.value;
      groupAssets.sort((a, b) => (b.value ?? 0).compareTo(a.value ?? 0));
      final netValue = groupAssets.fold<num>(0, (sum, a) => sum + (a.suggestion ? 0 : (a.value ?? 0)));
      result.add(_AssetGroupDisplay(
        groupId: group.id,
        groupName: group.name,
        netValue: netValue,
        assets: groupAssets,
      ));
    }

    // Add standalone assets (each as its own single-item display, no header)
    for (var asset in standalone) {
      result.add(_AssetGroupDisplay(
        netValue: asset.suggestion ? 0 : (asset.value ?? 0),
        assets: [asset],
      ));
    }

    // Sort groups and standalone assets together by net value descending
    result.sort((a, b) => b.netValue.compareTo(a.netValue));

    return result;
  }

  Widget _tagFilterBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: allTags.map((tag) {
          final selected = selectedFilterTagIds.contains(tag.id);
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: FilterChip(
              label: Text(tag.name),
              selected: selected,
              onSelected: (value) {
                setState(() {
                  if (value) {
                    selectedFilterTagIds.add(tag.id);
                  } else {
                    selectedFilterTagIds.remove(tag.id);
                  }
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _summaryCard(KrypticColors colors, String formattedDate) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.cardBackgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            NumberFormat.compact().format(uiMonth.currentMonthSum),
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: colors.primaryText,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.l10n.changeValue(uiMonth.change.toString()),
                style: TextStyle(color: colors.secondaryText, fontSize: 14),
              ),
              _percentBadge(uiMonth.percent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _percentBadge(num? percent) {
    var color = getArrowColor(percent ?? 0);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        "${percent?.toStringAsFixed(1) ?? 0}%",
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  List<Widget> _buildGroupedList(KrypticColors colors) {
    final groups = _groupedAssets;
    final widgets = <Widget>[];

    for (var group in groups) {
      if (group.groupId != null) {
        // Group header
        widgets.add(_groupHeader(group, colors));
        // Indented asset items
        for (var asset in group.assets) {
          widgets.add(Padding(
            padding: const EdgeInsets.only(left: 16),
            child: _assetItem(asset, colors),
          ));
        }
      } else {
        // Standalone asset (no header)
        for (var asset in group.assets) {
          widgets.add(_assetItem(asset, colors));
        }
      }
    }

    return widgets;
  }

  Widget _groupHeader(_AssetGroupDisplay group, KrypticColors colors) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Row(
        children: [
          Icon(Icons.folder_outlined, size: 16, color: colors.secondaryText),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              group.groupName ?? '',
              style: TextStyle(
                color: colors.secondaryText,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            NumberFormat.compact().format(group.netValue),
            style: TextStyle(
              color: colors.secondaryText,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _assetItem(AssetUiModel item, KrypticColors colors) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      tileColor: item.suggestion ? colors.cardBackgroundColor.withValues(alpha: 0.5) : null,
      title: Text(
        item.name ?? "",
        style: TextStyle(color: colors.primaryText),
      ),
      subtitle: item.suggestion
          ? Text(context.l10n.previousMonthValue(item.value?.toString() ?? ""), style: TextStyle(color: colors.secondaryText))
          : Text("${item.value ?? ""}", style: TextStyle(color: colors.secondaryText)),
      trailing: item.suggestion
          ? Text(context.l10n.tapToAdd, style: TextStyle(color: colors.secondaryText, fontSize: 12))
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("${item.change ?? 0}", style: TextStyle(color: colors.primaryText, fontSize: 13)),
                _percentBadge(item.percent ?? 0),
              ],
            ),
      onTap: () {
        openDetailView(context, item);
      },
    );
  }
}
