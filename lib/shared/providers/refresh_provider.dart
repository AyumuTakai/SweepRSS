import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import 'database_provider.dart';

final feedsStreamProvider = StreamProvider<List<Feed>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.feedsDao.watchAllActiveFeeds();
});

final trashedFeedsStreamProvider = StreamProvider<List<Feed>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.feedsDao.watchTrashedFeeds();
});

final foldersStreamProvider = StreamProvider<List<Folder>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.foldersDao.watchAllFolders();
});

// 自動更新 (60秒ごと)
final autoRefreshProvider = Provider<void>((ref) {
  final timer = Timer.periodic(const Duration(seconds: 60), (_) async {
    final db = ref.read(databaseProvider);
    final rss = ref.read(rsServiceProvider);
    final feeds = await db.feedsDao.getAllActiveFeeds();
    await rss.refreshAllFeeds(feeds);
  });
  ref.onDispose(timer.cancel);
});

class RefreshState {
  final bool isRefreshing;
  final int done;
  final int total;

  const RefreshState({
    this.isRefreshing = false,
    this.done = 0,
    this.total = 0,
  });
}

class RefreshNotifier extends Notifier<RefreshState> {
  @override
  RefreshState build() => const RefreshState();

  Future<void> refreshAll() async {
    final db = ref.read(databaseProvider);
    final rss = ref.read(rsServiceProvider);
    final feeds = await db.feedsDao.getAllActiveFeeds();

    state = RefreshState(isRefreshing: true, done: 0, total: feeds.length);

    await rss.refreshAllFeeds(feeds, onProgress: (done, total) {
      state = RefreshState(isRefreshing: true, done: done, total: total);
    });

    state = const RefreshState();
  }
}

final refreshProvider = NotifierProvider<RefreshNotifier, RefreshState>(RefreshNotifier.new);
