// SSRF 防止: 現行 Rust 実装の Dart 移植
class UrlValidator {
  static const int _maxUrlLength = 2048;

  static final _privateRanges = [
    _IpRange(10, 0, 0, 0, 8),
    _IpRange(172, 16, 0, 0, 12),
    _IpRange(192, 168, 0, 0, 16),
    _IpRange(169, 254, 0, 0, 16),
  ];

  static String? validate(String url) {
    if (url.length > _maxUrlLength) {
      return 'URL が長すぎます (最大 $_maxUrlLength 文字)';
    }

    final uri = Uri.tryParse(url);
    if (uri == null) return 'URL の形式が不正です';

    if (uri.scheme != 'http' && uri.scheme != 'https') {
      return 'http または https のみ対応しています';
    }

    final host = uri.host.toLowerCase();
    if (host.isEmpty) return 'ホスト名が指定されていません';

    if (host == 'localhost' || host == '127.0.0.1' || host == '::1') {
      return 'ローカルアドレスへのアクセスは許可されていません';
    }

    final parts = host.split('.').map(int.tryParse).toList();
    if (parts.length == 4 && parts.every((p) => p != null)) {
      final ip = parts.cast<int>();
      for (final range in _privateRanges) {
        if (range.contains(ip[0], ip[1], ip[2], ip[3])) {
          return 'プライベートネットワークへのアクセスは許可されていません';
        }
      }
    }

    return null; // valid
  }
}

class _IpRange {
  final int a, b, c, d, prefix;
  const _IpRange(this.a, this.b, this.c, this.d, this.prefix);

  bool contains(int oa, int ob, int oc, int od) {
    final mask = prefix == 0 ? 0 : (0xFFFFFFFF << (32 - prefix)) & 0xFFFFFFFF;
    final network = ((a << 24) | (b << 16) | (c << 8) | d) & mask;
    final addr = ((oa << 24) | (ob << 16) | (oc << 8) | od) & mask;
    return network == addr;
  }
}
