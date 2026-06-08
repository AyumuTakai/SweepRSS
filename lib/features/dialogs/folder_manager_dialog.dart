import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' show Value;

import '../../core/database/app_database.dart';
import '../../shared/providers/active_space_provider.dart';
import '../../shared/providers/database_provider.dart';
import '../../shared/providers/refresh_provider.dart';
import '../../shared/widgets/toast_overlay.dart';

class FolderManagerDialog extends ConsumerWidget {
  const FolderManagerDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final foldersAsync = ref.watch(foldersStreamProvider);

    return AlertDialog(
      title: const Text('フォルダを管理'),
      content: SizedBox(
        width: 400,
        height: 400,
        child: foldersAsync.when(
          data: (folders) => _FolderList(folders: folders),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('エラー: $e'),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('閉じる'),
        ),
        FilledButton(
          onPressed: () => _showAddFolderDialog(context, ref),
          child: const Text('フォルダを追加'),
        ),
      ],
    );
  }

  void _showAddFolderDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('新しいフォルダ'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'フォルダ名'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              final db = ref.read(databaseProvider);
              final activeSpace = ref.read(resolvedActiveSpaceProvider);
              final folders = await db.foldersDao.getAllFolders();
              await db.foldersDao.insertFolder(FoldersCompanion.insert(
                id: const Uuid().v4(),
                name: name,
                order: Value(folders.length),
                spaceId: Value(activeSpace?.id),
              ));
              ref.read(toastProvider.notifier).show('フォルダを作成しました');
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: const Text('作成'),
          ),
        ],
      ),
    );
  }
}

class _FolderList extends ConsumerWidget {
  final List<Folder> folders;
  const _FolderList({required this.folders});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (folders.isEmpty) {
      return const Center(child: Text('フォルダがありません'));
    }
    return ListView.builder(
      itemCount: folders.length,
      itemBuilder: (context, i) {
        final folder = folders[i];
        return ListTile(
          leading: const Icon(Icons.folder),
          title: Text(folder.name),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, size: 18),
                onPressed: () => _showRenameDialog(context, ref, folder),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 18),
                onPressed: () async {
                  await ref.read(databaseProvider).foldersDao.deleteFolder(folder.id);
                  ref.read(toastProvider.notifier).show('フォルダを削除しました');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showRenameDialog(BuildContext context, WidgetRef ref, Folder folder) {
    final controller = TextEditingController(text: folder.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('フォルダ名を変更'),
        content: TextField(
          controller: controller,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              await ref.read(databaseProvider).foldersDao.renameFolder(folder.id, name);
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: const Text('変更'),
          ),
        ],
      ),
    );
  }
}
