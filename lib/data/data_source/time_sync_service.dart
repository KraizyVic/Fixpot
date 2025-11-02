
import 'dart:io';

class TimeSyncService {
  /// Fetches the HTTP Date header from a local device IP (or any HTTP URL).
  /// Returns a UTC DateTime or null on failure.
  static Future<DateTime?> fetchDateFromHttp(String ipOrUrl, {Duration timeout = const Duration(seconds: 5)}) async {
    try {
      final uri = Uri.parse(
        ipOrUrl.startsWith('http') ? ipOrUrl : 'http://$ipOrUrl/',
      );

      final client = HttpClient();
      client.connectionTimeout = timeout;

      final req = await client.getUrl(uri).timeout(timeout);
      final resp = await req.close().timeout(timeout);

      // Date header exists even on 404 responses on most servers/routers
      final dateHeader = resp.headers.value('date');
      await resp.drain(); // consume response
      client.close();
      if (dateHeader == null) return null;
      print('TimeSyncService date: $dateHeader');
      return HttpDate.parse(dateHeader).toUtc();
    } on Exception catch (e) {
      // timeout, socket error, parse error, etc.
      // print or log in debug only
      // print('TimeSyncService error: $e');
      return null;
    }
  }
}