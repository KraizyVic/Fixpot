
import 'package:package_info_plus/package_info_plus.dart';

/// Compares semantic versions 'v1.2.3' or '1.2.3'. Returns true if latest > current.
class VersionHelper {
  static Future<bool> isUpdateAvailable(String latestVersion) async {
    final info = await PackageInfo.fromPlatform();
    final currentVersion = info.version;
    return _isLater(latestVersion, currentVersion);
  }

  static bool _isLater(String latest, String current) {
    final lv = latest.replaceFirst('v', '').split('.').map((s) => int.tryParse(s) ?? 0).toList();
    final cv = current.split('.').map((s) => int.tryParse(s) ?? 0).toList();
    for (var i = 0; i < lv.length; i++) {
      final l = lv[i];
      final c = (i < cv.length) ? cv[i] : 0;
      if (l > c) return true;
      if (l < c) return false;
    }
    return false;
  }
}
