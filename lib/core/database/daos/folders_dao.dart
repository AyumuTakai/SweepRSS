import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/folders_table.dart';

part 'folders_dao.g.dart';

@DriftAccessor(tables: [Folders])
class FoldersDao extends DatabaseAccessor<AppDatabase> with _$FoldersDaoMixin {
  FoldersDao(super.db);

  Stream<List<Folder>> watchAllFolders() {
    return (select(folders)..orderBy([(f) => OrderingTerm.asc(f.order)]))
        .watch();
  }

  Future<List<Folder>> getAllFolders() {
    return (select(folders)..orderBy([(f) => OrderingTerm.asc(f.order)])).get();
  }

  Stream<List<Folder>> watchFoldersInSpace(String spaceId) {
    return (select(folders)
          ..where((f) => f.spaceId.equals(spaceId))
          ..orderBy([(f) => OrderingTerm.asc(f.order)]))
        .watch();
  }

  Future<List<Folder>> getFoldersInSpace(String spaceId) {
    return (select(folders)
          ..where((f) => f.spaceId.equals(spaceId))
          ..orderBy([(f) => OrderingTerm.asc(f.order)]))
        .get();
  }

  Future<Folder?> getFolderById(String id) {
    return (select(folders)..where((f) => f.id.equals(id))).getSingleOrNull();
  }

  Future<int> insertFolder(FoldersCompanion folder) =>
      into(folders).insert(folder);

  Future<bool> updateFolder(FoldersCompanion folder) =>
      update(folders).replace(folder);

  Future<void> renameFolder(String id, String newName) {
    return (update(folders)..where((f) => f.id.equals(id))).write(
      FoldersCompanion(name: Value(newName)),
    );
  }

  Future<void> reorderFolder(String id, int newOrder) {
    return (update(folders)..where((f) => f.id.equals(id))).write(
      FoldersCompanion(order: Value(newOrder)),
    );
  }

  /// フォルダ削除時: 直接の子フォルダの parent を null（未分類）へ
  Future<void> detachSubfolders(String parentId) {
    return (update(folders)..where((f) => f.parent.equals(parentId))).write(
      const FoldersCompanion(parent: Value(null)),
    );
  }

  Future<int> deleteFolder(String id) {
    return (delete(folders)..where((f) => f.id.equals(id))).go();
  }
}
