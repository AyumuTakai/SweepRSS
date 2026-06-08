import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import 'tables/feeds_table.dart';
import 'tables/entries_table.dart';
import 'tables/folders_table.dart';
import 'tables/spaces_table.dart';
import 'daos/feeds_dao.dart';
import 'daos/entries_dao.dart';
import 'daos/folders_dao.dart';
import 'daos/spaces_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Feeds, Entries, Folders, Spaces],
  daos: [FeedsDao, EntriesDao, FoldersDao, SpacesDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(spaces);
            await m.addColumn(folders, folders.spaceId);
            await m.addColumn(feeds, feeds.spaceId);

            // 既存データをデフォルトスペースへ移行
            final defaultId = const Uuid().v4();
            await customInsert(
              'INSERT INTO spaces (id, name, "order") VALUES (?, ?, 0)',
              variables: [
                Variable.withString(defaultId),
                Variable.withString('デフォルト'),
              ],
              updates: {spaces},
            );
            await customUpdate(
              'UPDATE folders SET space_id = ?',
              variables: [Variable.withString(defaultId)],
              updates: {folders},
            );
            await customUpdate(
              'UPDATE feeds SET space_id = ?',
              variables: [Variable.withString(defaultId)],
              updates: {feeds},
            );
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'rssreader');
  }

  static Future<AppDatabase> create() async {
    final dir = await getApplicationSupportDirectory();
    final dbPath = p.join(dir.path, 'rssreader.db');
    return AppDatabase(
      driftDatabase(
          name: 'rssreader',
          native: DriftNativeOptions(databasePath: () async => dbPath)),
    );
  }
}
