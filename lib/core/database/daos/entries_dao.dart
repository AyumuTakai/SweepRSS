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
}
