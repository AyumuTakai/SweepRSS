import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/models/selection.dart';
import '../../../shared/providers/selection_provider.dart';
import '../../../shared/providers/database_provider.dart';
import '../../../shared/widgets/toast_overlay.dart';
import '../../articles/providers/articles_provider.dart';
import '../../dialogs/edit_feed_dialog.dart';

class FeedTile extends ConsumerWidget {
  final Feed feed;
  /// 親から宣言的に渡される選択状態。
  /// このコンポーネント自身は selectionProvider を watch しない。
  final bool isSelected;

  const FeedTile({super.key, required this.feed, required this.isSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // unreadCount は feed ごとに独立して変化するため、ここで watch するのが適切
    final unreadAsync = ref.watch(unreadCountProvider(feed.id));

    final tile = GestureDetector(
      onSecondaryTapDown: (details) =>
          _showContextMenu(context, ref, details.globalPosition),
      child: ListTile(
        dense: true,
        leading: const Icon(Icons.rss_feed, size: 14),
        title: Text(
          feed.title ?? feed.url,
          style: const TextStyle(fontSize: 12),
          overflow: TextOverflow.ellipsis,
        ),
        trailing: unreadAsync.when(
          data: (count) => count > 0
              ? Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 10,
                    ),
                  ),
                )
              : null,
          loading: () => null,
          error: (e, st) => null,
        ),
        selected: isSelected,
        selectedTileColor: Theme.of(context).colorScheme.primaryContainer,
        onTap: () {
          ref.read(selectionProvider.notifier).state = SelectionFeed(feed.id);
          ref.read(currentArticleIdProvider.notifier).state = null;
        },
      ),
    );

    return Draggable<Feed>(
      data: feed,
      childWhenDragging: Opacity(opacity: 0.4, child: tile),
      feedback: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(context).colorScheme.surface,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          constraints: const BoxConstraints(maxWidth: 200),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.rss_feed,
                  size: 14,
                  color: Theme.of(context).colorScheme.onSurface),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  feed.title ?? feed.url,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
      child: tile,
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
          child: const Text('編集'),
          onTap: () => showDialog(
            context: context,
            builder: (_) => EditFeedDialog(feed: feed),
          ),
        ),
        PopupMenuItem(
          child: const Text('すべて既読'),
          onTap: () async {
            await ref
                .read(databaseProvider)
                .entriesDao
                .markAllReadForFeed(feed.id);
          },
        ),
        PopupMenuItem(
          child: const Text('フィードを削除',
              style: TextStyle(color: Colors.red)),
          onTap: () async {
            await ref.read(databaseProvider).feedsDao.softDeleteFeed(feed.id);
            ref.read(toastProvider.notifier).show('フィードをゴミ箱に移動しました');
          },
        ),
      ],
    );
  }
}
