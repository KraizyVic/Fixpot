
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

/// DownloadService downloads the APK to external storage and reports progress.
/// It supports cancellation via a callback checked inside the onReceiveProgress loop.
class DownloadService {
  final Dio _dio = Dio();

  /// downloadApk - downloads url to external storage as update.apk
  /// onProgress receives a double 0.0..1.0, isCancelled checks if cancel was requested.
  Future<String> downloadApk(String url, Function(double) onProgress, Function() isCancelled) async {
    final dir = await getExternalStorageDirectory(); // external storage directory
    final filePath = '${dir!.path}/update.apk';

    // remove existing file if any
    final f = File(filePath);
    if (await f.exists()) {
      await f.delete();
    }

    // This uses Dio download which reports progress in bytes.
    try {
      await _dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (isCancelled()) {
            // If cancel requested, throw to stop download.
            throw Exception('cancelled');
          }
          if (total != -1) {
            onProgress(received / total);
          }
        },
        options: Options(receiveTimeout: Duration(seconds: 0), sendTimeout: Duration(seconds: 0)),
      );
      return filePath;
    } catch (e) {
      // cleanup partial file on error
      if (await f.exists()) {
        await f.delete();
      }
      rethrow;
    }
  }
}
