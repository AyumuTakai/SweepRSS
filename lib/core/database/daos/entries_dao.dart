import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/entries_table.dart';

part 'entries_dao.g.dart';

@DriftAccessor(tables: [Entries])
class EntriesDao extends DatabaseAccessor<AppDatabase> with _$EntriesDaoMixin {
  EntriesDao(super.db);

  Stream<List<Entry>> watchEntriesForFeed(String feedId) {
    return (select(entries)
          ..where((e) => e.feedId.equals(feedId))
          ..orderBy([(e) => OrderingTerm.desc(e.published)]))
        .watch();
  }

  Future<List<Entry>> getEntriesForFeed(String feedId) {
    return (select(entries)
          ..where((e) => e.feedId.equals(feedId))
          ..orderBy([(e) => OrderingTerm.desc(e.published)]))
        .get();
  }

  Stream<Entry?> watchEntryById(String id) {
    return (select(entries)..where((e) => e.id.equals(id)))
        .watchSingleOrNull();
  }

  Future<List<Entry>> getAllEntries() {
    return (select(entries)
          ..orderBy([(e) => OrderingTerm.desc(e.published)]))
        .get();
  }

  Future<List<Entry>> getEntriesForFeeds(List<String> feedIds) {
    return (select(entries)
          ..where((e) => e.feedId.isIn(feedIds))
          ..orderBy([(e) => OrderingTerm.desc(e.published)]))
        .get();
  }

  Future<void> insertEntries(List<EntriesCompanion> items) async {
    await batch((b) => b.insertAllOnConflictUpdate(entries, items));
  }

  Future<void> markRead(String id) {
    return (update(entries)..where((e) => e.id.equals(id))).write(
      const EntriesCompanion(unread: Value(false)),
    );
  }

  Future<void> markUnread(String id) {
    return (update(entries)..where((e) => e.id.equals(id))).write(
      const EntriesCompanion(unread: Value(true)),
    );
  }

  Future<void> bulkMarkRead(List<String> ids) {
    return (update(entries)..where((e) => e.id.isIn(ids))).write(
      const EntriesCompanion(unread: Value(false)),
    );
  }

  Future<void> markAllReadForFeed(String feedId) {
    return (update(entries)..where((e) => e.feedId.equals(feedId))).write(
      const EntriesCompanion(unread: Value(false)),
    );
  }

  Future<void> toggleFlag(String id, bool flagged) {
    return (update(entries)..where((e) => e.id.equals(id))).write(
      EntriesCompanion(flagged: Value(flagged)),
    );
  }

  Future<List<Entry>> getFlaggedEntries() {
    return (select(entries)
          ..where((e) => e.flagged.equals(true))
          ..orderBy([(e) => OrderingTerm.desc(e.published)]))
        .get();
  }

  Future<void> deleteEntriesForFeed(String feedId) {
    return (delete(entries)..where((e) => e.feedId.equals(feedId))).go();
  }

  Future<int> getUnreadCountForFeed(String feedId) async {
    final count = await customSelect(
      'SELECT COUNT(*) as cnt FROM entries WHERE feed_id = ? AND unread = 1',
      variables: [Variable.withString(feedId)],
    ).getSingle();
    return count.read<int>('cnt');
  }

  Stream<int> watchUnreadCountForFeed(String feedId) {
    return customSelect(
      'SELECT COUNT(*) as cnt FROM entries WHERE feed_id = ? AND unread = 1',
      variables: [Variable.withString(feedId)],
      readsFrom: {entries},
    ).watchSingle().map((row) => row.read<int>('cnt'));
  }

  /// 全未読記事の ID リストを返す（スナップショット初期化用）。
  Future<List<String>> getAllUnreadIds() async {
    final result = await (select(entries)
          ..where((e) => e.unread.equals(true)))
        .get();
    return result.map((e) => e.id).toList();
  }

  /// 指定フィードの未読記事 ID リストを返す（スペース付きスナップショット初期化用）。
  Future<List<String>> getUnreadIdsForFeeds(List<String> feedIds) async {
    if (feedIds.isEmpty) return [];
    final result = await (select(entries)
          ..where((e) => e.feedId.isIn(feedIds) & e.unread.equals(true)))
        .get();
    return result.map((e) => e.id).toList();
  }

  /// ID リストで記事を取得する（スナップショット表示用）。
  /// 既読・未読を問わず返すため、既読化した記事もリストに残る。
  Future<List<Entry>> getEntriesForIds(List<String> ids) {
    if (ids.isEmpty) return Future.value([]);
    return (select(entries)
          ..where((e) => e.id.isIn(ids))
          ..orderBy([
            (e) => OrderingTerm(
                expression: e.published, mode: OrderingMode.desc),
            (e) => OrderingTerm(expression: e.id, mode: OrderingMode.desc),
          ]))
        .get();
  }

  /// 指定フィード ID リストの未読件数合計をリアクティブに返す。
  /// feedIds が空の場合は 0 を即時返す。
  Stream<int> watchTotalUnreadCountForFeeds(List<String> feedIds) {
    if (feedIds.isEmpty) return Stream.value(0);
    final placeholders = List.filled(feedIds.length, '?').join(',');
    return customSelect(
      'SELECT COUNT(*) as cnt FROM entries WHERE unread = 1 AND feed_id IN ($placeholders)',
      variables: feedIds.map(Variable.withString).toList(),
      readsFrom: {entries},
    ).watchSingle().map((row) => row.read<int>('cnt'));
  }
}
