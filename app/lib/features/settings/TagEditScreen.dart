import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/Tag.dart';
import '../../core/sync/WealthtrackerSync.dart' as WealthtrackerSync;
import 'package:kryptic_core/kryptic_core.dart';
import '../../l10n/l10n.dart';
import '../Providers.dart';

class TagEditScreen extends ConsumerStatefulWidget {
  final Tag tag;

  const TagEditScreen({super.key, required this.tag});

  @override
  ConsumerState<TagEditScreen> createState() => _TagEditScreenState();
}

class _TagEditScreenState extends ConsumerState<TagEditScreen> {
  late TextEditingController nameController;
  late Tag currentTag;

  @override
  void initState() {
    super.initState();
    currentTag = widget.tag;
    nameController = TextEditingController(text: currentTag.name);
    nameController.addListener(() {
      currentTag.name = nameController.text;
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
        title: context.l10n.editTag,
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
              label: Text(context.l10n.tagName),
              hintText: context.l10n.enterTagName,
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
      tags: myConf.tags.where((t) => t.id != currentTag.id).toList(),
    );

    await repo.conf.save(updatedConf);
    WealthtrackerSync.uploadMyConf(ref);
    if (mounted) Navigator.pop(context);
  }

  Future<void> save() async {
    if (nameController.text.trim().isEmpty) {
      KrypticSnackbar.showError(context, context.l10n.tagNameEmpty);
      return;
    }

    final repo = await ref.read(wealthtrackerRepositoryProvider.future);
    final myConf = await repo.conf.load();

    final tagIndex = myConf.tags.indexWhere((t) => t.id == currentTag.id);
    final updatedTags = List<Tag>.from(myConf.tags);

    if (tagIndex >= 0) {
      updatedTags[tagIndex] = currentTag;
    } else {
      updatedTags.add(currentTag);
    }

    final updatedConf = myConf.copyWith(tags: updatedTags);
    await repo.conf.save(updatedConf);
    WealthtrackerSync.uploadMyConf(ref);
    if (mounted) Navigator.pop(context);
  }
}
