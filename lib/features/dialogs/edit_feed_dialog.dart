import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shared/providers/database_provider.dart';
import '../../shared/widgets/toast_overlay.dart';

class EditFeedDialog extends ConsumerStatefulWidget {
  final Feed feed;
  const EditFeedDialog({super.key, required this.feed});

  @override
  ConsumerState<EditFeedDialog> createState() => _EditFeedDialogState();
}

class _EditFeedDialogState extends ConsumerState<EditFeedDialog> {
  late final TextEditingController _titleController;
  late bool _requiresExternalBrowser;
  late bool _useRssContent;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.feed.title ?? '');
    _requiresExternalBrowser = widget.feed.requiresExternalBrowser;
    _useRssContent = widget.feed.useRssContent;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final db = ref.read(databaseProvider);
    final newTitle = _titleController.text.trim();
    if (newTitle.isNotEmpty && newTitle != widget.feed.title) {
      await db.feedsDao.renameFeed(widget.feed.id, newTitle);
    }
    if (_requiresExternalBrowser != widget.feed.requiresExternalBrowser) {
      await db.feedsDao.setRequiresExternalBrowser(widget.feed.id, _requiresExternalBrowser);
    }
    if (_useRssContent != widget.feed.useRssContent) {
      await db.feedsDao.setUseRssContent(widget.feed.id, _useRssContent);
    }
    if (mounted) {
      ref
          .read(toastProvider.notifier)
          .show(AppLocalizations.of(context).toastFeedUpdated);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.editFeedDialogTitle),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: l10n.editFeedTitleLabel),
            ),
            const SizedBox(height: 12),
            CheckboxListTile(
              title: Text(l10n.editFeedExternalBrowserLabel,
                  style: const TextStyle(fontSize: 13)),
              subtitle: Text(l10n.editFeedExternalBrowserSubtitle,
                  style: const TextStyle(fontSize: 11)),
              value: _requiresExternalBrowser,
              onChanged: (v) =>
                  setState(() => _requiresExternalBrowser = v ?? false),
            ),
            CheckboxListTile(
              title: Text(l10n.editFeedUseRssContentLabel,
                  style: const TextStyle(fontSize: 13)),
              subtitle: Text(l10n.editFeedUseRssContentSubtitle,
                  style: const TextStyle(fontSize: 11)),
              value: _useRssContent,
              onChanged: (v) =>
                  setState(() => _useRssContent = v ?? true),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.link, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    widget.feed.url,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.dialogCancel),
        ),
        FilledButton(onPressed: _save, child: Text(l10n.dialogSave)),
      ],
    );
  }
}
