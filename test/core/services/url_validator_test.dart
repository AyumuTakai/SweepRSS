import 'package:flutter_test/flutter_test.dart';
import 'package:sweeprss/core/services/url_validator.dart';

void main() {
  group('UrlValidator.validate', () {
    // ── 正常系 ──────────────────────────────────────────────────────────────
    test('http URL を受け入れる', () {
      expect(UrlValidator.validate('http://example.com/feed'), isNull);
    });

    test('https URL を受け入れる', () {
      expect(UrlValidator.validate('https://example.com/rss'), isNull);
    });

    test('クエリパラメータ付き URL を受け入れる', () {
      expect(UrlValidator.validate('https://example.com/feed?format=rss'), isNull);
    });

    test('パスが深い URL を受け入れる', () {
      expect(
        UrlValidator.validate('https://example.com/blog/category/rss.xml'),
        isNull,
      );
    });

    // ── スキーム拒否 ─────────────────────────────────────────────────────────
    test('ftp スキームを拒否する', () {
      expect(UrlValidator.validate('ftp://example.com/feed'), isNotNull);
    });

    test('file スキームを拒否する', () {
      expect(UrlValidator.validate('file:///etc/passwd'), isNotNull);
    });

    test('javascript スキームを拒否する', () {
      expect(UrlValidator.validate('javascript:alert(1)'), isNotNull);
    });

    test('スキームなし URL を拒否する', () {
      expect(UrlValidator.validate('example.com/feed'), isNotNull);
    });

    // ── ローカルホスト拒否 ───────────────────────────────────────────────────
    test('localhost を拒否する', () {
      expect(UrlValidator.validate('http://localhost:8080/feed'), isNotNull);
    });

    test('127.0.0.1 を拒否する', () {
      expect(UrlValidator.validate('http://127.0.0.1/feed'), isNotNull);
    });

    test('::1 (IPv6 loopback) を拒否する', () {
      expect(UrlValidator.validate('http://[::1]/feed'), isNotNull);
    });

    // ── プライベート IP 拒否 ─────────────────────────────────────────────────
    test('10.0.0.1 (RFC 1918) を拒否する', () {
      expect(UrlValidator.validate('http://10.0.0.1/feed'), isNotNull);
    });

    test('10.255.255.255 を拒否する', () {
      expect(UrlValidator.validate('http://10.255.255.255/feed'), isNotNull);
    });

    test('172.16.0.1 (RFC 1918) を拒否する', () {
      expect(UrlValidator.validate('http://172.16.0.1/feed'), isNotNull);
    });

    test('172.31.255.255 を拒否する', () {
      expect(UrlValidator.validate('http://172.31.255.255/feed'), isNotNull);
    });

    test('172.32.0.1 はプライベートでないため許可する', () {
      expect(UrlValidator.validate('http://172.32.0.1/feed'), isNull);
    });

    test('192.168.1.1 (RFC 1918) を拒否する', () {
      expect(UrlValidator.validate('http://192.168.1.1/feed'), isNotNull);
    });

    test('169.254.0.1 (リンクローカル) を拒否する', () {
      expect(UrlValidator.validate('http://169.254.169.254/feed'), isNotNull);
    });

    // ── パブリック IP は許可 ─────────────────────────────────────────────────
    test('8.8.8.8 (パブリック) を許可する', () {
      expect(UrlValidator.validate('http://8.8.8.8/feed'), isNull);
    });

    test('93.184.216.34 (example.com IP) を許可する', () {
      expect(UrlValidator.validate('http://93.184.216.34/feed'), isNull);
    });

    // ── URL 長さ制限 ─────────────────────────────────────────────────────────
    test('2048 文字以内の URL を許可する', () {
      final url = 'https://example.com/${'a' * 2020}';
      expect(UrlValidator.validate(url), isNull);
    });

    test('2049 文字以上の URL を拒否する', () {
      final url = 'https://example.com/${'a' * 2049}';
      expect(UrlValidator.validate(url), isNotNull);
    });

    // ── 不正な URL ────────────────────────────────────────────────────────────
    test('空文字列を拒否する', () {
      expect(UrlValidator.validate(''), isNotNull);
    });

    test('ホスト名なし URL を拒否する', () {
      expect(UrlValidator.validate('https:///path'), isNotNull);
    });
  });
}
