import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

class MyHttpOverrides extends HttpOverrides{

  @override
  HttpClient
  createHttpClient(SecurityContext?context){
    return super.createHttpClient(context)..badCertificateCallback = (X509Certificate cert,String host,int port)=>true;
  }
}


/// Returns true for likely TVs, false otherwise.
Future<bool> isAndroidTv() async {
  if (!Platform.isAndroid) return false;

  try {
    final info = DeviceInfoPlugin();
    final androidInfo = await info.androidInfo;

    // 1) Check systemFeatures (most reliable if available)
    final features = androidInfo.systemFeatures; // may be null on some versions
    final lower = features.map((s) => s.toLowerCase()).toList();
    if (lower.contains('android.software.leanback') || lower.contains('android.software.leanback_only') || lower.contains('android.hardware.type.television') || lower.contains('android.hardware.type.watch') == false && lower.contains('android.hardware.type.television')) {
      return true;
    }

    // 2) Fallback: check build characteristics string (tv often appears here)
    final characteristics = androidInfo.display.toString();

    // If systemFeatures missing, try model/manufacturer heuristics
    final model = (androidInfo.model ?? '').toLowerCase();
    final manufacturer = (androidInfo.manufacturer ?? '').toLowerCase();
    if (model.contains('tv') || manufacturer.contains('tv') || model.contains('androidtv')) {
      return true;
    }

    // 3) Final fallback: screen-size heuristic (needs BuildContext) — provide separate helper
    // Prefer using `isLargeScreen(context)` in widgets when you have BuildContext available.

  } catch (e) {
    // ignore errors and fall through to false
    if (kDebugMode) debugPrint('isAndroidTv detection error: $e');
  }
  return false;
}