import 'package:drift/drift.dart';

class Feeds extends Table {
  TextColumn get id => text()();
  TextColumn get url => text()();
  TextColumn get feedType => text().nullable()();
  TextColumn get title => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get link => text().nullable()();
  DateTimeColumn get published => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get folderId => text().nullable()();
  BoolColumn get requiresExternalBrowser =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
