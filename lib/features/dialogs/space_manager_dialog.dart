import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shared/providers/active_space_provider.dart';
import '../../shared/providers/database_provider.dart';
import '../../shared/widgets/toast_overlay.dart';

class SpaceManagerDialog extends ConsumerWidget {
  const SpaceManagerDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final spacesAsync = ref.watch(spacesStreamProvider);

    return AlertDialog(
      title: Text(l10n.spaceManagerDialogTitle),
      content: SizedBox(
        width: 400,
        height: 400,
        child: spacesAsync.when(
          data: (spaces) => _SpaceList(spaces: spaces),
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
          onPressed: () => _showAddSpaceDialog(context, ref),
          child: Text(l10n.spaceManagerAddButton),
        ),
      ],
    );
  }

  void _showAddSpaceDialog(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.spaceManagerAddDialogTitle),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: l10n.spaceNameLabel),
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
              final newId = await db.spacesDao.insertSpace(name);
              // 作成したスペースをすぐにアクティブにする
              ref.read(activeSpaceProvider.notifier).setSpace(newId);
              ref.read(toastProvider.notifier).show(l10n.toastSpaceCreated(name));
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: Text(l10n.dialogCreate),
          ),
        ],
      ),
    );
  }
}

class _SpaceList extends ConsumerWidget {
  final List<Space> spaces;
  const _SpaceList({required this.spaces});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    if (spaces.isEmpty) {
      return Center(child: Text(l10n.spaceManagerEmpty));
    }

    final activeSpace = ref.watch(resolvedActiveSpaceProvider);

    return ReorderableListView.builder(
      itemCount: spaces.length,
      buildDefaultDragHandles: false,
      itemBuilder: (context, i) {
        final space = spaces[i];
        final isActive = activeSpace?.id == space.id;
        return ListTile(
          key: ValueKey(space.id),
          leading: ReorderableDragStartListener(
            index: i,
            child: const Icon(Icons.drag_handle, size: 18),
          ),
          title: Text(
            space.name,
            style: isActive
                ? TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  )
                : null,
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, size: 18),
                onPressed: () => _showRenameDialog(context, ref, space),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 18),
                onPressed: spaces.length <= 1
                    ? null
                    : () => _confirmDelete(context, ref, space, spaces),
              ),
            ],
          ),
          onTap: () {
            ref.read(activeSpaceProvider.notifier).setSpace(space.id);
            Navigator.of(context).pop();
          },
        );
      },
      onReorderItem: (oldIndex, newIndex) async {
        final db = ref.read(databaseProvider);
        final list = [...spaces];
        final item = list.removeAt(oldIndex);
        list.insert(newIndex, item);
        for (int i = 0; i < list.length; i++) {
          await db.spacesDao.reorderSpace(list[i].id, i);
        }
      },
    );
  }

  void _showRenameDialog(BuildContext context, WidgetRef ref, Space space) {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController(text: space.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.spaceManagerRenameDialogTitle),
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
                  .spacesDao
                  .renameSpace(space.id, name);
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: Text(l10n.dialogChange),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Space space,
    List<Space> spaces,
  ) async {
    final l10n = AppLocalizations.of(context);
    // 削除後のフォールバックスペース（別のスペースを選ぶ）
    final fallback = spaces.firstWhere((s) => s.id != space.id);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.spaceDeleteDialogTitle(space.name)),
        content: Text(l10n.spaceDeleteDialogBody(fallback.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.dialogCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.dialogDelete),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final db = ref.read(databaseProvider);
    // アクティブスペースを削除する場合はフォールバックへ切り替え
    final current = ref.read(resolvedActiveSpaceProvider);
    if (current?.id == space.id) {
      ref.read(activeSpaceProvider.notifier).setSpace(fallback.id);
    }
    await db.spacesDao.deleteSpace(space.id, fallback.id);
    if (context.mounted) {
      ref.read(toastProvider.notifier).show(l10n.toastSpaceDeleted);
    }
  }
}
