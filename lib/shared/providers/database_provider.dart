import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/app_database.dart';
import '../../core/services/rss_service.dart';
import '../../core/services/opml_service.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError('databaseProvider must be overridden in ProviderScope');
});

final rsServiceProvider = Provider<RssService>((ref) {
  return RssService(ref.watch(databaseProvider));
});

final opmlServiceProvider = Provider<OpmlService>((ref) {
  return OpmlService(ref.watch(databaseProvider));
});
