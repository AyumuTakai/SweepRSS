import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/feeds_table.dart';

part 'feeds_dao.g.dart';

@DriftAccessor(tables: [Feeds])
class FeedsDao extends DatabaseAccessor<AppDatabase> with _$FeedsDaoMixin {
  FeedsDao(super.db);

  Stream<List<Feed>> watchAllActiveFeeds() {
    return (select(feeds)..where((f) => f.deletedAt.isNull()))
        .watch();
  }

  Stream<List<Feed>> watchTrashedFeeds() {
    return (select(feeds)..where((f) => f.deletedAt.isNotNull()))
        .watch();
  }

  Future<List<Feed>> getAllActiveFeeds() {
    return (select(feeds)..where((f) => f.deletedAt.isNull())).get();
  }

  Future<Feed?> getFeedById(String id) {
    return (select(feeds)..where((f) => f.id.equals(id))).getSingleOrNull();
  }

  Future<int> insertFeed(FeedsCompanion feed) => into(feeds).insert(feed);

  Future<bool> updateFeed(FeedsCompanion feed) => update(feeds).replace(feed);

  Future<void> softDeleteFeed(String id) {
    return (update(feeds)..where((f) => f.id.equals(id))).write(
      FeedsCompanion(deletedAt: Value(DateTime.now())),
    );
  }

  Future<void> restoreFeed(String id) {
    return (update(feeds)..where((f) => f.id.equals(id))).write(
      const FeedsCompanion(deletedAt: Value(null)),
    );
  }

  Future<int> deleteFeedPermanently(String id) {
    return (delete(feeds)..where((f) => f.id.equals(id))).go();
  }

  /// フォルダ削除時: そのフォルダ内の全フィードを未分類へ移動
  Future<void> detachFromFolder(String folderId) {
    return (update(feeds)..where((f) => f.folderId.equals(folderId))).write(
      const FeedsCompanion(folderId: Value(null)),
    );
  }

  /// フォルダ削除時: そのフォルダ内の全フィードをゴミ箱へ移動
  Future<void> trashFeedsInFolder(String folderId) {
    return (update(feeds)
          ..where((f) => f.folderId.equals(folderId) & f.deletedAt.isNull()))
        .write(FeedsCompanion(deletedAt: Value(DateTime.now())));
  }

  Future<void> moveFeed(String feedId, String? folderId) {
    return (update(feeds)..where((f) => f.id.equals(feedId))).write(
      FeedsCompanion(folderId: Value(folderId)),
    );
  }

  Future<void> renameFeed(String id, String newTitle) {
    return (update(feeds)..where((f) => f.id.equals(id))).write(
      FeedsCompanion(title: Value(newTitle)),
    );
  }

  Future<void> setRequiresExternalBrowser(String id, bool value) {
    return (update(feeds)..where((f) => f.id.equals(id))).write(
      FeedsCompanion(requiresExternalBrowser: Value(value)),
    );
  }

  Future<void> setUseRssContent(String id, bool value) {
    return (update(feeds)..where((f) => f.id.equals(id))).write(
      FeedsCompanion(useRssContent: Value(value)),
    );
  }

  Future<void> updateFetchStatus(String id, {String? error}) {
    return (update(feeds)..where((f) => f.id.equals(id))).write(
      FeedsCompanion(
        lastFetchError: Value(error),
        lastFetchAt: Value(DateTime.now()),
      ),
    );
  }

  /// 起動時チェック: 参照先フォルダが存在しない幽霊フィードを未分類へ移動する
  Future<void> fixOrphanedFeeds() {
    return customUpdate(
      '''
      UPDATE feeds
      SET folder_id = NULL
      WHERE folder_id IS NOT NULL
        AND folder_id NOT IN (SELECT id FROM folders)
        AND deleted_at IS NULL
      ''',
      updates: {feeds},
    );
  }
}
