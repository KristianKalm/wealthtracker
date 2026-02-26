import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/WealthtrackerRepository.dart';
import '../../core/models/AssetGroup.dart';
import 'package:kryptic_core/kryptic_core.dart';
import '../../l10n/l10n.dart';
import '../Providers.dart';
import 'AssetGroupEditScreen.dart';

class AssetGroupListScreen extends ConsumerStatefulWidget {
  const AssetGroupListScreen({super.key});

  @override
  ConsumerState<AssetGroupListScreen> createState() => _AssetGroupListScreenState();
}

class _AssetGroupListScreenState extends ConsumerState<AssetGroupListScreen> {
  List<AssetGroup> groupList = [];

  void load() async {
    final repo = await ref.read(wealthtrackerRepositoryProvider.future);
    final myConf = await repo.conf.load();
    if (mounted) {
      setState(() {
        groupList = myConf.assetGroups;
      });
    }
  }

  Future<void> openDetailView(BuildContext context, AssetGroup item) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AssetGroupEditScreen(group: item)),
    );
    if (!mounted) return;
    load();
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  Widget build(BuildContext context) {
    return KrypticBaseScreen(
      extendBody: true,
      toolbar: KrypticToolbar(
        leftButton: ToolbarButton(
          icon: Icons.arrow_back,
          onPressed: () => Navigator.of(context).pop(),
          tooltip: context.l10n.back,
        ),
        title: context.l10n.assetGroups,
      ),
      floatingActionButton: FloatingActionButtonConfig(
        icon: Icons.add,
        onPressed: () {
          openDetailView(
            context,
            AssetGroup(
              id: WealthtrackerRepository.generateId(),
              name: '',
            ),
          );
        },
        tooltip: context.l10n.addGroup,
      ),
      centerContent: groupList.isEmpty,
      content: groupList.isEmpty
          ? KrypticEmptyView(
              isEmpty: true,
              icon: Icons.folder_outlined,
              title: context.l10n.noGroupsYet,
              subtitle: context.l10n.noGroupsSubtitle,
            )
          : ListView.builder(
              shrinkWrap: true,
              itemCount: groupList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    child: Icon(Icons.folder_outlined),
                  ),
                  title: Text(groupList[index].name),
                  onTap: () {
                    openDetailView(context, groupList[index]);
                  },
                );
              },
            ),
    );
  }
}
