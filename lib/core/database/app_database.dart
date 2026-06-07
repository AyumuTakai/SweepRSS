import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables/feeds_table.dart';
import 'tables/entries_table.dart';
import 'tables/folders_table.dart';
import 'daos/feeds_dao.dart';
import 'daos/entries_dao.dart';
import 'daos/folders_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Feeds, Entries, Folders],
  daos: [FeedsDao, EntriesDao, FoldersDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          // 将来のスキーマアップグレード
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
      driftDatabase(name: 'rssreader', native: DriftNativeOptions(databasePath: () async => dbPath)),
    );
  }
}
