import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../core/models/selection.dart';
import 'active_space_provider.dart';
import 'database_provider.dart';
import 'refresh_provider.dart';
import 'selection_provider.dart';

/// 未読ビューを開いた瞬間の未読記事 ID セット（スナップショット）。
///
/// - 未読ビューを開く → [initialize] で現時点の未読 ID を記録
/// - 記事を既読にしても ID はセットから消えない → リストに残る
/// - フィード更新完了後 → 新たな未読 ID をセットに追加
/// - 未読ビューから離れる → null にリセット
final unreadSnapshotProvider =
    NotifierProvider<UnreadSnapshotNotifier, Set<String>?>(
  UnreadSnapshotNotifier.new,
);

class UnreadSnapshotNotifier extends Notifier<Set<String>?> {
  @override
  Set<String>? build() {
    // 未読ビュー以外に移動したらスナップショットをクリア
    ref.listen<Selection>(selectionProvider, (_, next) {
      if (next is! SelectionUnread) state = null;
    });

    // フィード更新が完了したら新しい未読記事をスナップショットに追加
    ref.listen<RefreshState>(refreshProvider, (prev, next) {
      if (prev != null && prev.isRefreshing && !next.isRefreshing) {
        _mergeNewUnread();
      }
    });

    return null;
  }

  /// 未読ビューを開いたときに呼び出す。すでに初期化済みなら何もしない。
  Future<void> initialize() async {
    if (state != null) return;
    final db = ref.read(databaseProvider);
    final activeSpace = ref.read(resolvedActiveSpaceProvider);
    final ids = await _fetchUnreadIds(db, activeSpace?.id);
    state = ids.toSet();
  }

  /// フィード更新完了後に新規未読記事をスナップショットへ追加する。
  /// 未読ビューを開いていない場合（state == null）は何もしない。
  Future<void> _mergeNewUnread() async {
    if (state == null) return;
    final db = ref.read(databaseProvider);
    final activeSpace = ref.read(resolvedActiveSpaceProvider);
    final latestIds = await _fetchUnreadIds(db, activeSpace?.id);
    final newIds = latestIds.toSet().difference(state!);
    if (newIds.isNotEmpty) {
      state = {...state!, ...newIds};
    }
  }

  /// 現在のスペースに属する未読記事の ID 一覧を取得する。
  Future<List<String>> _fetchUnreadIds(
      AppDatabase db, String? spaceId) async {
    if (spaceId == null) {
      return db.entriesDao.getAllUnreadIds();
    }
    final spaceFolders = await db.foldersDao.getFoldersInSpace(spaceId);
    final spaceFolderIds = spaceFolders.map((f) => f.id).toSet();
    final allFeeds = await db.feedsDao.getAllActiveFeeds();
    final feedIds = allFeeds
        .where((f) =>
            (f.folderId != null && spaceFolderIds.contains(f.folderId)) ||
            (f.folderId == null && f.spaceId == spaceId))
        .map((f) => f.id)
        .toList();
    return db.entriesDao.getUnreadIdsForFeeds(feedIds);
  }
}
