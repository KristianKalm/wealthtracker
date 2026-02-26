import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/WealthtrackerRepository.dart';
import '../../core/models/Tag.dart';
import 'package:kryptic_ui/kryptic_ui.dart';
import '../../l10n/l10n.dart';
import '../Providers.dart';
import 'TagEditScreen.dart';

class TagListScreen extends ConsumerStatefulWidget {
  const TagListScreen({super.key});

  @override
  ConsumerState<TagListScreen> createState() => _TagListScreenState();
}

class _TagListScreenState extends ConsumerState<TagListScreen> {
  List<Tag> tagList = [];

  void load() async {
    final repo = await ref.read(wealthtrackerRepositoryProvider.future);
    final myConf = await repo.conf.load();
    if (mounted) {
      setState(() {
        tagList = myConf.tags;
      });
    }
  }

  Future<void> openDetailView(BuildContext context, Tag item) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TagEditScreen(tag: item)),
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
        title: context.l10n.tags,
      ),
      floatingActionButton: FloatingActionButtonConfig(
        icon: Icons.add,
        onPressed: () {
          openDetailView(
            context,
            Tag(
              id: WealthtrackerRepository.generateId(),
              name: '',
            ),
          );
        },
        tooltip: context.l10n.addTag,
      ),
      centerContent: tagList.isEmpty,
      content: tagList.isEmpty
          ? KrypticEmptyView(
              isEmpty: true,
              icon: Icons.label_outline,
              title: context.l10n.noTagsYet,
              subtitle: context.l10n.noTagsSubtitle,
            )
          : ListView.builder(
              shrinkWrap: true,
              itemCount: tagList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    child: Icon(Icons.label),
                  ),
                  title: Text(tagList[index].name),
                  onTap: () {
                    openDetailView(context, tagList[index]);
                  },
                );
              },
            ),
    );
  }
}
