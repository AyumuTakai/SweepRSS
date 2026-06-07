import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:webfeed_plus/webfeed_plus.dart';

import '../database/app_database.dart';
import 'url_validator.dart';

class RssService {
  final AppDatabase _db;
  final Dio _dio;
  static const _uuid = Uuid();

  RssService(this._db)
      : _dio = Dio(
          BaseOptions(
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
            headers: {
              'User-Agent':
                  'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36',
            },
          ),
        );

  Future<FeedValidationResult> validateAndFetchFeed(String url) async {
    final error = UrlValidator.validate(url);
    if (error != null) throw RssException(error);

    final response = await _dio.get<String>(
      url,
      options: Options(responseType: ResponseType.plain),
    );

    final body = response.data ?? '';
    final feed = _parseFeed(body);
    return FeedValidationResult(
      title: feed.title ?? Uri.parse(url).host,
      feedType: feed is RssFeed ? 'RSS' : 'Atom',
    );
  }

  Future<void> addFeed(String url, {String? title, String? folderId}) async {
    final error = UrlValidator.validate(url);
    if (error != null) throw RssException(error);

    final response = await _dio.get<String>(
      url,
      options: Options(responseType: ResponseType.plain),
    );
    final body = response.data ?? '';
    final feed = _parseFeed(body);

    final feedId = _uuid.v4();
    final feedTitle = title ?? feed.title ?? Uri.parse(url).host;
    final feedType = feed is RssFeed ? 'RSS' : 'Atom';

    await _db.feedsDao.insertFeed(FeedsCompanion.insert(
      id: feedId,
      url: url,
      title: Value(feedTitle),
      feedType: Value(feedType),
      folderId: Value(folderId),
      description: Value(feed is RssFeed ? feed.description : null),
      link: Value(feed is RssFeed ? feed.link : (feed as AtomFeed).links?.firstOrNull?.href),
    ));

    await _saveEntries(feedId, feed);
  }

  Future<({int newCount, String? error})> refreshFeed(Feed feed) async {
    try {
      final error = UrlValidator.validate(feed.url);
      if (error != null) return (newCount: 0, error: error);

      final response = await _dio.get<String>(
        feed.url,
        options: Options(responseType: ResponseType.plain),
      );
      final body = response.data ?? '';
      final parsed = _parseFeed(body);
      final newCount = await _saveEntries(feed.id, parsed);
      return (newCount: newCount, error: null);
    } on DioException catch (e) {
      return (newCount: 0, error: _formatDioError(e));
    } catch (e) {
      return (newCount: 0, error: e.toString());
    }
  }

  Future<void> refreshAllFeeds(
    List<Feed> feeds, {
    void Function(int done, int total)? onProgress,
  }) async {
    for (var i = 0; i < feeds.length; i++) {
      await refreshFeed(feeds[i]);
      onProgress?.call(i + 1, feeds.length);
    }
  }

  dynamic _parseFeed(String body) {
    try {
      return RssFeed.parse(body);
    } catch (_) {
      try {
        return AtomFeed.parse(body);
      } catch (_) {
        throw RssException('フィードの形式を認識できません (RSS/Atom)');
      }
    }
  }

  Future<int> _saveEntries(String feedId, dynamic feed) async {
    final List<EntriesCompanion> items = [];
    final existingEntries = await _db.entriesDao.getEntriesForFeed(feedId);
    final existingIds = existingEntries.map((e) => e.id).toSet();

    if (feed is RssFeed) {
      for (final item in feed.items ?? <RssItem>[]) {
        final id = _entryId(feedId, item.guid ?? item.link ?? item.title ?? _uuid.v4());
        if (!existingIds.contains(id)) {
          items.add(EntriesCompanion.insert(
            id: id,
            feedId: feedId,
            title: Value(item.title),
            link: Value(item.link),
            summary: Value(item.description),
            published: Value(item.pubDate),
          ));
        }
      }
    } else if (feed is AtomFeed) {
      for (final entry in feed.items ?? <AtomItem>[]) {
        final id = _entryId(feedId, entry.id ?? entry.links?.firstOrNull?.href ?? entry.title ?? _uuid.v4());
        if (!existingIds.contains(id)) {
          items.add(EntriesCompanion.insert(
            id: id,
            feedId: feedId,
            title: Value(entry.title),
            link: Value(entry.links?.firstOrNull?.href),
            summary: Value(entry.summary),
            published: Value(entry.updated),
          ));
        }
      }
    }

    if (items.isNotEmpty) {
      await _db.entriesDao.insertEntries(items);
    }
    return items.length;
  }

  String _entryId(String feedId, String rawId) {
    return '$feedId:$rawId';
  }

  String _formatDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return '接続がタイムアウトしました';
      case DioExceptionType.connectionError:
        return 'ネットワークエラー: ${e.message}';
      case DioExceptionType.badResponse:
        return 'HTTP ${e.response?.statusCode}: ${e.response?.statusMessage}';
      default:
        return e.message ?? '不明なエラー';
    }
  }
}

class RssException implements Exception {
  final String message;
  RssException(this.message);
  @override
  String toString() => message;
}

class FeedValidationResult {
  final String title;
  final String feedType;
  FeedValidationResult({required this.title, required this.feedType});
}
