import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/models/selection.dart';
import '../../../shared/providers/active_space_provider.dart';
import '../../../shared/providers/database_provider.dart';
import '../../../shared/providers/refresh_provider.dart';
import '../../../shared/providers/selection_provider.dart';
import '../../../shared/providers/unread_snapshot_provider.dart';

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
      // スナップショットが初期化されていればそのIDセットで取得。
      // 既読化された記事もIDがセットに残るためリストから消えない。
      // 初期化前（null）は空を返し、initialize() 完了後に自動再描画される。
      final snapshot = ref.watch(unreadSnapshotProvider);
      entries = snapshot == null || snapshot.isEmpty
          ? []
          : await db.entriesDao.getEntriesForIds(snapshot.toList());

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
    StreamProvider.family<int, String>((ref, feedId) {
  return ref.watch(databaseProvider).entriesDao.watchUnreadCountForFeed(feedId);
});

/// 現在のスペースにおける未読件数合計。
/// スペース切り替え・既読化・フィード追加削除に追従してリアクティブに更新される。
final totalUnreadCountProvider = StreamProvider<int>((ref) {
  final db = ref.watch(databaseProvider);
  final activeSpace = ref.watch(resolvedActiveSpaceProvider);
  final feeds = ref.watch(feedsStreamProvider).valueOrNull ?? [];
  final folders = (activeSpace != null
          ? ref.watch(spaceFoldersStreamProvider(activeSpace.id))
          : ref.watch(foldersStreamProvider))
      .valueOrNull ?? [];

  final List<String> feedIds;
  if (activeSpace != null) {
    final spaceFolderIds = folders.map((f) => f.id).toSet();
    feedIds = feeds
        .where((f) =>
            (f.folderId != null && spaceFolderIds.contains(f.folderId)) ||
            (f.folderId == null && f.spaceId == activeSpace.id))
        .map((f) => f.id)
        .toList();
  } else {
    feedIds = feeds.map((f) => f.id).toList();
  }

  return db.entriesDao.watchTotalUnreadCountForFeeds(feedIds);
});
