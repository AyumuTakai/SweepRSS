import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/database/app_database.dart';
import 'database_provider.dart';
import 'selection_provider.dart';
import '../../core/models/selection.dart';

const _kFileName = 'active_space.json';

final spacesStreamProvider = StreamProvider<List<Space>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.spacesDao.watchAllSpaces();
});

final activeSpaceProvider =
    AsyncNotifierProvider<ActiveSpaceNotifier, String?>(
  ActiveSpaceNotifier.new,
);

class ActiveSpaceNotifier extends AsyncNotifier<String?> {
  File? _file;

  Future<File> _resolveFile() async {
    if (_file != null) return _file!;
    final dir = await getApplicationSupportDirectory();
    _file = File('${dir.path}/$_kFileName');
    return _file!;
  }

  @override
  Future<String?> build() async {
    final file = await _resolveFile();
    if (!file.existsSync()) return null;
    try {
      final raw = jsonDecode(await file.readAsString());
      return raw as String?;
    } catch (_) {
      return null;
    }
  }

  void setSpace(String? spaceId) {
    state = AsyncData(spaceId);
    _persist(spaceId);
    ref.read(selectionProvider.notifier).state = const SelectionAll();
    ref.read(currentArticleIdProvider.notifier).state = null;
  }

  void _persist(String? spaceId) {
    final file = _file;
    if (file != null) {
      file.writeAsString(jsonEncode(spaceId));
    } else {
      _resolveFile().then((f) => f.writeAsString(jsonEncode(spaceId)));
    }
  }
}

/// アクティブスペースを spaces リストと突合した結果を返す派生プロバイダ。
/// スペースが削除されていた場合はリストの先頭スペースへフォールバック。
/// スペースがひとつも存在しない場合は null（全表示モード）を返す。
final resolvedActiveSpaceProvider = Provider<Space?>((ref) {
  final activeIdAsync = ref.watch(activeSpaceProvider);
  final activeId = activeIdAsync.when(
    data: (data) => data,
    loading: () => null,
    error: (_, _) => null,
  );
  final spacesAsync = ref.watch(spacesStreamProvider);
  final spaces = spacesAsync.when(
    data: (data) => data,
    loading: () => [],
    error: (_, _) => [],
  );
  if (spaces.isEmpty) return null;
  return spaces.firstWhere(
    (s) => s.id == activeId,
    orElse: () => spaces.first,
  );
});
