import 'package:package_info_plus/package_info_plus.dart';

/// pubspec.yaml の version を実行時に取得して保持する
class AppVersion {
  AppVersion._();

  static String version = '';

  static Future<void> init() async {
    final info = await PackageInfo.fromPlatform();
    version = info.version;
  }
}
