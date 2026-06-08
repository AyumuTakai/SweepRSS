import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' show Value;

import '../../core/database/app_database.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shared/providers/active_space_provider.dart';
import '../../shared/providers/database_provider.dart';
import '../../shared/providers/refresh_provider.dart';
import '../../shared/widgets/toast_overlay.dart';

class FolderManagerDialog extends ConsumerWidget {
  const FolderManagerDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final foldersAsync = ref.watch(foldersStreamProvider);

    return AlertDialog(
      title: Text(l10n.folderManagerDialogTitle),
      content: SizedBox(
        width: 400,
        height: 400,
        child: foldersAsync.when(
          data: (folders) => _FolderList(folders: folders),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) =>
              Text(l10n.sidebarErrorLabel(e.toString())),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.dialogClose),
        ),
        FilledButton(
          onPressed: () => _showAddFolderDialog(context, ref),
          child: Text(l10n.folderManagerAddButton),
        ),
      ],
    );
  }

  void _showAddFolderDialog(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.folderManagerAddDialogTitle),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: l10n.folderNameLabel),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.dialogCancel),
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
              ref.read(toastProvider.notifier).show(l10n.toastFolderCreated);
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: Text(l10n.dialogCreate),
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
    final l10n = AppLocalizations.of(context);
    if (folders.isEmpty) {
      return Center(child: Text(l10n.folderManagerEmpty));
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
                  await ref
                      .read(databaseProvider)
                      .foldersDao
                      .deleteFolder(folder.id);
                  if (context.mounted) {
                    ref
                        .read(toastProvider.notifier)
                        .show(AppLocalizations.of(context).toastFolderDeleted);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showRenameDialog(BuildContext context, WidgetRef ref, Folder folder) {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController(text: folder.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.folderManagerRenameDialogTitle),
        content: TextField(
          controller: controller,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.dialogCancel),
          ),
          FilledButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              await ref
                  .read(databaseProvider)
                  .foldersDao
                  .renameFolder(folder.id, name);
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: Text(l10n.dialogChange),
          ),
        ],
      ),
    );
  }
}
