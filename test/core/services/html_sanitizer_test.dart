import 'package:flutter_test/flutter_test.dart';
import 'package:rssreader/core/services/html_sanitizer.dart';

void main() {
  group('HtmlSanitizer.sanitize', () {
    // ── script タグ除去 ───────────────────────────────────────────────────────
    test('script タグを除去する', () {
      const input = '<p>Hello</p><script>alert("xss")</script><p>World</p>';
      final result = HtmlSanitizer.sanitize(input);
      expect(result, isNot(contains('<script')));
      expect(result, contains('<p>Hello</p>'));
      expect(result, contains('<p>World</p>'));
    });

    test('属性付き script タグを除去する', () {
      const input = '<script type="text/javascript">evil()</script>';
      final result = HtmlSanitizer.sanitize(input);
      expect(result, isNot(contains('<script')));
      expect(result, isNot(contains('evil()')));
    });

    test('複数行 script タグを除去する', () {
      const input = '<script>\nvar x = 1;\nalert(x);\n</script>';
      final result = HtmlSanitizer.sanitize(input);
      expect(result, isNot(contains('alert')));
    });

    // ── inline イベントハンドラ除去 ──────────────────────────────────────────
    test('onclick を除去する', () {
      const input = '<a href="#" onclick="evil()">link</a>';
      final result = HtmlSanitizer.sanitize(input);
      expect(result, isNot(contains('onclick')));
    });

    test('onerror を除去する', () {
      const input = '<img src="x" onerror="alert(1)">';
      final result = HtmlSanitizer.sanitize(input);
      expect(result, isNot(contains('onerror')));
    });

    test('onload を除去する', () {
      const input = '<body onload="evil()">';
      final result = HtmlSanitizer.sanitize(input);
      expect(result, isNot(contains('onload')));
    });

    test('シングルクォートのイベントハンドラを除去する', () {
      const input = "<a href='#' onclick='evil()'>link</a>";
      final result = HtmlSanitizer.sanitize(input);
      expect(result, isNot(contains('onclick')));
    });

    // ── javascript: URL 除去 ─────────────────────────────────────────────────
    test('href="javascript:..." を無効化する', () {
      const input = '<a href="javascript:alert(1)">click</a>';
      final result = HtmlSanitizer.sanitize(input);
      expect(result, isNot(contains('javascript:')));
      expect(result, contains('href="#"'));
    });

    test("href='javascript:...' を無効化する", () {
      const input = "<a href='javascript:void(0)'>click</a>";
      final result = HtmlSanitizer.sanitize(input);
      expect(result, isNot(contains('javascript:')));
    });

    // ── 正常な HTML はそのまま ───────────────────────────────────────────────
    test('通常の href はそのまま残す', () {
      const input = '<a href="https://example.com">link</a>';
      final result = HtmlSanitizer.sanitize(input);
      expect(result, contains('href="https://example.com"'));
    });

    test('img src はそのまま残す', () {
      const input = '<img src="https://example.com/img.png" alt="photo">';
      final result = HtmlSanitizer.sanitize(input);
      expect(result, contains('src="https://example.com/img.png"'));
    });

    test('空文字列でクラッシュしない', () {
      expect(() => HtmlSanitizer.sanitize(''), returnsNormally);
    });
  });

  group('HtmlSanitizer.injectBaseUrl', () {
    const htmlWithHead = '<html><head></head><body>content</body></html>';
    const htmlWithBase = '<html><head><base href="other"></head><body></body></html>';

    test('head タグに base を挿入する', () {
      final result = HtmlSanitizer.injectBaseUrl(
          htmlWithHead, 'https://example.com');
      expect(result, contains('<base href="https://example.com">'));
    });

    test('すでに base タグがある場合は変更しない', () {
      final result = HtmlSanitizer.injectBaseUrl(
          htmlWithBase, 'https://example.com');
      expect(result, contains('<base href="other">'));
      expect(result, isNot(contains('https://example.com')));
    });

    test('空の baseUrl は挿入しない', () {
      final result = HtmlSanitizer.injectBaseUrl(htmlWithHead, '');
      expect(result, isNot(contains('<base')));
    });

    test('http 以外のスキームは挿入しない', () {
      final result = HtmlSanitizer.injectBaseUrl(
          htmlWithHead, 'javascript:alert(1)');
      expect(result, isNot(contains('<base')));
    });

    test('file:// スキームは挿入しない', () {
      final result = HtmlSanitizer.injectBaseUrl(
          htmlWithHead, 'file:///etc/passwd');
      expect(result, isNot(contains('<base')));
    });

    test('URL 内の " をエスケープする', () {
      final result = HtmlSanitizer.injectBaseUrl(
          htmlWithHead, 'https://example.com/"evil"');
      expect(result, isNot(contains('"evil"')));
      expect(result, contains('&quot;evil&quot;'));
    });

    test('URL 内の & をエスケープする', () {
      final result = HtmlSanitizer.injectBaseUrl(
          htmlWithHead, 'https://example.com/path?a=1&b=2');
      expect(result, contains('&amp;b=2'));
    });
  });
}
