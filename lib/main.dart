import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'app.dart';
import 'core/database/app_database.dart';
import 'shared/app_version.dart';
import 'shared/providers/database_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows) {
    final appDir = await getApplicationSupportDirectory();
    await WebViewEnvironment.create(
      settings: WebViewEnvironmentSettings(
        userDataFolder: p.join(appDir.path, 'WebView2'),
      ),
    );
  }

  await AppVersion.init();

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
