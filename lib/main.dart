import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/database/app_database.dart';
import 'shared/providers/database_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final db = await AppDatabase.create();

  // 参照先フォルダが存在しない幽霊フィードを未分類に修正
  await db.feedsDao.fixOrphanedFeeds();

  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
      ],
      child: const RssReaderApp(),
    ),
  );
}
