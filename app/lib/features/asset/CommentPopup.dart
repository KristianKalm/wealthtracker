import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/db/WealthtrackerRepository.dart';
import '../../core/models/Comment.dart';
import '../../core/sync/WealthtrackerSync.dart' as WealthtrackerSync;
import '../../l10n/l10n.dart';
import '../Providers.dart';

class CommentPopup extends StatefulWidget {
  final WidgetRef ref;
  final DateTime date;
  final String initialComment;

  const CommentPopup({super.key, required this.ref, required this.date, required this.initialComment});

  @override
  State<CommentPopup> createState() => _CommentPopupState();
}

class _CommentPopupState extends State<CommentPopup> {
  late TextEditingController commentController;

  @override
  void initState() {
    super.initState();
    commentController = TextEditingController(text: widget.initialComment);
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final repo = await widget.ref.read(wealthtrackerRepositoryProvider.future);
    int yearMonth = widget.date.year * 100 + widget.date.month;

    // Check if there's already a comment for this month
    final existing = await repo.comments.loadByMonth(yearMonth);
    final comment = Comment(
      id: existing?.id ?? WealthtrackerRepository.generateId(),
      yearMonth: yearMonth,
      comment: commentController.text,
    );
    await repo.comments.save(comment);
    WealthtrackerSync.uploadComment(widget.ref, comment);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('MMMM yyyy').format(widget.date);
    return AlertDialog(
      title: Text(context.l10n.commentForDate(formattedDate)),
      content: TextField(
        controller: commentController,
        keyboardType: TextInputType.multiline,
        minLines: 3,
        maxLines: 10,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          label: Text(context.l10n.commentLabel),
          hintText: context.l10n.addComment,
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(context.l10n.cancel),
        ),
        TextButton(
          onPressed: _save,
          child: Text(context.l10n.save),
        ),
      ],
    );
  }
}
