import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 現在表示中の WebView コントローラー（スペースキースクロールに使用）
final readerWebViewControllerProvider =
    StateProvider<InAppWebViewController?>((ref) => null);

/// 記事リストの ScrollController（キーボードナビゲーション時のスクロールに使用）
final articlesScrollControllerProvider = Provider<ScrollController>((ref) {
  final sc = ScrollController();
  ref.onDispose(sc.dispose);
  return sc;
});
