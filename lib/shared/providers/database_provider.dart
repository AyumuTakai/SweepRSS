import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/app_database.dart';
import '../../core/services/rss_service.dart';
import '../../core/services/opml_service.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError('databaseProvider must be overridden in ProviderScope');
});

/// Windows で WebView2 のユーザーデータフォルダを書き込み可能な場所に固定するための環境。
/// 他プラットフォームでは null。
final webViewEnvironmentProvider = Provider<WebViewEnvironment?>((ref) => null);

final rsServiceProvider = Provider<RssService>((ref) {
  return RssService(ref.watch(databaseProvider));
});

final opmlServiceProvider = Provider<OpmlService>((ref) {
  return OpmlService(ref.watch(databaseProvider));
});
