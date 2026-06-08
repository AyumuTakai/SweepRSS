import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/database/app_database.dart';
import '../../../core/models/selection.dart';
import '../../../shared/providers/database_provider.dart';
import '../../../shared/providers/reader_controller_provider.dart';
import '../../../shared/providers/selection_provider.dart';
import '../providers/articles_provider.dart';

// currentArticleIdProvider は ArticlesPanel でまとめて watch し _ArticlesList へ渡す

final _dateFormat = DateFormat('MM/dd HH:mm');

class ArticlesPanel extends ConsumerWidget {
  const ArticlesPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selection = ref.watch(selectionProvider);

    // ゴミ箱選択時はガイドを表示
    if (selection is SelectionTrash) {
      return const Center(
        child: Text(
          'ゴミ箱のフィードはサイドバーで\n右クリックして操作できます',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    final articlesAsync = ref.watch(articlesProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final currentArticleId = ref.watch(currentArticleIdProvider);

    return Column(
      children: [
        _ArticlesToolbar(query: searchQuery),
        Expanded(
          child: articlesAsync.when(
            data: (articles) => articles.isEmpty
                ? const Center(child: Text('記事がありません'))
                : _ArticlesList(
                    articles: articles,
                    currentArticleId: currentArticleId,
                  ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('エラー: $e')),
          ),
        ),
      ],
    );
  }
}

// ── 記事ツールバー ─────────────────────────────────────────────────────────────

class _ArticlesToolbar extends ConsumerStatefulWidget {
  final String query;
  const _ArticlesToolbar({required this.query});

  @override
  ConsumerState<_ArticlesToolbar> createState() => _ArticlesToolbarState();
}

class _ArticlesToolbarState extends ConsumerState<_ArticlesToolbar> {
  late final FocusNode _focusNode = FocusNode(skipTraversal: true);

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              focusNode: _focusNode,
              autofocus: false,
              decoration: const InputDecoration(
                hintText: '記事を検索...',
                prefixIcon: Icon(Icons.search, size: 16),
                border: InputBorder.none,
                isDense: true,
              ),
              style: const TextStyle(fontSize: 13),
              onChanged: (v) =>
                  ref.read(searchQueryProvider.notifier).state = v,
              onTapOutside: (_) => _focusNode.unfocus(),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 記事リスト ─────────────────────────────────────────────────────────────────

class _ArticlesList extends ConsumerWidget {
  final List<Entry> articles;
  /// 親 (ArticlesPanel) から宣言的に渡される選択中の記事 ID。
  /// このコンポーネント自身は currentArticleIdProvider を watch しない。
  final String? currentArticleId;

  const _ArticlesList({
    required this.articles,
    required this.currentArticleId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scrollController = ref.watch(articlesScrollControllerProvider);
    return ListView.builder(
      controller: scrollController,
      itemCount: articles.length,
      itemBuilder: (context, i) {
        final entry = articles[i];
        final isSelected = currentArticleId == entry.id;

        return _ArticleTile(
          entry: entry,
          isSelected: isSelected,
          onTap: () async {
            ref.read(currentArticleIdProvider.notifier).state = entry.id;
            if (entry.unread) {
              await ref.read(databaseProvider).entriesDao.markRead(entry.id);
              ref.invalidate(articlesProvider);
            }
          },
        );
      },
    );
  }
}

// ── 記事タイル ─────────────────────────────────────────────────────────────────

class _ArticleTile extends StatelessWidget {
  final Entry entry;
  final bool isSelected;
  final VoidCallback onTap;

  const _ArticleTile({
    required this.entry,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        color: isSelected
            ? theme.colorScheme.primaryContainer
            : entry.unread
                ? null
                : theme.colorScheme.surfaceContainerLow.withValues(alpha: 0.5),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            if (entry.unread)
              Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primary,
                ),
              )
            else
              const SizedBox(width: 12),
            if (entry.flagged)
              const Padding(
                padding: EdgeInsets.only(right: 4),
                child: Icon(Icons.bookmark, size: 12, color: Colors.orange),
              ),
            Expanded(
              child: Text(
                (entry.title ?? '(タイトルなし)').replaceAll(RegExp(r'[\r\n]+'), ' '),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight:
                      entry.unread ? FontWeight.bold : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              entry.published != null
                  ? _dateFormat.format(entry.published!)
                  : '',
              style: TextStyle(
                  fontSize: 11,
                  color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
