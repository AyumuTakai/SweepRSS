import 'dart:io';
import 'package:drift/drift.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:xml/xml.dart';

import '../database/app_database.dart';
import 'url_validator.dart';
import 'dart:convert';

class OpmlService {
  final AppDatabase _db;
  static const _uuid = Uuid();

  OpmlService(this._db);

  Future<String?> pickOpmlFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['opml', 'xml'],
    );
    return result?.files.single.path;
  }

  Future<OpmlImportResult> importFromFile(
    String path, {
    String? spaceId,
  }) async {
    final content = await File(path).readAsString();
    return importFromString(content, spaceId: spaceId);
  }

  /// OPML をパースして DB に挿入する。
  ///
  /// - [spaceId] が指定された場合、フォルダ・フィードをそのスペースへ割り当てる。
  /// - トップレベル outline に `sweepType="space"` がある場合はマルチスペース形式として
  ///   スペースを再作成し、それぞれの配下へインポートする。
  /// - 再帰深度は最大 [_maxImportDepth] に制限し、スタックオーバーフローを防ぐ。
  static const int _maxImportDepth = 20;

  Future<OpmlImportResult> importFromString(
    String opmlContent, {
    String? spaceId,
  }) async {
    final doc = XmlDocument.parse(opmlContent);
    final body = doc.findAllElements('body').firstOrNull;
    if (body == null) throw const OpmlException('OPML body が見つかりません');

    var feedCount = 0;
    var folderCount = 0;
    final newFeedIds = <String>[];

    await _db.transaction(() async {
      var folderOrderBase = (await _db.foldersDao.getAllFolders()).length;
      // 重複 URL チェック用: DB 既存 URL + 今回インポートした URL の両方を追跡する
      final existingUrls = (await _db.feedsDao.getAllActiveFeeds())
          .map((f) => f.url)
          .toSet();

      Future<void> processOutlines(
        Iterable<XmlElement> outlines,
        String? parentFolderId,
        String? currentSpaceId,
        int depth,
      ) async {
        if (depth > _maxImportDepth) return;

        for (final outline in outlines) {
          final xmlUrl = outline.getAttribute('xmlUrl');
          final title =
              outline.getAttribute('title') ??
              outline.getAttribute('text') ??
              '';

          if (xmlUrl != null && xmlUrl.isNotEmpty) {
            // 不正な URL（プライベート IP 等）を含む OPML でも安全にインポートできるよう
            // 同じバリデーションを適用してスキップする
            if (UrlValidator.validate(xmlUrl) != null) continue;
            // DB 既存 + 今回インポート済み URL との重複をスキップ
            if (existingUrls.contains(xmlUrl)) continue;
            try {
              final feedId = _uuid.v4();
              await _db.feedsDao.insertFeed(
                FeedsCompanion.insert(
                  id: feedId,
                  url: xmlUrl,
                  title: Value(title.isNotEmpty ? title : null),
                  folderId: Value(parentFolderId),
                  spaceId: Value(currentSpaceId),
                ),
              );
              existingUrls.add(xmlUrl); // 同一 OPML 内の重複も防ぐ
              newFeedIds.add(feedId);
              feedCount++;
            } catch (_) {
              // その他の DB エラーはスキップ
            }
          } else if (outline.getAttribute('sweepType') == 'space') {
            // マルチスペース OPML: スペースを作成して配下を処理
            final spaceName = title.isNotEmpty ? title : 'Untitled Space';
            final newSpaceId = await _db.spacesDao.insertSpace(spaceName);
            await processOutlines(
              outline.findElements('outline'),
              null,
              newSpaceId,
              depth + 1,
            );
          } else {
            // フォルダ
            final folderId = _uuid.v4();
            await _db.foldersDao.insertFolder(
              FoldersCompanion.insert(
                id: folderId,
                name: title.isNotEmpty ? title : 'Untitled Folder',
                parent: Value(parentFolderId),
                order: Value(folderOrderBase++),
                spaceId: Value(currentSpaceId),
              ),
            );
            folderCount++;
            await processOutlines(
              outline.findElements('outline'),
              folderId,
              currentSpaceId,
              depth + 1,
            );
          }
        }
      }

      await processOutlines(body.findElements('outline'), null, spaceId, 0);
    });

    return OpmlImportResult(
      feeds: feedCount,
      folders: folderCount,
      newFeedIds: newFeedIds,
    );
  }

  // ── エクスポート ──────────────────────────────────────────────────────────

  /// スペース名をファイル名として使う際の安全化。パス区切り文字等を '_' に置換する。
  String _toSafeFilename(String name) =>
      name.replaceAll(RegExp(r'[/\\:*?"<>|\x00-\x1F]'), '_');

  /// すべてのスペースを含む OPML 文字列を生成する。
  /// スペースは最上位の `sweepType="space"` outline としてグルーピングされる。
  /// 他の RSS リーダーにはフォルダとして見える（後方互換性あり）。
  Future<String> exportAllSpacesToString() async {
    final allSpaces = await _db.spacesDao.getAllSpaces();
    final allFolders = await _db.foldersDao.getAllFolders();
    final allFeeds = await _db.feedsDao.getAllActiveFeeds();

    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0" encoding="UTF-8"');
    builder.element(
      'opml',
      attributes: {'version': '2.0'},
      nest: () {
        builder.element(
          'head',
          nest: () {
            builder.element('title', nest: 'SweepRSS Export');
          },
        );
        builder.element(
          'body',
          nest: () {
            for (final space in allSpaces) {
              builder.element(
                'outline',
                attributes: {
                  'text': space.name,
                  'title': space.name,
                  'sweepType': 'space',
                },
                nest: () {
                  final uncatFeeds = allFeeds.where(
                    (f) => f.folderId == null && f.spaceId == space.id,
                  );
                  for (final feed in uncatFeeds) {
                    builder.element(
                      'outline',
                      attributes: {
                        'type': 'rss',
                        'text': feed.title ?? feed.url,
                        'title': feed.title ?? feed.url,
                        'xmlUrl': feed.url,
                      },
                    );
                  }
                  for (final folder in allFolders.where(
                    (f) => f.parent == null && f.spaceId == space.id,
                  )) {
                    _buildFolderXml(builder, folder, allFolders, allFeeds);
                  }
                },
              );
            }
            // スペース未割り当てのトップレベルフォルダ（移行前データの安全網）
            for (final folder in allFolders.where(
              (f) => f.parent == null && f.spaceId == null,
            )) {
              _buildFolderXml(builder, folder, allFolders, allFeeds);
            }
          },
        );
      },
    );

    return builder.buildDocument().toXmlString(pretty: true);
  }

  /// 指定スペースのみを含む OPML 文字列を生成する（既存フォーマットと同一構造）。
  Future<String> exportCurrentSpaceToString(String spaceId) async {
    final spaceFolders = await _db.foldersDao.getFoldersInSpace(spaceId);
    final allActiveFeeds = await _db.feedsDao.getAllActiveFeeds();
    final space = await _db.spacesDao.getSpaceById(spaceId);
    final spaceFolderIds = spaceFolders.map((f) => f.id).toSet();

    final spaceFeeds = allActiveFeeds
        .where(
          (f) =>
              (f.folderId != null && spaceFolderIds.contains(f.folderId)) ||
              (f.folderId == null && f.spaceId == spaceId),
        )
        .toList();

    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0" encoding="UTF-8"');
    builder.element(
      'opml',
      attributes: {'version': '2.0'},
      nest: () {
        builder.element(
          'head',
          nest: () {
            builder.element(
              'title',
              nest: 'SweepRSS Export - ${space?.name ?? ''}',
            );
          },
        );
        builder.element(
          'body',
          nest: () {
            for (final feed in spaceFeeds.where((f) => f.folderId == null)) {
              builder.element(
                'outline',
                attributes: {
                  'type': 'rss',
                  'text': feed.title ?? feed.url,
                  'title': feed.title ?? feed.url,
                  'xmlUrl': feed.url,
                },
              );
            }
            for (final folder in spaceFolders.where((f) => f.parent == null)) {
              _buildFolderXml(builder, folder, spaceFolders, spaceFeeds);
            }
          },
        );
      },
    );

    return builder.buildDocument().toXmlString(pretty: true);
  }

  static const int _maxExportDepth = 20;

  void _buildFolderXml(
    XmlBuilder builder,
    Folder folder,
    List<Folder> allFolders,
    List<Feed> allFeeds, {
    int depth = 0,
  }) {
    if (depth > _maxExportDepth) return;
    builder.element(
      'outline',
      attributes: {'text': folder.name, 'title': folder.name},
      nest: () {
        final feedsInFolder = allFeeds.where((f) => f.folderId == folder.id);
        for (final feed in feedsInFolder) {
          builder.element(
            'outline',
            attributes: {
              'type': 'rss',
              'text': feed.title ?? feed.url,
              'title': feed.title ?? feed.url,
              'xmlUrl': feed.url,
            },
          );
        }
        final subfolders = allFolders.where((f) => f.parent == folder.id);
        for (final sub in subfolders) {
          _buildFolderXml(builder, sub, allFolders, allFeeds, depth: depth + 1);
        }
      },
    );
  }

  Future<void> exportAllSpacesToFile({required String dialogTitle}) async {
    final content = await exportAllSpacesToString();
    await FilePicker.saveFile(
      dialogTitle: dialogTitle,
      fileName: 'sweeprss_export_all.opml',
      bytes: Uint8List.fromList(utf8.encode(content)),
    );
    // if (path != null) {
    //   await File(path).writeAsString(content);
    // }
  }

  Future<void> exportCurrentSpaceToFile(
    Space space, {
    required String dialogTitle,
  }) async {
    final content = await exportCurrentSpaceToString(space.id);
    await FilePicker.saveFile(
      dialogTitle: dialogTitle,
      fileName: 'sweeprss_export_${_toSafeFilename(space.name)}.opml',
      bytes: Uint8List.fromList(utf8.encode(content)),
    );
    // if (path != null) {
    //   await File(path).writeAsString(content);
    // }
  }
}

class OpmlImportResult {
  final int feeds;
  final int folders;
  final List<String> newFeedIds;
  const OpmlImportResult({
    required this.feeds,
    required this.folders,
    required this.newFeedIds,
  });
}

class OpmlException implements Exception {
  final String message;
  const OpmlException(this.message);
  @override
  String toString() => message;
}
