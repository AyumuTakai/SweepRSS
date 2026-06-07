import 'dart:io';
import 'package:drift/drift.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:xml/xml.dart';

import '../database/app_database.dart';

class OpmlService {
  final AppDatabase _db;
  static const _uuid = Uuid();

  OpmlService(this._db);

  Future<String?> pickOpmlFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['opml', 'xml'],
    );
    return result?.files.single.path;
  }

  Future<OpmlImportResult> importFromFile(String path) async {
    final content = await File(path).readAsString();
    return importFromString(content);
  }

  /// OPML をパースして DB に挿入する。
  /// 戻り値の [newFeedIds] を使って呼び出し元が RSS 記事を取得できる。
  Future<OpmlImportResult> importFromString(String opmlContent) async {
    final doc = XmlDocument.parse(opmlContent);
    final body = doc.findAllElements('body').firstOrNull;
    if (body == null) throw const OpmlException('OPML body が見つかりません');

    var feedCount = 0;
    var folderCount = 0;
    final newFeedIds = <String>[];

    // フォルダ挿入時の order 計算用にキャッシュ
    var folderOrderBase = (await _db.foldersDao.getAllFolders()).length;

    Future<void> processOutlines(Iterable<XmlElement> outlines, String? parentFolderId) async {
      for (final outline in outlines) {
        final xmlUrl = outline.getAttribute('xmlUrl');
        final title = outline.getAttribute('title') ?? outline.getAttribute('text') ?? '';

        if (xmlUrl != null && xmlUrl.isNotEmpty) {
          try {
            final feedId = _uuid.v4();
            await _db.feedsDao.insertFeed(FeedsCompanion.insert(
              id: feedId,
              url: xmlUrl,
              title: Value(title.isNotEmpty ? title : null),
              folderId: Value(parentFolderId),
            ));
            newFeedIds.add(feedId);
            feedCount++;
          } catch (_) {
            // 重複 URL などはスキップ
          }
        } else {
          // フォルダ
          final folderId = _uuid.v4();
          await _db.foldersDao.insertFolder(FoldersCompanion.insert(
            id: folderId,
            name: title.isNotEmpty ? title : '無題フォルダ',
            parent: Value(parentFolderId),
            order: Value(folderOrderBase++),
          ));
          folderCount++;
          await processOutlines(outline.findElements('outline'), folderId);
        }
      }
    }

    await processOutlines(body.findElements('outline'), null);
    return OpmlImportResult(feeds: feedCount, folders: folderCount, newFeedIds: newFeedIds);
  }

  Future<String> exportToString() async {
    final allFolders = await _db.foldersDao.getAllFolders();
    final allFeeds = await _db.feedsDao.getAllActiveFeeds();

    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0" encoding="UTF-8"');
    builder.element('opml', attributes: {'version': '2.0'}, nest: () {
      builder.element('head', nest: () {
        builder.element('title', nest: 'SweepRSS Export');
      });
      builder.element('body', nest: () {
        // フォルダなしフィード
        final topLevelFeeds = allFeeds.where((f) => f.folderId == null);
        for (final feed in topLevelFeeds) {
          builder.element('outline', attributes: {
            'type': 'rss',
            'text': feed.title ?? feed.url,
            'title': feed.title ?? feed.url,
            'xmlUrl': feed.url,
          });
        }
        // フォルダとその配下フィード
        for (final folder in allFolders.where((f) => f.parent == null)) {
          _buildFolderXml(builder, folder, allFolders, allFeeds);
        }
      });
    });

    return builder.buildDocument().toXmlString(pretty: true);
  }

  void _buildFolderXml(
    XmlBuilder builder,
    Folder folder,
    List<Folder> allFolders,
    List<Feed> allFeeds,
  ) {
    builder.element('outline', attributes: {'text': folder.name, 'title': folder.name}, nest: () {
      final feedsInFolder = allFeeds.where((f) => f.folderId == folder.id);
      for (final feed in feedsInFolder) {
        builder.element('outline', attributes: {
          'type': 'rss',
          'text': feed.title ?? feed.url,
          'title': feed.title ?? feed.url,
          'xmlUrl': feed.url,
        });
      }
      final subfolders = allFolders.where((f) => f.parent == folder.id);
      for (final sub in subfolders) {
        _buildFolderXml(builder, sub, allFolders, allFeeds);
      }
    });
  }

  Future<void> exportToFile() async {
    final content = await exportToString();
    final path = await FilePicker.platform.saveFile(
      dialogTitle: 'OPML をエクスポート',
      fileName: 'sweeprss_export.opml',
    );
    if (path != null) {
      await File(path).writeAsString(content);
    }
  }
}

class OpmlImportResult {
  final int feeds;
  final int folders;
  final List<String> newFeedIds;
  const OpmlImportResult({required this.feeds, required this.folders, required this.newFeedIds});
}

class OpmlException implements Exception {
  final String message;
  const OpmlException(this.message);
  @override
  String toString() => message;
}
