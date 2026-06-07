import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
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

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.feed.title ?? '');
    _requiresExternalBrowser = widget.feed.requiresExternalBrowser;
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
    ref.read(toastProvider.notifier).show('フィードを更新しました');
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('フィードを編集'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'タイトル'),
            ),
            const SizedBox(height: 12),
            CheckboxListTile(
              title: const Text('外部ブラウザで開く', style: TextStyle(fontSize: 13)),
              subtitle: const Text('JS が多いサイト向け', style: TextStyle(fontSize: 11)),
              value: _requiresExternalBrowser,
              onChanged: (v) => setState(() => _requiresExternalBrowser = v ?? false),
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
          child: const Text('キャンセル'),
        ),
        FilledButton(onPressed: _save, child: const Text('保存')),
      ],
    );
  }
}
