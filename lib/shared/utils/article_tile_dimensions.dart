/// 記事タイル（ArticleTile）の高さを計算するユーティリティ
double getArticleItemHeight({
  double titleFontSize = 13.0,
  double lineHeight = 1.2,
  double verticalPadding = 8.0,
  double iconHeight = 6.0,
}) {
  return (titleFontSize * lineHeight) + verticalPadding + iconHeight;
}
