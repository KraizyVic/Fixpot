
import 'dart:convert';
import 'package:http/http.dart' as http;

/// Simple service that checks GitHub Releases for the latest release info.
/// It returns a Map with 'version', 'changelog', and 'apkUrl' (if an .apk asset exists).
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

class UpdateService {
  final String repoOwner;
  final String repoName;

  UpdateService({required this.repoOwner, required this.repoName});

  /// Detects the ABI (CPU architecture) of the device.
  Future<String> _getDeviceAbi() async {
    if (!Platform.isAndroid) return 'universal';

    final info = await DeviceInfoPlugin().androidInfo;
    return info.supportedAbis.first; // e.g. "armeabi-v7a"
  }

  /// Check for update on GitHub and return details (version, changelog, apkUrl)
  Future<Map<String, dynamic>?> checkForUpdate() async {
    final abi = await _getDeviceAbi();
    print('🧠 Detected ABI: $abi');

    final url = Uri.parse('https://api.github.com/repos/$repoOwner/$repoName/releases/latest');
    final res = await http.get(url);

    if (res.statusCode != 200) return null;

    final data = json.decode(res.body);
    final assets = (data['assets'] as List<dynamic>? ) ?? [];

    String? apkUrl;

    // Try to find the matching ABI APK
    for (final a in assets) {
      final name = a['name']?.toString().toLowerCase() ?? '';

      if (abi.contains('armeabi-v7a') && name.contains('armeabi-v7a')) {
        apkUrl = a['browser_download_url'];
        break;
      } else if (abi.contains('arm64-v8a') && name.contains('arm64-v8a')) {
        apkUrl = a['browser_download_url'];
        break;
      } else if (abi.contains('x86_64') && name.contains('x86_64')) {
        apkUrl = a['browser_download_url'];
        break;
      }
    }

    // If none matched, fallback to universal (or main) APK
    apkUrl ??= assets
        .firstWhere(
          (a) => (a['name']?.toString() ?? '').endsWith('.apk'),
      orElse: () => null,
    )?['browser_download_url'];

    return {
      'version': data['tag_name'],
      'changelog': data['body'],
      'apkUrl': apkUrl,
    };
  }
}
