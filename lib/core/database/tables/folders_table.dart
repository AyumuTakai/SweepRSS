import 'package:drift/drift.dart';

class Folders extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get type => integer().withDefault(const Constant(1))();
  TextColumn get parent => text().nullable()();
  IntColumn get order => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}
