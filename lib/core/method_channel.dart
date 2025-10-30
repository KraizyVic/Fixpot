
import 'package:flutter/services.dart';

/// ApkInstaller - simple MethodChannel bridge to native Android installer logic.
class ApkInstaller {
  static const _channel = MethodChannel('app_updater');

  /// installApk - invokes native code with path to downloaded APK
  static Future<void> installApk(String path) async {
    await _channel.invokeMethod('installApk', {'path': path});
  }
}
