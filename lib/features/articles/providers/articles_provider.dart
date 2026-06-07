import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/models/selection.dart';
// Feed 型は app_database.dart 経由で利用可能
import '../../../shared/providers/database_provider.dart';
import '../../../shared/providers/selection_provider.dart';
import '../../../shared/providers/refresh_provider.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');

final articlesProvider = FutureProvider<List<Entry>>((ref) async {
  final selection = ref.watch(selectionProvider);
  final db = ref.watch(databaseProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase();

  List<Entry> entries;

  switch (selection) {
    case SelectionAll():
      entries = await db.entriesDao.getAllEntries();
    case SelectionUnread():
      final all = await db.entriesDao.getAllEntries();
      entries = all.where((e) => e.unread).toList();
    case SelectionFlagged():
      entries = await db.entriesDao.getFlaggedEntries();
    case SelectionTrash():
      final trashedFeeds = await db.feedsDao.watchTrashedFeeds().first;
      final feedIds = trashedFeeds.map((f) => f.id).toList();
      entries = feedIds.isEmpty ? [] : await db.entriesDao.getEntriesForFeeds(feedIds);
    case SelectionFolder(folderId: final folderId):
      final feeds = await db.feedsDao.getAllActiveFeeds();
      final feedIds = feeds.where((f) => f.folderId == folderId).map((f) => f.id).toList();
      entries = feedIds.isEmpty ? [] : await db.entriesDao.getEntriesForFeeds(feedIds);
    case SelectionFeed(feedId: final feedId):
      entries = await db.entriesDao.getEntriesForFeed(feedId);
  }

  if (query.isNotEmpty) {
    entries = entries.where((e) => (e.title ?? '').toLowerCase().contains(query)).toList();
  }

  return entries;
});

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

final unreadCountProvider = FutureProvider.family<int, String>((ref, feedId) async {
  ref.watch(feedsStreamProvider);
  final db = ref.watch(databaseProvider);
  return db.entriesDao.getUnreadCountForFeed(feedId);
});
