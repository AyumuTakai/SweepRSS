import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rssreader/core/database/app_database.dart';
import 'package:rssreader/core/services/opml_service.dart';

/// テスト用インメモリ DB を生成する
AppDatabase _makeTestDb() => AppDatabase(NativeDatabase.memory());

void main() {
  late AppDatabase db;
  late OpmlService service;

  setUp(() {
    db = _makeTestDb();
    service = OpmlService(db);
  });

  tearDown(() async {
    await db.close();
  });

  // ── importFromString ───────────────────────────────────────────────────────
  group('OpmlService.importFromString', () {
    test('フラットな OPML をインポートできる', () async {
      const opml = '''<?xml version="1.0"?>
<opml version="2.0">
  <head><title>Test</title></head>
  <body>
    <outline type="rss" text="Feed A" xmlUrl="https://example.com/rss"/>
    <outline type="rss" text="Feed B" xmlUrl="https://feeds.example.org/atom"/>
  </body>
</opml>''';

      final result = await service.importFromString(opml);
      expect(result.feeds, 2);
      expect(result.folders, 0);
    });

    test('フォルダ付き OPML をインポートできる', () async {
      const opml = '''<?xml version="1.0"?>
<opml version="2.0">
  <head><title>Test</title></head>
  <body>
    <outline text="Tech">
      <outline type="rss" text="Feed A" xmlUrl="https://example.com/rss"/>
    </outline>
    <outline text="News">
      <outline type="rss" text="Feed B" xmlUrl="https://news.example.com/feed"/>
    </outline>
  </body>
</opml>''';

      final result = await service.importFromString(opml);
      expect(result.feeds, 2);
      expect(result.folders, 2);
    });

    test('プライベート IP の xmlUrl をスキップする', () async {
      const opml = '''<?xml version="1.0"?>
<opml version="2.0">
  <head><title>Test</title></head>
  <body>
    <outline type="rss" text="Safe"     xmlUrl="https://example.com/rss"/>
    <outline type="rss" text="Local"    xmlUrl="http://192.168.1.1/feed"/>
    <outline type="rss" text="Loopback" xmlUrl="http://127.0.0.1/rss"/>
  </body>
</opml>''';

      final result = await service.importFromString(opml);
      expect(result.feeds, 1, reason: 'プライベート IP のフィードはスキップされる');
    });

    test('file:// スキームをスキップする', () async {
      const opml = '''<?xml version="1.0"?>
<opml version="2.0">
  <head><title>Test</title></head>
  <body>
    <outline type="rss" text="File" xmlUrl="file:///etc/passwd"/>
    <outline type="rss" text="Safe" xmlUrl="https://example.com/rss"/>
  </body>
</opml>''';

      final result = await service.importFromString(opml);
      expect(result.feeds, 1);
    });

    test('マルチスペース OPML をインポートしてスペースを作成する', () async {
      const opml = '''<?xml version="1.0"?>
<opml version="2.0">
  <head><title>SweepRSS Export</title></head>
  <body>
    <outline text="仕事" sweepType="space">
      <outline type="rss" text="Work Feed" xmlUrl="https://work.example.com/rss"/>
    </outline>
    <outline text="趣味" sweepType="space">
      <outline type="rss" text="Hobby Feed" xmlUrl="https://hobby.example.com/rss"/>
    </outline>
  </body>
</opml>''';

      final result = await service.importFromString(opml);
      expect(result.feeds, 2);

      final spaces = await db.spacesDao.getAllSpaces();
      expect(spaces.length, 2);
      expect(spaces.map((s) => s.name), containsAll(['仕事', '趣味']));
    });

    test('body が存在しない場合は例外をスローする', () async {
      const opml = '<?xml version="1.0"?><opml version="2.0"><head/></opml>';
      expect(
        () => service.importFromString(opml),
        throwsA(isA<OpmlException>()),
      );
    });

    test('フィードが 0 件でもクラッシュしない', () async {
      const opml = '''<?xml version="1.0"?>
<opml version="2.0">
  <head><title>Empty</title></head>
  <body></body>
</opml>''';
      final result = await service.importFromString(opml);
      expect(result.feeds, 0);
      expect(result.folders, 0);
    });

    test('重複 URL は 2 回目をスキップしてクラッシュしない', () async {
      const opml = '''<?xml version="1.0"?>
<opml version="2.0">
  <head><title>Dup</title></head>
  <body>
    <outline type="rss" text="Feed A"     xmlUrl="https://example.com/rss"/>
    <outline type="rss" text="Feed A dup" xmlUrl="https://example.com/rss"/>
  </body>
</opml>''';

      // 例外なく完了すること
      await expectLater(service.importFromString(opml), completes);

      final feeds = await db.feedsDao.getAllActiveFeeds();
      final urls = feeds.map((f) => f.url).toList();
      expect(urls.where((u) => u == 'https://example.com/rss').length, 1);
    });
  });

  // ── exportAllSpacesToString ───────────────────────────────────────────────
  group('OpmlService.exportAllSpacesToString', () {
    test('空の DB でも valid な OPML を出力する', () async {
      final xml = await service.exportAllSpacesToString();
      expect(xml, contains('<opml'));
      expect(xml, contains('<body'));
    });

    test('エクスポートした OPML を再インポートできる（ラウンドトリップ）', () async {
      final spaceId = await db.spacesDao.insertSpace('テスト');
      await db.feedsDao.insertFeed(
        FeedsCompanion.insert(
          id: 'feed-1',
          url: 'https://example.com/rss',
          spaceId: drift.Value(spaceId),
        ),
      );

      final exported = await service.exportAllSpacesToString();
      expect(exported, contains('https://example.com/rss'));
      expect(exported, contains('sweepType="space"'));

      // 別の DB に再インポート
      final db2 = _makeTestDb();
      final service2 = OpmlService(db2);
      final result = await service2.importFromString(exported);
      expect(result.feeds, 1);
      await db2.close();
    });

    test('フィード title に XML 特殊文字が含まれていてもクラッシュしない', () async {
      final spaceId = await db.spacesDao.insertSpace('S');
      await db.feedsDao.insertFeed(
        FeedsCompanion.insert(
          id: 'feed-x',
          url: 'https://example.com/rss',
          title: const drift.Value('<B&W> "Feed"'),
          spaceId: drift.Value(spaceId),
        ),
      );

      // XmlBuilder が自動エスケープするため例外なく完了する
      await expectLater(service.exportAllSpacesToString(), completes);
    });
  });

  // ── _toSafeFilename（exportCurrentSpaceToString 経由で検証） ──────────────
  group('OpmlService.exportCurrentSpaceToString', () {
    test('スペース名に / が含まれていても exportCurrentSpaceToString が完了する', () async {
      final spaceId = await db.spacesDao.insertSpace('仕事/副業');
      await db.feedsDao.insertFeed(
        FeedsCompanion.insert(
          id: 'feed-2',
          url: 'https://example.com/feed2',
          spaceId: drift.Value(spaceId),
        ),
      );

      await expectLater(service.exportCurrentSpaceToString(spaceId), completes);
    });
  });
}
