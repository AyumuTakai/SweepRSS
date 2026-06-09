import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/models/selection.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/providers/active_space_provider.dart';
import '../../../shared/providers/database_provider.dart';
import '../../../shared/providers/folder_expanded_provider.dart';
import '../../../shared/providers/refresh_provider.dart';
import '../../../shared/providers/selection_provider.dart';
import '../../../shared/widgets/toast_overlay.dart';
import '../../dialogs/add_feed_dialog.dart';
import '../../dialogs/folder_manager_dialog.dart';
import '../../articles/providers/articles_provider.dart';
import '../../opml/opml_import_provider.dart';
import '../../../shared/providers/unread_snapshot_provider.dart';
import 'folder_tile.dart';
import 'feed_tile.dart';
import 'space_switcher.dart';

class SidebarPanel extends ConsumerWidget {
  const SidebarPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeSpace = ref.watch(resolvedActiveSpaceProvider);
    final feedsAsync = ref.watch(feedsStreamProvider);
    final foldersAsync = activeSpace != null
        ? ref.watch(spaceFoldersStreamProvider(activeSpace.id))
        : ref.watch(foldersStreamProvider);
    final selection = ref.watch(selectionProvider);
    final refreshState = ref.watch(refreshProvider);

    return SizedBox(
      width: 220,
      child: Material(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        child: Column(
          children: [
            _SidebarHeader(isRefreshing: refreshState.isRefreshing),
            const SpaceSwitcher(),
            Expanded(
              child: ListView(
                children: [
                  _NavItem(
                    icon: Icons.all_inbox,
                    label: AppLocalizations.of(context).navAll,
                    selected: selection is SelectionAll,
                    unreadCount: ref.watch(totalUnreadCountProvider).when(
                      data: (data) => data,
                      loading: () => null,
                      error: (_, _) => null,
                    ),
                    onTap: () => ref.read(selectionProvider.notifier).state =
                        const SelectionAll(),
                  ),
                  _NavItem(
                    icon: Icons.mark_email_unread,
                    label: AppLocalizations.of(context).navUnread,
                    selected: selection is SelectionUnread,
                    onTap: () {
                      ref.read(selectionProvider.notifier).state =
                          const SelectionUnread();
                      // スナップショットを初期化（すでに初期化済みなら何もしない）
                      ref.read(unreadSnapshotProvider.notifier).initialize();
                    },
                  ),
                  _NavItem(
                    icon: Icons.bookmark,
                    label: AppLocalizations.of(context).navFlagged,
                    selected: selection is SelectionFlagged,
                    onTap: () => ref.read(selectionProvider.notifier).state =
                        const SelectionFlagged(),
                  ),
                  const Divider(height: 1),
                  foldersAsync.when(
                    data: (folders) => feedsAsync.when(
                      data: (feeds) => _SidebarItemList(
                        folders: folders,
                        feeds: feeds,
                        selection: selection,
                        activeSpace: activeSpace,
                      ),
                      loading: () => const SizedBox.shrink(),
                      error: (e, st) => const SizedBox.shrink(),
                    ),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Text(
                        AppLocalizations.of(context)
                            .sidebarErrorLabel(e.toString())),
                  ),
                  const Divider(height: 1),
                  const _TrashTile(),
                ],
              ),
            ),
            _ImportProgressBar(),
            if (refreshState.isRefreshing)
              LinearProgressIndicator(
                value: refreshState.total > 0
                    ? refreshState.done / refreshState.total
                    : null,
              ),
          ],
        ),
      ),
    );
  }
}

class _SidebarHeader extends ConsumerWidget {
  final bool isRefreshing;
  const _SidebarHeader({required this.isRefreshing});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.add, size: 18),
            tooltip: AppLocalizations.of(context).sidebarAddFeedTooltip,
            onPressed: () => showDialog(
              context: context,
              builder: (_) => const AddFeedDialog(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.create_new_folder_outlined, size: 18),
            tooltip: AppLocalizations.of(context).sidebarManageFoldersTooltip,
            onPressed: () => showDialog(
              context: context,
              builder: (_) => const FolderManagerDialog(),
            ),
          ),
          const Spacer(),
          IconButton(
            icon: isRefreshing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.refresh, size: 18),
            tooltip: AppLocalizations.of(context).sidebarRefreshTooltip,
            onPressed: isRefreshing
                ? null
                : () => ref.read(refreshProvider.notifier).refreshAll(),
          ),
        ],
      ),
    );
  }
}

