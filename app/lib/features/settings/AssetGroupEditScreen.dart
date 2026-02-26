import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/AssetGroup.dart';
import '../../core/sync/WealthtrackerSync.dart' as WealthtrackerSync;
import 'package:kryptic_ui/kryptic_ui.dart';
import '../../l10n/l10n.dart';
import '../Providers.dart';

class AssetGroupEditScreen extends ConsumerStatefulWidget {
  final AssetGroup group;

  const AssetGroupEditScreen({super.key, required this.group});

  @override
  ConsumerState<AssetGroupEditScreen> createState() => _AssetGroupEditScreenState();
}

class _AssetGroupEditScreenState extends ConsumerState<AssetGroupEditScreen> {
  late TextEditingController nameController;
  late AssetGroup currentGroup;

  @override
  void initState() {
    super.initState();
    currentGroup = widget.group;
    nameController = TextEditingController(text: currentGroup.name);
    nameController.addListener(() {
      currentGroup.name = nameController.text;
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KrypticBaseScreen(
      toolbar: KrypticToolbar(
        leftButton: ToolbarButton(
          icon: Icons.arrow_back,
          onPressed: () => Navigator.pop(context),
          tooltip: context.l10n.back,
        ),
        title: context.l10n.editGroup,
        rightButtons: [
          ToolbarButton(
            icon: Icons.delete,
            onPressed: delete,
            tooltip: context.l10n.delete,
          ),
        ],
      ),
      saveButton: SaveButtonConfig(
        label: context.l10n.save,
        onPressed: save,
        tooltip: context.l10n.save,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const SizedBox(height: 10),
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              label: Text(context.l10n.groupName),
              hintText: context.l10n.enterGroupName,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> delete() async {
    final repo = await ref.read(wealthtrackerRepositoryProvider.future);
    final myConf = await repo.conf.load();

    final updatedConf = myConf.copyWith(
      assetGroups: myConf.assetGroups.where((g) => g.id != currentGroup.id).toList(),
    );

    await repo.conf.save(updatedConf);
    WealthtrackerSync.uploadMyConf(ref);
    if (mounted) Navigator.pop(context);
  }

  Future<void> save() async {
    if (nameController.text.trim().isEmpty) {
      KrypticSnackbar.showError(context, context.l10n.groupNameEmpty);
      return;
    }

    final repo = await ref.read(wealthtrackerRepositoryProvider.future);
    final myConf = await repo.conf.load();

    final groupIndex = myConf.assetGroups.indexWhere((g) => g.id == currentGroup.id);
    final updatedGroups = List<AssetGroup>.from(myConf.assetGroups);

    if (groupIndex >= 0) {
      updatedGroups[groupIndex] = currentGroup;
    } else {
      updatedGroups.add(currentGroup);
    }

    final updatedConf = myConf.copyWith(assetGroups: updatedGroups);
    await repo.conf.save(updatedConf);
    WealthtrackerSync.uploadMyConf(ref);
    if (mounted) Navigator.pop(context);
  }
}
