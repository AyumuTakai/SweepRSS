import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../core/services/opml_service.dart';
import '../../shared/providers/active_space_provider.dart';
import '../../shared/providers/database_provider.dart';

enum OpmlImportStatus { idle, picking, importing, refreshing, done, error }

class OpmlImportState {
  final OpmlImportStatus status;
  final int refreshDone;
  final int refreshTotal;
  final String? rawError;
  final int importedFeeds;
  final int importedFolders;

  const OpmlImportState({
    this.status = OpmlImportStatus.idle,
    this.refreshDone = 0,
    this.refreshTotal = 0,
    this.rawError,
    this.importedFeeds = 0,
    this.importedFolders = 0,
  });

  bool get isRunning =>
      status == OpmlImportStatus.picking ||
      status == OpmlImportStatus.importing ||
      status == OpmlImportStatus.refreshing;

  double? get progress => refreshTotal > 0 ? refreshDone / refreshTotal : null;
}

class OpmlImportNotifier extends Notifier<OpmlImportState> {
  @override
  OpmlImportState build() => const OpmlImportState();

  Future<void> startImport() async {
    if (state.isRunning) return;

    // 現在アクティブなスペースへインポート
    final activeSpace = ref.read(resolvedActiveSpaceProvider);

    // 1. ファイルを選択
    state = const OpmlImportState(status: OpmlImportStatus.picking);
    final opml = ref.read(opmlServiceProvider);
    final path = await opml.pickOpmlFile();
    if (path == null) {
      state = const OpmlImportState();
      return;
    }

    // 2. OPML をパースして DB に挿入
    state = const OpmlImportState(status: OpmlImportStatus.importing);
    late final OpmlImportResult result;
    try {
      result = await opml.importFromFile(path, spaceId: activeSpace?.id);
    } catch (e) {
      state = OpmlImportState(
        status: OpmlImportStatus.error,
        rawError: e.toString(),
      );
      return;
    }

    if (result.newFeedIds.isEmpty) {
      state = OpmlImportState(
        status: OpmlImportStatus.done,
        importedFeeds: 0,
        importedFolders: result.folders,
      );
      return;
    }

    // 3. 新しいフィードの記事を取得
    state = OpmlImportState(
      status: OpmlImportStatus.refreshing,
      refreshTotal: result.newFeedIds.length,
      importedFeeds: result.feeds,
      importedFolders: result.folders,
    );

    final db = ref.read(databaseProvider);
    final rss = ref.read(rsServiceProvider);
    var done = 0;

    for (final feedId in result.newFeedIds) {
      final feed = await db.feedsDao.getFeedById(feedId);
      if (feed != null) {
        await rss.refreshFeed(feed);
      }
      done++;
      state = OpmlImportState(
        status: OpmlImportStatus.refreshing,
        refreshDone: done,
        refreshTotal: result.newFeedIds.length,
        importedFeeds: result.feeds,
        importedFolders: result.folders,
      );
    }

    state = OpmlImportState(
      status: OpmlImportStatus.done,
      importedFeeds: result.feeds,
      importedFolders: result.folders,
    );
  }

  Future<void> exportAllSpaces({required String dialogTitle}) async {
    final opml = ref.read(opmlServiceProvider);
    try {
      await opml.exportAllSpacesToFile(dialogTitle: dialogTitle);
    } catch (e) {
      state = OpmlImportState(
        status: OpmlImportStatus.error,
        rawError: e.toString(),
      );
      Future.microtask(reset);
    }
  }

  Future<void> exportCurrentSpace(Space space,
      {required String dialogTitle}) async {
    final opml = ref.read(opmlServiceProvider);
    try {
      await opml.exportCurrentSpaceToFile(space, dialogTitle: dialogTitle);
    } catch (e) {
      state = OpmlImportState(
        status: OpmlImportStatus.error,
        rawError: e.toString(),
      );
      Future.microtask(reset);
    }
  }

  void reset() {
    state = const OpmlImportState();
  }
}

final opmlImportProvider =
    NotifierProvider<OpmlImportNotifier, OpmlImportState>(OpmlImportNotifier.new);