class _ImportProgressBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final importState = ref.watch(opmlImportProvider);

    // 完了・エラー時にトーストを表示してリセット
    final l10n = AppLocalizations.of(context);
    ref.listen(opmlImportProvider, (prev, next) {
      if (next.status == OpmlImportStatus.done) {
        final msg = next.importedFeeds == 0
            ? l10n.opmlImportFoldersOnly(next.importedFolders)
            : l10n.opmlImportComplete(next.importedFeeds, next.importedFolders);
        ref.read(toastProvider.notifier).show(msg);
        Future.microtask(() => ref.read(opmlImportProvider.notifier).reset());
      } else if (next.status == OpmlImportStatus.error) {
        ref.read(toastProvider.notifier).showError(
              l10n.opmlImportError(next.rawError ?? l10n.errorUnknown),
            );
        Future.microtask(() => ref.read(opmlImportProvider.notifier).reset());
      }
    });

    if (!importState.isRunning) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(value: importState.progress),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          child: Text(
            _statusLabel(context, importState),
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ),
      ],
    );
  }

  String _statusLabel(BuildContext context, OpmlImportState s) {
    final l10n = AppLocalizations.of(context);
    switch (s.status) {
      case OpmlImportStatus.picking:
        return l10n.sidebarImportPicking;
      case OpmlImportStatus.importing:
        return l10n.sidebarImportParsing;
      case OpmlImportStatus.refreshing:
        return l10n.sidebarImportFetching(s.refreshDone, s.refreshTotal);
      default:
        return '';
    }
  }
}

class _SidebarFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.add, size: 18),
            tooltip: AppLocalizations.of(context).sidebarAddFeedTooltip,
            onPressed: () => showDialog(
              context: context,
              builder: (_) => const AddFeedDialog(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.create_new_folder_outlined, size: 18),
            tooltip: AppLocalizations.of(context).sidebarManageFoldersTooltip,
            onPressed: () => showDialog(
              context: context,
              builder: (_) => const FolderManagerDialog(),
            ),
          ),
        ],
      ),
    );
  }
}

// ── ドラッグ並び替え可能なフォルダ+フィードリスト ────────────────────────────

class _SidebarItemList extends ConsumerWidget {
  final List<Folder> folders;
  final List<Feed> feeds;
  final Selection selection;
  final Space? activeSpace;

  const _SidebarItemList({
    required this.folders,
    required this.feeds,
    required this.selection,
    required this.activeSpace,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topLevelFolders = folders.where((f) => f.parent == null).toList();

    // スペースがアクティブな場合、未分類フィードはスペースIDで絞り込む
    final feedsWithoutFolder = activeSpace != null
        ? feeds
            .where(
                (f) => f.folderId == null && f.spaceId == activeSpace!.id)
            .toList()
        : feeds.where((f) => f.folderId == null).toList();

    if (topLevelFolders.isEmpty && feedsWithoutFolder.isEmpty) {
      return const SizedBox.shrink();
    }

    final expandedMap = ref.watch(folderExpandedProvider).when(
      data: (data) => data,
      loading: () => const <String, bool>{},
      error: (_, _) => const <String, bool>{},
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (topLevelFolders.isNotEmpty)
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            itemCount: topLevelFolders.length,
            itemBuilder: (context, i) {
              final folder = topLevelFolders[i];
              return ReorderableDragStartListener(
                key: ValueKey('folder_${folder.id}'),
                index: i,
                child: FolderTile(
                  folder: folder,
                  allFolders: folders,
                  feeds: feeds,
                  expandedMap: expandedMap,
                  selection: selection,
                ),
              );
            },
            onReorderItem: (oldIndex, newIndex) =>
                _onReorderFolders(ref, topLevelFolders, oldIndex, newIndex),
          ),
        // 未分類フィードエリア（DragTarget で「未分類に戻す」を受け付ける）
        DragTarget<Feed>(
          onWillAcceptWithDetails: (details) =>
              details.data.folderId != null,
          onAcceptWithDetails: (details) async {
            await ref
                .read(databaseProvider)
                .feedsDao
                .moveFeed(details.data.id, null);
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
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    )
                  : null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (isHovered)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      child: Text(
                        AppLocalizations.of(context).sidebarMoveToUncategorized,
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ),
                  ...feedsWithoutFolder.map((feed) => FeedTile(
                        feed: feed,
                        isSelected: selection is SelectionFeed &&
                            (selection as SelectionFeed).feedId == feed.id,
                      )),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Future<void> _onReorderFolders(
    WidgetRef ref,
    List<Folder> topFolders,
    int oldIndex,
    int newIndex,
  ) async {
    final db = ref.read(databaseProvider);
    final list = [...topFolders];
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    for (int i = 0; i < list.length; i++) {
      await db.foldersDao.reorderFolder(list[i].id, i);
    }
  }
}

// ── ゴミ箱タイル (展開可能) ──────────────────────────────────────────────────

class _TrashTile extends ConsumerStatefulWidget {
  const _TrashTile();

  @override
  ConsumerState<_TrashTile> createState() => _TrashTileState();
}

class _TrashTileState extends ConsumerState<_TrashTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final selection = ref.watch(selectionProvider);
    final isSelected = selection is SelectionTrash;
    final feedsAsync = ref.watch(trashedFeedsStreamProvider);
    final feeds = feedsAsync.when(
      data: (data) => data,
      loading: () => [],
      error: (_, _) => [],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          dense: true,
          leading: Icon(
            _expanded ? Icons.delete : Icons.delete_outline,
            size: 16,
          ),
          title: Text(AppLocalizations.of(context).navTrash,
              style: const TextStyle(fontSize: 13)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (feeds.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${feeds.length}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              const SizedBox(width: 2),
              Icon(
                _expanded ? Icons.expand_less : Icons.expand_more,
                size: 14,
              ),
            ],
          ),
          selected: isSelected,
          selectedTileColor: Theme.of(context).colorScheme.primaryContainer,
          onTap: () {
            setState(() => _expanded = !_expanded);
            ref.read(selectionProvider.notifier).state =
                const SelectionTrash();
          },
        ),
        if (_expanded)
          ...feeds.map((feed) => Padding(
                padding: const EdgeInsets.only(left: 16),
                child: _TrashFeedSidebarTile(feed: feed),
              )),
      ],
    );
  }
}

