# SweepRSS

クロスプラットフォーム対応のRSSリーダーアプリです。Flutter製。

## スクリーンショット

*macOS 3ペインレイアウト*

## 機能

- **フィード管理**: RSS / Atom / JSON Feed に対応。フィードの追加・編集・削除
- **フォルダ整理**: フォルダでフィードを整理。ドラッグ&ドロップでフォルダ間移動・並び替え
- **記事一覧**: 未読・フラグ付き・すべて・フォルダ・フィード単位での絞り込み表示
- **記事表示**: WebView によるリッチな記事レンダリング
- **フォルダ開閉の永続化**: アプリ再起動後もフォルダの開閉状態を維持
- **ゴミ箱**: 削除したフィードをゴミ箱に移動。右クリックで復元または完全削除
- **自動更新**: バックグラウンドでのフィード自動取得（60秒間隔）
- **OPML インポート / エクスポート**: 他のRSSリーダーとのフィードリスト交換
- **セキュリティ**: SSRF防止・HTMLサニタイズ

## 対応プラットフォーム

| プラットフォーム | 状態 |
|---|---|
| macOS | ✅ 動作確認済み |
| iOS | 🔧 対応予定 |
| Android | 🔧 対応予定 |
| Windows | 🔧 対応予定 |
| Linux | 🔧 対応予定 |

## 技術スタック

| カテゴリ | ライブラリ |
|---|---|
| フレームワーク | Flutter 3.44 / Dart 3.12 |
| 状態管理 | Riverpod 2.6 |
| データベース | drift 2.28 (SQLite) |
| WebView | flutter_inappwebview 6.1 |
| RSSパース | webfeed_plus |
| HTTP | dio |
| OPML | xml |

## セットアップ

### 必要環境

- Flutter 3.44 以上
- macOS 13 以上（macOS ビルドの場合）
- Xcode 15 以上（macOS / iOS ビルドの場合）

### ビルド手順

```bash
# 依存パッケージの取得
flutter pub get

# macOS で起動
flutter run -d macos

# コード生成（drift / Riverpod）
dart run build_runner build --delete-conflicting-outputs
```

## プロジェクト構成

```
lib/
├── main.dart
├── app.dart                          # MaterialApp + PlatformMenuBar
├── core/
│   ├── database/                     # drift ORM (テーブル・DAO・マイグレーション)
│   ├── models/                       # Selection sealed class
│   └── services/                     # RSS取得・OPMLパース・URLバリデーション・HTMLサニタイズ
├── features/
│   ├── sidebar/widgets/              # サイドバーパネル・フォルダタイル・フィードタイル
│   ├── articles/                     # 記事一覧パネル
│   ├── reader/                       # WebViewリーダーパネル
│   ├── dialogs/                      # フィード追加・編集・フォルダ管理ダイアログ
│   └── opml/                         # OPMLインポートプロバイダー
└── shared/
    ├── providers/                    # DB・選択状態・フォルダ開閉・更新タイマー
    └── widgets/                      # アダプティブレイアウト・トースト通知
```

## ライセンス

MIT License
