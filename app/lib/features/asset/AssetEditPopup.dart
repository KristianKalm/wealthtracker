import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kryptic_core/kryptic_core.dart';

import '../../core/db/WealthtrackerRepository.dart';
import '../../core/models/Asset.dart';
import '../../core/models/AssetUiModel.dart';
import '../../core/models/AssetGroup.dart';
import '../../core/models/Tag.dart';
import '../../core/sync/WealthtrackerSync.dart' as WealthtrackerSync;
import '../../core/util/MoneyFormat.dart';
import '../../l10n/l10n.dart';
import '../Providers.dart';
import 'AutofillPopup.dart';

class _CustomTextInputFormatter extends TextInputFormatter {
  final RegExp _allowedRegExp;

  _CustomTextInputFormatter(this._allowedRegExp);

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text == "" || newValue.text == "-" || _allowedRegExp.hasMatch(newValue.text)) {
      return newValue;
    } else {
      return oldValue;
    }
  }
}

class AssetEditPopup extends StatefulWidget {
  final WidgetRef ref;
  final AssetUiModel currentAsset;

  const AssetEditPopup({super.key, required this.ref, required this.currentAsset});

  @override
  State<AssetEditPopup> createState() => _AssetEditPopupState();
}

class _AssetEditPopupState extends State<AssetEditPopup> {
  late TextEditingController nameController;
  late TextEditingController valueController;
  late TextEditingController changeController;
  late bool isAsset;
  late TextEditingController groupController;
  final FocusNode _groupFocusNode = FocusNode();
  late List<String> selectedTagIds;
  List<Tag> allTags = [];
  List<AssetGroup> allGroups = [];
  var valueListener = () {};
  var changeListener = () {};
  Map<String, double> _autofillValues = {};

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.currentAsset.name ?? "");
    valueController = TextEditingController(text: widget.currentAsset.value?.toString() ?? "");
    changeController = TextEditingController(text: widget.currentAsset.change?.toString() ?? "");
    isAsset = valueController.text.isEmpty || !valueController.text.startsWith("-");
    selectedTagIds = List<String>.from(widget.currentAsset.tagIds);
    groupController = TextEditingController();
    _loadConfig();

    valueListener = () {
      changeController.removeListener(changeListener);
      if (valueController.text.isEmpty || valueController.text == "-") {
        widget.currentAsset.value = null;
        changeController.text = roundMoney((widget.currentAsset.lastMonthValue ?? 0) * -1).toString();
      } else {
        widget.currentAsset.value = double.parse(valueController.text);
        changeController.text = roundMoney(((widget.currentAsset.value ?? 0) - (widget.currentAsset.lastMonthValue ?? 0)).toDouble()).toString();
      }
      changeController.addListener(changeListener);
      setState(() {
        isAsset = valueController.text.isEmpty || !valueController.text.startsWith("-");
      });
    };

    changeListener = () {
      valueController.removeListener(valueListener);
      if (changeController.text.isEmpty || changeController.text == "-") {
        valueController.text = roundMoney((widget.currentAsset.lastMonthValue ?? 0).toDouble()).toString();
      } else {
        valueController.text = roundMoney((widget.currentAsset.lastMonthValue ?? 0) + double.parse(changeController.text)).toString();
      }
      widget.currentAsset.value = double.parse(valueController.text);
      valueController.addListener(valueListener);
      setState(() {
        isAsset = valueController.text.isEmpty || !valueController.text.startsWith("-");
      });
    };

    nameController.addListener(() {
      widget.currentAsset.name = nameController.text;
    });
    valueController.addListener(valueListener);
    changeController.addListener(changeListener);
  }

  Future<void> _loadConfig() async {
    final repo = await widget.ref.read(wealthtrackerRepositoryProvider.future);
    final myConf = await repo.conf.load();
    if (mounted) {
      setState(() {
        allTags = myConf.tags;
        allGroups = myConf.assetGroups;
      });
      // Set initial group name from existing groupId
      final gid = widget.currentAsset.groupId;
      if (gid != null) {
        final match = allGroups.where((g) => g.id == gid);
        if (match.isNotEmpty) {
          groupController.text = match.first.name;
        }
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    valueController.dispose();
    changeController.dispose();
    groupController.dispose();
    _groupFocusNode.dispose();
    super.dispose();
  }

  Future<void> _saveAsset() async {
    if (widget.currentAsset.value == null) {
      KrypticSnackbar.showError(context, context.l10n.valueFieldRequired);
      return;
    }

    final repo = await widget.ref.read(wealthtrackerRepositoryProvider.future);
    final yearMonth = widget.currentAsset.yearMonth ?? 0;
    final ymStr = yearMonth.toString();
    final name = widget.currentAsset.name ?? "";

    // Look up existing asset by name to reuse its ID and preserve other months
    final existingAsset = await repo.assets.loadByName(name);

    // Resolve group: match existing by name or create new
    String? resolvedGroupId;
    final groupName = groupController.text.trim();
    if (groupName.isNotEmpty) {
      final match = allGroups.where((g) => g.name == groupName);
      if (match.isNotEmpty) {
        resolvedGroupId = match.first.id;
      } else {
        // Create new group
        final newGroup = AssetGroup(
          id: WealthtrackerRepository.generateId(),
          name: groupName,
        );
        final myConf = await repo.conf.load();
        final updatedGroups = List<AssetGroup>.from(myConf.assetGroups)..add(newGroup);
        final updatedConf = myConf.copyWith(assetGroups: updatedGroups);
        await repo.conf.save(updatedConf);
        resolvedGroupId = newGroup.id;
      }
      // Always ensure group definitions are synced when assigning a group
      WealthtrackerSync.uploadUnsyncedMyConf(widget.ref);
    }

    // Merge new month's value into existing monthlyValues (or start fresh)
    final mv = Map<String, double>.from(existingAsset?.monthlyValues ?? {});
    mv[ymStr] = (widget.currentAsset.value ?? 0).toDouble();
    mv.addAll(_autofillValues);

    final asset = Asset(
      id: existingAsset?.id ?? WealthtrackerRepository.generateId(),
      name: name,
      tagIds: selectedTagIds,
      groupId: resolvedGroupId,
      monthlyValues: mv,
    );
    await repo.assets.save(asset);
    WealthtrackerSync.uploadAsset(widget.ref, asset);
    if (mounted) Navigator.pop(context, true);
  }

  String _getMonthName() {
    final ym = widget.currentAsset.yearMonth ?? 0;
    return DateFormat('MMMM').format(DateTime(ym ~/ 100, ym % 100));
  }

  Future<void> _deleteAsset() async {
    final assetName = widget.currentAsset.name ?? "";
    final monthName = _getMonthName();

    final choice = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.delete),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () => Navigator.pop(ctx, 'deleteMonth'),
              child: Text(context.l10n.deleteMonthValueOnly(monthName)),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () => Navigator.pop(ctx, 'deleteAll'),
              child: Text(context.l10n.deleteAllAssetValues(assetName)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'discard'),
            child: Text(context.l10n.discard),
          ),
        ],
      ),
    );

    if (choice == null || choice == 'discard') return;

    final repo = await widget.ref.read(wealthtrackerRepositoryProvider.future);
    final ymStr = (widget.currentAsset.yearMonth ?? 0).toString();

    final existingAsset = await repo.assets.loadByName(assetName);
    if (existingAsset != null) {
      if (choice == 'deleteAll') {
        existingAsset.monthlyValues.clear();
        await repo.assets.save(existingAsset);
        await WealthtrackerSync.uploadAsset(widget.ref, existingAsset);
        await repo.assets.delete(existingAsset.id);
      } else {
        existingAsset.monthlyValues.remove(ymStr);
        if (existingAsset.monthlyValues.isEmpty) {
          await repo.assets.save(existingAsset);
          await WealthtrackerSync.uploadAsset(widget.ref, existingAsset);
          await repo.assets.delete(existingAsset.id);
        } else {
          await repo.assets.save(existingAsset);
          WealthtrackerSync.uploadAsset(widget.ref, existingAsset);
        }
      }
    }
    if (mounted) Navigator.pop(context, true);
  }

  Future<void> _openAutofill() async {
    final yearMonth = widget.currentAsset.yearMonth ?? 0;
    if (yearMonth == 0) return;
    final valueText = valueController.text;
    final currentValue = (valueText.isEmpty || valueText == '-')
        ? (widget.currentAsset.lastMonthValue ?? 0).toDouble()
        : double.tryParse(valueText) ?? 0.0;

    final result = await AutofillPopup.show(
      context,
      startValue: currentValue,
      startYearMonth: yearMonth,
    );

    if (result != null && mounted) {
      final ymStr = yearMonth.toString();
      final newValue = result[ymStr];
      setState(() {
        _autofillValues = Map.from(result)..remove(ymStr);
        if (newValue != null) {
          valueController.removeListener(valueListener);
          valueController.text = newValue.toString();
          widget.currentAsset.value = newValue;
          isAsset = newValue >= 0;
          valueController.addListener(valueListener);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.enter): _saveAsset,
      },
      child: AlertDialog(
      title: (widget.currentAsset.addNew && !widget.currentAsset.suggestion)
          ? Text(context.l10n.addNewAsset)
          : widget.currentAsset.suggestion
              ? Text(context.l10n.addAssetToMonth(widget.currentAsset.name ?? ""))
              : Text(context.l10n.editAsset(widget.currentAsset.name ?? "")),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SegmentedButton<bool>(
              segments: <ButtonSegment<bool>>[
                ButtonSegment<bool>(value: false, label: Text(context.l10n.liability), icon: Icon(Icons.arrow_downward)),
                ButtonSegment<bool>(value: true, label: Text(context.l10n.asset), icon: Icon(Icons.arrow_upward)),
              ],
              selected: <bool>{isAsset},
              onSelectionChanged: (Set<bool> newSelection) {
                setState(() {
                  if (newSelection.first) {
                    valueController.text = valueController.text.isEmpty ? "" : valueController.text.substring(1);
                  } else {
                    valueController.text = "-${valueController.text}";
                  }
                });
              },
            ),
            const SizedBox(height: 10),
            if (widget.currentAsset.addNew && !widget.currentAsset.suggestion)
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  label: Text(context.l10n.nameLabel),
                  hintText: context.l10n.nameLabel,
                ),
              ),
            if (allTags.isNotEmpty) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: allTags.map((tag) {
                    final selected = selectedTagIds.contains(tag.id);
                    return FilterChip(
                      label: Text(tag.name),
                      selected: selected,
                      onSelected: (value) {
                        setState(() {
                          if (value) {
                            selectedTagIds.add(tag.id);
                          } else {
                            selectedTagIds.remove(tag.id);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
            const SizedBox(height: 10),
            TextField(
              controller: valueController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                label: Text(context.l10n.valueLabel),
                hintText: context.l10n.valueLabel,
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                _CustomTextInputFormatter(RegExp(r'^-?[0-9]+(\.[0-9]*)?$')),
              ],
            ),
            const SizedBox(height: 10),
            if (widget.currentAsset.lastMonthValue != 0 &&
                (widget.currentAsset.yearMonth != null || widget.currentAsset.suggestion) &&
                !widget.currentAsset.addNew)
              TextField(
                controller: changeController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  label: Text(context.l10n.changeFieldLabel),
                  hintText: context.l10n.changeFieldLabel,
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [_CustomTextInputFormatter(RegExp(r'^-?[0-9]+(\.[0-9]*)?$'))],
              ),
            const SizedBox(height: 10),
            RawAutocomplete<AssetGroup>(
              textEditingController: groupController,
              focusNode: _groupFocusNode,
              optionsBuilder: (textEditingValue) {
                if (textEditingValue.text.isEmpty) return allGroups;
                return allGroups.where((g) =>
                  g.name.toLowerCase().contains(textEditingValue.text.toLowerCase()));
              },
              displayStringForOption: (group) => group.name,
              fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    label: Text(context.l10n.groupLabel),
                    hintText: context.l10n.enterOrSelectGroup,
                  ),
                );
              },
              optionsViewBuilder: (context, onSelected, options) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    elevation: 4,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: options.length,
                        itemBuilder: (context, index) {
                          final group = options.elementAt(index);
                          return ListTile(
                            dense: true,
                            title: Text(group.name),
                            onTap: () => onSelected(group),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              icon: const Icon(Icons.auto_fix_high),
              label: Text(_autofillValues.isEmpty
                  ? context.l10n.autofill
                  : context.l10n.autofillMonthsApplied(_autofillValues.length)),
              onPressed: _openAutofill,
            ),
            const SizedBox(height: 10),
            if (!widget.currentAsset.addNew && !widget.currentAsset.suggestion)
              OutlinedButton(
                style: ButtonStyle(
                  foregroundColor: WidgetStateProperty.all<Color>(Colors.red),
                ),
                onPressed: _deleteAsset,
                child: Text(context.l10n.delete),
              ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(context.l10n.cancel),
        ),
        TextButton(
          onPressed: _saveAsset,
          child: Text(context.l10n.save),
        ),
      ],
    ),
    );
  }
}
