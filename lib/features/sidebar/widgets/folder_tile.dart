import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/models/selection.dart';
import '../../../shared/providers/database_provider.dart';
import '../../../shared/providers/folder_expanded_provider.dart';
import '../../../shared/providers/selection_provider.dart';
import '../../articles/providers/articles_provider.dart';
import 'feed_tile.dart';

class FolderTile extends ConsumerWidget {
  final Folder folder;
  final List<Folder> allFolders;
  final List<Feed> feeds;
  /// 親から宣言的に渡される開閉マップ（再帰的に伝播）
  final Map<String, bool> expandedMap;
  /// 親から宣言的に渡される現在の選択状態（再帰的に伝播）
  /// このコンポーネント自身は selectionProvider を watch しない。
  final Selection selection;

  const FolderTile({
    super.key,
    required this.folder,
    required this.allFolders,
    required this.feeds,
    required this.expandedMap,
    required this.selection,
  });

  List<Feed> _feedsInSubtree(String folderId) {
    final result = <Feed>[];
    result.addAll(feeds.where((f) => f.folderId == folderId));
    for (final sub in allFolders.where((f) => f.parent == folderId)) {
      result.addAll(_feedsInSubtree(sub.id));
    }
    return result;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 選択状態・開閉状態はいずれも親から受け取った値で判定する
    final isSelected =
        selection is SelectionFolder &&
        (selection as SelectionFolder).folderId == folder.id;
    final isExpanded = expandedMap[folder.id] ?? true;

    final subfolders =
        allFolders.where((f) => f.parent == folder.id).toList();
    final feedsInFolder =
        feeds.where((f) => f.folderId == folder.id).toList();

    // unreadCount は feed ごとに独立して変化するため、ここで watch するのが適切
    final feedsInSubtree = _feedsInSubtree(folder.id);
    final totalUnread = feedsInSubtree.fold<int>(0, (sum, feed) {
      final count = ref.watch(unreadCountProvider(feed.id)).valueOrNull ?? 0;
      return sum + count;
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DragTarget<Feed>(
          onWillAcceptWithDetails: (details) =>
              details.data.folderId != folder.id,
          onAcceptWithDetails: (details) async {
            await ref
                .read(databaseProvider)
                .feedsDao
                .moveFeed(details.data.id, folder.id);
            if (!(expandedMap[folder.id] ?? true)) {
              ref.read(folderExpandedProvider.notifier).toggle(folder.id);
            }
          },
          builder: (context, candidateData, rejectedData) {
            final isHovered = candidateData.isNotEmpty;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              decoration: isHovered
                  ? BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .secondary
                          .withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    )
                  : null,
              child: GestureDetector(
                onSecondaryTapDown: (details) =>
                    _showContextMenu(context, ref, details.globalPosition),
                child: ListTile(
                  dense: true,
                  leading: Icon(
                    (isHovered || isExpanded)
                        ? Icons.folder_open
                        : Icons.folder,
                    size: 16,
                    color: isHovered
                        ? Theme.of(context).colorScheme.secondary
                        : null,
                  ),
                  title: Text(folder.name,
                      style: const TextStyle(fontSize: 13)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (totalUnread > 0) _UnreadBadge(count: totalUnread),
                      const SizedBox(width: 2),
                      Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more,
                        size: 14,
                      ),
                    ],
                  ),
                  selected: isSelected,
                  selectedTileColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  onTap: () {
                    ref
                        .read(folderExpandedProvider.notifier)
                        .toggle(folder.id);
                    ref.read(selectionProvider.notifier).state =
                        SelectionFolder(folder.id);
                  },
                ),
              ),
            );
          },
        ),
        if (isExpanded) ...[
          // expandedMap と selection を再帰的に伝播
          ...subfolders.map((sub) => Padding(
                padding: const EdgeInsets.only(left: 16),
                child: FolderTile(
                  folder: sub,
                  allFolders: allFolders,
                  feeds: feeds,
                  expandedMap: expandedMap,
                  selection: selection,
                ),
              )),
          // isSelected を親（FolderTile）が計算して渡す
          ...feedsInFolder.map((feed) => Padding(
                padding: const EdgeInsets.only(left: 16),
                child: FeedTile(
                  feed: feed,
                  isSelected: selection is SelectionFeed &&
                      (selection as SelectionFeed).feedId == feed.id,
                ),
              )),
        ],
      ],
    );
  }

  void _showContextMenu(
      BuildContext context, WidgetRef ref, Offset position) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
          position.dx, position.dy, position.dx + 1, position.dy + 1),
      items: [
        PopupMenuItem(
          child: const ListTile(
            dense: true,
            leading: Icon(Icons.drive_file_rename_outline, size: 16),
            title: Text('リネーム'),
            contentPadding: EdgeInsets.zero,
          ),
          onTap: () => Future.microtask(() {
            if (context.mounted) _showRenameDialog(context, ref);
          }),
        ),
        PopupMenuItem(
          child: const ListTile(
            dense: true,
            leading: Icon(Icons.delete_outline, size: 16, color: Colors.red),
            title: Text('削除', style: TextStyle(color: Colors.red)),
            contentPadding: EdgeInsets.zero,
          ),
          onTap: () => Future.microtask(() {
            if (context.mounted) _showDeleteDialog(context, ref);
          }),
        ),
      ],
    );
  }

  Future<void> _showRenameDialog(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController(text: folder.name);
    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('フォルダをリネーム'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'フォルダ名'),
          onSubmitted: (v) => Navigator.pop(ctx, v.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('変更'),
          ),
        ],
      ),
    );
    if (newName != null && newName.isNotEmpty && newName != folder.name) {
      await ref
          .read(databaseProvider)
          .foldersDao
          .renameFolder(folder.id, newName);
    }
  }

  Future<void> _showDeleteDialog(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('「${folder.name}」を削除'),
        content: const Text(
          'フォルダを削除します。\n'
          'フォルダ内のフィードはゴミ箱に移動されます。\n'
          'サブフォルダは未分類に移動されます。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('削除'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final db = ref.read(databaseProvider);
    await db.feedsDao.trashFeedsInFolder(folder.id);
    await db.foldersDao.detachSubfolders(folder.id);
    await db.foldersDao.deleteFolder(folder.id);

    final sel = ref.read(selectionProvider);
    if (sel is SelectionFolder && sel.folderId == folder.id) {
      ref.read(selectionProvider.notifier).state = const SelectionAll();
    }
  }
}

class _UnreadBadge extends StatelessWidget {
  final int count;
  const _UnreadBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
