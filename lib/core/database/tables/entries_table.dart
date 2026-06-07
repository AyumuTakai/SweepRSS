import 'package:drift/drift.dart';

class Entries extends Table {
  TextColumn get id => text()();
  TextColumn get feedId => text()();
  TextColumn get title => text().nullable()();
  TextColumn get link => text().nullable()();
  TextColumn get summary => text().nullable()();
  DateTimeColumn get published => dateTime().nullable()();
  BoolColumn get unread => boolean().withDefault(const Constant(true))();
  BoolColumn get flagged => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
