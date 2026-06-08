import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

const _kFileName = 'folder_expanded.json';

final folderExpandedProvider =
    AsyncNotifierProvider<FolderExpandedNotifier, Map<String, bool>>(
  FolderExpandedNotifier.new,
);

class FolderExpandedNotifier extends AsyncNotifier<Map<String, bool>> {
  // build() 完了後にキャッシュされる。toggle() からも参照できる。
  File? _file;

  Future<File> _resolveFile() async {
    if (_file != null) return _file!;
    final dir = await getApplicationSupportDirectory();
    _file = File('${dir.path}/$_kFileName');
    return _file!;
  }

  @override
  Future<Map<String, bool>> build() async {
    final file = await _resolveFile();
    if (!file.existsSync()) return {};
    try {
      final raw = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      return raw.map((k, v) => MapEntry(k, v as bool));
    } catch (_) {
      return {};
    }
  }

  /// フォルダの展開状態を切り替える。
  /// in-memory 更新は同期的。ファイル書き込みは fire-and-forget。
  void toggle(String folderId) {
    final current = state.when(
      data: (data) => data,
      loading: () => {},
      error: (_, __) => {},
    );
    final next = !(current[folderId] ?? true);
    state = AsyncData({...current, folderId: next});
    _persist({...current, folderId: next});
  }

  void _persist(Map<String, bool> map) {
    // build() でキャッシュ済みなら即書き込み。
    // まだキャッシュされていない場合は resolve してから書き込む。
    final file = _file;
    if (file != null) {
      file.writeAsString(jsonEncode(map));
    } else {
      _resolveFile().then((f) => f.writeAsString(jsonEncode(map)));
    }
  }
}