class _TrashFeedSidebarTile extends ConsumerWidget {
  final Feed feed;
  const _TrashFeedSidebarTile({required this.feed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onSecondaryTapDown: (details) =>
          _showContextMenu(context, ref, details.globalPosition),
      child: ListTile(
        dense: true,
        leading: const Icon(Icons.rss_feed, size: 14, color: Colors.grey),
        title: Text(
          feed.title ?? feed.url,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  void _showContextMenu(
      BuildContext context, WidgetRef ref, Offset position) {
    final l10n = AppLocalizations.of(context);
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
          position.dx, position.dy, position.dx + 1, position.dy + 1),
      items: [
        PopupMenuItem(
          child: ListTile(
            dense: true,
            leading: const Icon(Icons.restore, size: 16),
            title: Text(l10n.trashContextRestore),
            contentPadding: EdgeInsets.zero,
          ),
          onTap: () async {
            final db = ref.read(databaseProvider);
            await db.feedsDao.restoreFeed(feed.id);
            if (feed.folderId != null) {
              final folder =
                  await db.foldersDao.getFolderById(feed.folderId!);
              if (folder == null) {
                await db.feedsDao.moveFeed(feed.id, null);
              }
            }
          },
        ),
        PopupMenuItem(
          child: ListTile(
            dense: true,
            leading:
                const Icon(Icons.delete_forever, size: 16, color: Colors.red),
            title: Text(l10n.trashContextDeletePermanently,
                style: const TextStyle(color: Colors.red)),
            contentPadding: EdgeInsets.zero,
          ),
          onTap: () => Future.microtask(() {
            if (context.mounted) _confirmDelete(context, ref);
          }),
        ),
      ],
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.trashDeleteDialogTitle(feed.title ?? feed.url)),
        content: Text(l10n.trashDeleteDialogBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.dialogCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.trashContextDeletePermanently),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final db = ref.read(databaseProvider);
    await db.entriesDao.deleteEntriesForFeed(feed.id);
    await db.feedsDao.deleteFeedPermanently(feed.id);
  }
}

// ── ナビゲーションアイテム ────────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final int? unreadCount;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.unreadCount,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: Icon(icon, size: 16),
      title: Text(label, style: const TextStyle(fontSize: 13)),
      trailing: (unreadCount != null && unreadCount! > 0)
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$unreadCount',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 10,
                ),
              ),
            )
          : null,
      selected: selected,
      selectedTileColor: Theme.of(context).colorScheme.primaryContainer,
      onTap: onTap,
    );
  }
}
