import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../app_database.dart';
import '../tables/spaces_table.dart';

part 'spaces_dao.g.dart';

@DriftAccessor(tables: [Spaces])
class SpacesDao extends DatabaseAccessor<AppDatabase> with _$SpacesDaoMixin {
  SpacesDao(super.db);

  Stream<List<Space>> watchAllSpaces() {
    return (select(spaces)..orderBy([(s) => OrderingTerm.asc(s.order)])).watch();
  }

  Future<List<Space>> getAllSpaces() {
    return (select(spaces)..orderBy([(s) => OrderingTerm.asc(s.order)])).get();
  }

  Future<Space?> getSpaceById(String id) {
    return (select(spaces)..where((s) => s.id.equals(id))).getSingleOrNull();
  }

  Future<String> insertSpace(String name, {String? icon}) async {
    final id = const Uuid().v4();
    final count = (await getAllSpaces()).length;
    await into(spaces).insert(SpacesCompanion.insert(
      id: id,
      name: name,
      icon: Value(icon),
      order: Value(count),
    ));
    return id;
  }

  Future<void> renameSpace(String id, String newName) {
    return (update(spaces)..where((s) => s.id.equals(id))).write(
      SpacesCompanion(name: Value(newName)),
    );
  }

  Future<void> reorderSpace(String id, int newOrder) {
    return (update(spaces)..where((s) => s.id.equals(id))).write(
      SpacesCompanion(order: Value(newOrder)),
    );
  }

  /// スペース削除: フォルダ・フィードを fallbackSpaceId へ移動してからスペースを削除。
  /// customStatement を使いトランザクションで一括実行し、データ不整合を防ぐ。
  Future<void> deleteSpace(String id, String fallbackSpaceId) async {
    await transaction(() async {
      await customStatement(
        'UPDATE folders SET space_id = ? WHERE space_id = ?',
        [fallbackSpaceId, id],
      );
      await customStatement(
        'UPDATE feeds SET space_id = ? WHERE space_id = ?',
        [fallbackSpaceId, id],
      );
      await (delete(spaces)..where((s) => s.id.equals(id))).go();
    });
  }
}
