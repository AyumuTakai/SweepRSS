import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/generated/app_localizations.dart';

import '../../core/database/app_database.dart';
import '../../features/articles/providers/articles_provider.dart';
import '../../features/articles/widgets/articles_panel.dart';
import '../../features/reader/widgets/reader_panel.dart';
import '../../features/sidebar/widgets/sidebar_panel.dart';
import '../providers/database_provider.dart';
import '../providers/reader_controller_provider.dart';
import '../providers/selection_provider.dart';

class AdaptiveLayout extends ConsumerStatefulWidget {
  const AdaptiveLayout({super.key});

  @override
  ConsumerState<AdaptiveLayout> createState() => _AdaptiveLayoutState();
}

class _AdaptiveLayoutState extends ConsumerState<AdaptiveLayout> {
  double _articlesWidth = 320;
  double _articlesHeight = 300;

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_handleKeyEvent);
    // 起動時に検索フィールドがフォーカスを取得しないよう次フレームで解除
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) FocusManager.instance.primaryFocus?.unfocus();
    });
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
    super.dispose();
  }

  // ── キーボードハンドラー ────────────────────────────────────────────────────

  bool _handleKeyEvent(KeyEvent event) {
    // テキスト入力中は横取りしない
    if (_isTextInputFocused) return false;

    // スペースキーは長押し（KeyRepeatEvent）でも連続スクロールさせる。
    // 矢印キーは KeyDownEvent のみ処理（記事を高速で連続送りしない）。
    if (event.logicalKey == LogicalKeyboardKey.space) {
      if (event is! KeyDownEvent && event is! KeyRepeatEvent) return false;
      _handleSpace();
      return true;
    }

    if (event is! KeyDownEvent) return false;

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      _handleArrowDown();
      return true;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      _handleArrowUp();
      return true;
    }
    return false;
  }

  bool get _isTextInputFocused {
    final node = FocusManager.instance.primaryFocus;
    if (node == null) return false;
    final context = node.context;
    if (context == null) return false;
    // フォーカスノードが EditableText（TextField の内部ウィジェット）にあるか確認
    if (context.widget is EditableText) return true;
    bool found = false;
    context.visitAncestorElements((element) {
      if (element.widget is EditableText) {
        found = true;
        return false;
      }
      return true;
    });
    return found;
  }

  // ── スペースキー: WebView スクロール → 底で次の未読 ────────────────────────

  Future<void> _handleSpace() async {
    if (!mounted) return;
    final currentId = ref.read(currentArticleIdProvider);
    if (currentId == null) {
      _selectNextUnread();
      return;
    }

    final controller = ref.read(readerWebViewControllerProvider);
    if (controller == null) {
      _selectNextUnread();
      return;
    }

    try {
      final atBottom = await controller.evaluateJavascript(source: '''
        (() => {
          const scrollTop = window.pageYOffset || document.documentElement.scrollTop;
          const windowHeight = window.innerHeight;
          const bodyHeight = Math.max(
            document.body.scrollHeight,
            document.documentElement.scrollHeight
          );
          if (scrollTop + windowHeight >= bodyHeight - 20) return true;
          window.scrollBy({ top: 400, behavior: 'smooth' });
          return false;
        })()
      ''');
      if (!mounted) return;
      if (atBottom == true) _selectNextUnread();
    } catch (_) {
      // JS 無効（summary ビュー）の場合はネイティブスクロールを試みる
      if (!mounted) return;
      try {
        final scrollY = await controller.getScrollY() ?? 0;
        final contentHeight = await controller.getContentHeight() ?? 0;
        if (!mounted) return;
        if (contentHeight <= 0 || scrollY + 400 >= contentHeight - 20) {
          _selectNextUnread();
        } else {
          await controller.scrollBy(x: 0, y: 400);
        }
      } catch (_) {
        if (mounted) _selectNextUnread();
      }
    }
  }

  // ── ↓キー: 次の未読記事 ────────────────────────────────────────────────────

  void _handleArrowDown() => _selectNextUnread();

  // ── ↑キー: 前の記事 ────────────────────────────────────────────────────────

  void _handleArrowUp() {
    final articlesAsync = ref.read(articlesProvider);
    final articles = articlesAsync.when(
      data: (data) => data,
      loading: () => null,
      error: (_, _) => null,
    );
    if (articles == null || articles.isEmpty) return;

    final currentId = ref.read(currentArticleIdProvider);
    if (currentId == null) return;

    final currentIndex = articles.indexWhere((a) => a.id == currentId);
    if (currentIndex <= 0) return;

    _selectArticle(articles[currentIndex - 1], currentIndex - 1);
  }

  // ── 次の未読記事を選択 ─────────────────────────────────────────────────────

  void _selectNextUnread() {
    final articlesAsync = ref.read(articlesProvider);
    final articles = articlesAsync.when(
      data: (data) => data,
      loading: () => null,
      error: (_, _) => null,
    );
    if (articles == null || articles.isEmpty) return;

    final currentId = ref.read(currentArticleIdProvider);
    final currentIndex =
        currentId == null ? -1 : articles.indexWhere((a) => a.id == currentId);

    for (int i = currentIndex + 1; i < articles.length; i++) {
      if (articles[i].unread) {
        _selectArticle(articles[i], i);
        return;
      }
    }
  }

  // ── 記事を選択して既読化・リストスクロール ─────────────────────────────────

  void _selectArticle(Entry article, int index) {
    // 古いコントローラーをクリア（新記事読み込み前にスペースキーが
    // 旧 WebView をスクロールしないようにする）
    ref.read(readerWebViewControllerProvider.notifier).state = null;
    ref.read(currentArticleIdProvider.notifier).state = article.id;
    if (article.unread) {
      ref.read(databaseProvider).entriesDao.markRead(article.id).then((_) {
        if (mounted) ref.invalidate(articlesProvider);
      });
    }
    _scrollArticlesTo(index);
  }

  void _scrollArticlesTo(int index) {
    final sc = ref.read(articlesScrollControllerProvider);
    if (!sc.hasClients) return;
    // ArticleTile の推定高さ（padding 16px + テキスト ~21px = ~37px）
    const estimatedItemHeight = 37.0;
    final target =
        (index * estimatedItemHeight).clamp(0.0, sc.position.maxScrollExtent);
    sc.animateTo(
      target,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
    );
  }

  // ── レイアウト ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDesktopPlatform = Platform.isMacOS || Platform.isWindows || Platform.isLinux;
    return isDesktopPlatform ? _buildDesktop() : _buildMobile();
  }

  Widget _buildDesktop() {
    final width = MediaQuery.of(context).size.width;

    if (width > 1600) {
      return _buildThreeColumnLayout();
    } else {
      return _buildTwoColumnLayout();
    }
  }

  Widget _buildThreeColumnLayout() {
    return Row(
      children: [
        const SidebarPanel(),
        const VerticalDivider(width: 1),
        SizedBox(
          width: _articlesWidth,
          child: const ArticlesPanel(),
        ),
        MouseRegion(
          cursor: SystemMouseCursors.resizeColumn,
          child: GestureDetector(
            onHorizontalDragUpdate: (d) {
              setState(() {
                _articlesWidth =
                    (_articlesWidth + d.delta.dx).clamp(200, 600);
              });
            },
            child: Container(
              width: 5,
              color: Colors.transparent,
              child: const VerticalDivider(width: 1),
            ),
          ),
        ),
        const Expanded(child: ReaderPanel()),
      ],
    );
  }

  Widget _buildTwoColumnLayout() {
    return Row(
      children: [
        const SidebarPanel(),
        const VerticalDivider(width: 1),
        Expanded(
          child: Column(
            children: [
              SizedBox(
                height: _articlesHeight,
                child: const ArticlesPanel(),
              ),
              MouseRegion(
                cursor: SystemMouseCursors.resizeRow,
                child: GestureDetector(
                  onVerticalDragUpdate: (d) {
                    setState(() {
                      _articlesHeight =
                          (_articlesHeight + d.delta.dy).clamp(100, 500);
                    });
                  },
                  child: Container(
                    height: 5,
                    color: Colors.transparent,
                    child: const Divider(height: 1),
                  ),
                ),
              ),
              const Expanded(child: ReaderPanel()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobile() => const _MobileLayout();
}

// ── モバイルレイアウト ──────────────────────────────────────────────────────────

class _MobileLayout extends StatefulWidget {
  const _MobileLayout();

  @override
  State<_MobileLayout> createState() => _MobileLayoutState();
}

class _MobileLayoutState extends State<_MobileLayout> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          SidebarPanel(),
          ArticlesPanel(),
          ReaderPanel(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        destinations: [
          NavigationDestination(
              icon: const Icon(Icons.folder),
              label: AppLocalizations.of(context).mobileNavFeeds),
          NavigationDestination(
              icon: const Icon(Icons.list),
              label: AppLocalizations.of(context).mobileNavArticles),
          NavigationDestination(
              icon: const Icon(Icons.article),
              label: AppLocalizations.of(context).mobileNavReader),
        ],
      ),
    );
  }
}
