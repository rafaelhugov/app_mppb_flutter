import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppVersionInfo {
  static PackageInfo? _packageInfo;

  static Future<void> ensureInitialized() async {
    if (_packageInfo != null) return;
    try {
      _packageInfo = await PackageInfo.fromPlatform();
    } catch (e) {
      debugPrint('Erro ao inicializar PackageInfo: $e');
    }
  }

  static String get appVersion => _packageInfo?.version ?? '4.0.0';

  static int get appBuildNumber {
    final rawBuild = _packageInfo?.buildNumber;
    if (rawBuild != null) {
      final parsed = int.tryParse(rawBuild);
      if (parsed != null) return parsed;
    }
    return 129;
  }

  static String get platformName {
    if (kIsWeb) return 'web';
    if (Platform.isIOS) return 'ios';
    if (Platform.isAndroid) return 'android';
    if (Platform.isMacOS) return 'macos';
    if (Platform.isWindows) return 'windows';
    if (Platform.isLinux) return 'linux';
    return 'unknown';
  }

  static const String defaultPlayStoreUrl =
      'https://play.google.com/store/apps/details?id=br.mp.mppbapp.app';

  static const String defaultAppStoreUrl =
      'https://apps.apple.com/app/mppb/id6825377891';

  static String get defaultStoreUrl =>
      platformName == 'ios' ? defaultAppStoreUrl : defaultPlayStoreUrl;
}
