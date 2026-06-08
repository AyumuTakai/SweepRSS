import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/models/selection.dart';
import '../../../shared/providers/active_space_provider.dart';
import '../../../shared/providers/database_provider.dart';
import '../../../shared/providers/selection_provider.dart';
import '../../../shared/providers/refresh_provider.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');

final articlesProvider = FutureProvider<List<Entry>>((ref) async {
  final selection = ref.watch(selectionProvider);
  final db = ref.watch(databaseProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final activeSpace = ref.watch(resolvedActiveSpaceProvider);

  List<Entry> entries;

  switch (selection) {
    case SelectionAll():
      if (activeSpace != null) {
        final feedIds = await _feedIdsInSpace(db, activeSpace.id);
        entries = feedIds.isEmpty
            ? []
            : await db.entriesDao.getEntriesForFeeds(feedIds);
      } else {
        entries = await db.entriesDao.getAllEntries();
      }

    case SelectionUnread():
      if (activeSpace != null) {
        final feedIds = await _feedIdsInSpace(db, activeSpace.id);
        if (feedIds.isEmpty) {
          entries = [];
        } else {
          final all = await db.entriesDao.getEntriesForFeeds(feedIds);
          entries = all.where((e) => e.unread).toList();
        }
      } else {
        final all = await db.entriesDao.getAllEntries();
        entries = all.where((e) => e.unread).toList();
      }

    case SelectionFlagged():
      if (activeSpace != null) {
        final feedIds = await _feedIdsInSpace(db, activeSpace.id);
        entries = feedIds.isEmpty
            ? []
            : (await db.entriesDao.getEntriesForFeeds(feedIds))
                .where((e) => e.flagged)
                .toList();
      } else {
        entries = await db.entriesDao.getFlaggedEntries();
      }

    case SelectionTrash():
      final trashedFeeds = await db.feedsDao.watchTrashedFeeds().first;
      final feedIds = trashedFeeds.map((f) => f.id).toList();
      entries =
          feedIds.isEmpty ? [] : await db.entriesDao.getEntriesForFeeds(feedIds);

    case SelectionFolder(folderId: final folderId):
      final feeds = await db.feedsDao.getAllActiveFeeds();
      final feedIds =
          feeds.where((f) => f.folderId == folderId).map((f) => f.id).toList();
      entries =
          feedIds.isEmpty ? [] : await db.entriesDao.getEntriesForFeeds(feedIds);

    case SelectionFeed(feedId: final feedId):
      entries = await db.entriesDao.getEntriesForFeed(feedId);
  }

  if (query.isNotEmpty) {
    entries = entries
        .where((e) => (e.title ?? '').toLowerCase().contains(query))
        .toList();
  }

  return entries;
});

/// 指定スペースに属するアクティブフィードの ID 一覧を返す。
/// - フォルダに属するフィード: フォルダの spaceId が一致するもの
/// - 未分類フィード: feeds.spaceId が一致するもの
Future<List<String>> _feedIdsInSpace(AppDatabase db, String spaceId) async {
  final spaceFolders = await db.foldersDao.getFoldersInSpace(spaceId);
  final spaceFolderIds = spaceFolders.map((f) => f.id).toSet();
  final allFeeds = await db.feedsDao.getAllActiveFeeds();
  return allFeeds
      .where((f) =>
          (f.folderId != null && spaceFolderIds.contains(f.folderId)) ||
          (f.folderId == null && f.spaceId == spaceId))
      .map((f) => f.id)
      .toList();
}

// Stream で watchEntryById → DB 変更（既読・フラグ）が即反映される
final currentArticleProvider = StreamProvider<Entry?>((ref) {
  final id = ref.watch(currentArticleIdProvider);
  if (id == null) return Stream.value(null);
  return ref.watch(databaseProvider).entriesDao.watchEntryById(id);
});

// 選択中記事のフィード情報（requiresExternalBrowser 判定に使用）
final currentArticleFeedProvider = FutureProvider<Feed?>((ref) async {
  final article = ref.watch(currentArticleProvider).valueOrNull;
  if (article == null) return null;
  return ref.read(databaseProvider).feedsDao.getFeedById(article.feedId);
});

final unreadCountProvider =
    FutureProvider.family<int, String>((ref, feedId) async {
  ref.watch(feedsStreamProvider);
  final db = ref.watch(databaseProvider);
  return db.entriesDao.getUnreadCountForFeed(feedId);
});
