import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/services/html_sanitizer.dart';
import '../../../shared/providers/database_provider.dart';
import '../../../shared/providers/reader_controller_provider.dart';
import '../../../shared/providers/selection_provider.dart';
import '../../articles/providers/articles_provider.dart';

class ReaderPanel extends ConsumerWidget {
  const ReaderPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articleAsync = ref.watch(currentArticleProvider);
    final feedAsync = ref.watch(currentArticleFeedProvider);

    return articleAsync.when(
      data: (article) {
        if (article == null) {
          return const Center(
            child: Text(
              '記事を選択してください',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          );
        }

        final requiresExternal =
            feedAsync.valueOrNull?.requiresExternalBrowser ?? false;

        return Column(
          children: [
            _ReaderToolbar(
              title: article.title ?? '',
              link: article.link,
              articleId: article.id,
              flagged: article.flagged,
            ),
            Expanded(
              child: _ReaderContent(
                key: ValueKey(article.id),
                summary: article.summary,
                link: article.link,
                requiresExternalBrowser: requiresExternal,
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('エラー: $e')),
    );
  }
}

/// 表示モードを決定して適切なビューを返す
class _ReaderContent extends StatelessWidget {
  final String? summary;
  final String? link;
  final bool requiresExternalBrowser;

  const _ReaderContent({
    super.key,
    required this.summary,
    required this.link,
    required this.requiresExternalBrowser,
  });

  @override
  Widget build(BuildContext context) {
    final hasSummary = summary != null && summary!.isNotEmpty;
    final hasLink = link != null && link!.isNotEmpty;

    // モード1: link あり → 記事ページを WebView でロード（優先）
    if (hasLink) {
      if (requiresExternalBrowser) {
        return _ExternalBrowserPrompt(link: link!);
      }
      return _UrlView(url: link!);
    }

    // モード2: link なし & summary あり → RSS 要約 HTML を表示
    if (hasSummary) {
      return _SummaryView(summary: summary!, link: link);
    }

    // モード3: コンテンツなし
    return const Center(
      child: Text('コンテンツがありません', style: TextStyle(color: Colors.grey)),
    );
  }
}

// ── URL を WebView でロード ────────────────────────────────────────────────────

class _UrlView extends ConsumerWidget {
  final String url;
  const _UrlView({required this.url});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InAppWebView(
      initialUrlRequest: URLRequest(url: WebUri(url)),
      initialSettings: InAppWebViewSettings(
        javaScriptEnabled: true,
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: true,
      ),
      onWebViewCreated: (controller) {
        ref.read(readerWebViewControllerProvider.notifier).state = controller;
      },
      onLoadStop: (controller, url) async {
        // ページ読み込み完了後にスクロール位置をトップへリセット
        // （スクロール復元機能や anchor によるオフセットを防ぐ）
        await controller.evaluateJavascript(
          source: 'window.scrollTo(0, 0);',
        );
      },
      shouldOverrideUrlLoading: (controller, action) async {
        // ユーザーが明示的にリンクをクリックした場合のみ外部ブラウザで開く。
        // 自動リダイレクトや JS ナビゲーションは WebView 内で処理する。
        if (action.navigationType == NavigationType.LINK_ACTIVATED) {
          final dest = action.request.url;
          if (dest != null) {
            await launchUrl(dest.uriValue, mode: LaunchMode.externalApplication);
          }
          return NavigationActionPolicy.CANCEL;
        }
        return NavigationActionPolicy.ALLOW;
      },
    );
  }
}

// ── RSS 要約 HTML (link なしの場合のフォールバック) ──────────────────────────
// macOS の flutter_inappwebview は loadData() が動作しないため、
// HTML を base64 エンコードした data: URI を initialUrlRequest に渡す。

class _SummaryView extends ConsumerWidget {
  final String summary;
  final String? link;

  const _SummaryView({required this.summary, this.link});

  String _buildDataUri() {
    final sanitized = HtmlSanitizer.sanitize(summary);
    final html = HtmlSanitizer.injectBaseUrl(_wrapStyle(sanitized), link ?? '');
    final encoded = base64Encode(utf8.encode(html));
    return 'data:text/html;charset=utf-8;base64,$encoded';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InAppWebView(
      initialUrlRequest: URLRequest(url: WebUri(_buildDataUri())),
      initialSettings: InAppWebViewSettings(
        javaScriptEnabled: false,
        allowFileAccess: false,
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: true,
        transparentBackground: false,
      ),
      onWebViewCreated: (controller) {
        ref.read(readerWebViewControllerProvider.notifier).state = controller;
      },
      onLoadStop: (controller, url) {
        // data: URI ロード後にスクロール位置をトップへリセット
        controller.scrollTo(x: 0, y: 0);
      },
      shouldOverrideUrlLoading: (controller, action) async {
        final url = action.request.url?.toString() ?? '';
        if (url.startsWith('data:') || url == 'about:blank') {
          return NavigationActionPolicy.ALLOW;
        }
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        return NavigationActionPolicy.CANCEL;
      },
    );
  }

  String _wrapStyle(String content) => '''<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<style>
  body {
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
    font-size: 15px; line-height: 1.7; color: #333;
    max-width: 800px; margin: 0 auto; padding: 16px 20px;
    background: #fff;
  }
  img { max-width: 100%; height: auto; }
  pre { overflow-x: auto; background: #f5f5f5; padding: 8px; border-radius: 4px; }
  a { color: #0066cc; }
  blockquote { border-left: 3px solid #ccc; margin: 0; padding-left: 16px; color: #666; }
</style>
</head>
<body>$content</body>
</html>''';
}

// ── 外部ブラウザ誘導 ──────────────────────────────────────────────────────────

class _ExternalBrowserPrompt extends StatelessWidget {
  final String link;
  const _ExternalBrowserPrompt({required this.link});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.open_in_browser, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          const Text(
            'このサイトは外部ブラウザで表示する必要があります',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            icon: const Icon(Icons.open_in_new, size: 16),
            label: const Text('ブラウザで開く'),
            onPressed: () =>
                launchUrl(Uri.parse(link), mode: LaunchMode.externalApplication),
          ),
        ],
      ),
    );
  }
}

// ── ツールバー ────────────────────────────────────────────────────────────────

class _ReaderToolbar extends ConsumerWidget {
  final String title;
  final String? link;
  final String articleId;
  final bool flagged;

  const _ReaderToolbar({
    required this.title,
    required this.link,
    required this.articleId,
    required this.flagged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: Icon(
              flagged ? Icons.bookmark : Icons.bookmark_border,
              size: 18,
            ),
            tooltip: flagged ? 'フラグを解除' : 'フラグを付ける',
            onPressed: () async {
              await ref
                  .read(databaseProvider)
                  .entriesDao
                  .toggleFlag(articleId, !flagged);
            },
          ),
          if (link != null)
            IconButton(
              icon: const Icon(Icons.open_in_new, size: 18),
              tooltip: 'ブラウザで開く',
              onPressed: () =>
                  launchUrl(Uri.parse(link!), mode: LaunchMode.externalApplication),
            ),
          IconButton(
            icon: const Icon(Icons.mark_email_read, size: 18),
            tooltip: '未読に戻す',
            onPressed: () async {
              await ref
                  .read(databaseProvider)
                  .entriesDao
                  .markUnread(articleId);
              ref.read(currentArticleIdProvider.notifier).state = null;
              ref.invalidate(articlesProvider);
            },
          ),
        ],
      ),
    );
  }
}
