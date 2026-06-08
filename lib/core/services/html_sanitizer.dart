class HtmlSanitizer {
  static const _forbiddenAttrs = [
    'onclick', 'onerror', 'onload', 'onmouseover', 'onfocus', 'onblur',
    'onchange', 'onsubmit', 'onkeydown', 'onkeyup', 'onkeypress',
  ];

  static String sanitize(String html) {
    // script タグを除去
    var result = html.replaceAll(
      RegExp('<script[^>]*>.*?</script>', caseSensitive: false, dotAll: true),
      '',
    );
    // inline event handler を除去
    for (final attr in _forbiddenAttrs) {
      result = result.replaceAll(
        RegExp('\\s$attr\\s*=\\s*"[^"]*"', caseSensitive: false),
        '',
      );
      result = result.replaceAll(
        RegExp("\\s$attr\\s*=\\s*'[^']*'", caseSensitive: false),
        '',
      );
    }
    // javascript: URLs を除去
    result = result.replaceAll(
      RegExp('href\\s*=\\s*"javascript:[^"]*"', caseSensitive: false),
      'href="#"',
    );
    result = result.replaceAll(
      RegExp("href\\s*=\\s*'javascript:[^']*'", caseSensitive: false),
      "href='#'",
    );
    return result;
  }

  static String injectBaseUrl(String html, String baseUrl) {
    if (html.contains('<base')) return html;
    if (baseUrl.isEmpty) return html;
    // http / https 以外のスキームや不正な URL は無視する
    final uri = Uri.tryParse(baseUrl);
    if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) {
      return html;
    }
    // 属性値を破断させる文字をエスケープ
    final safeUrl = baseUrl.replaceAll('&', '&amp;').replaceAll('"', '&quot;');
    return html.replaceFirstMapped(
      RegExp('<head[^>]*>', caseSensitive: false),
      (match) => '${match.group(0)}<base href="$safeUrl">',
    );
  }
}
