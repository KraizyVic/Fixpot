import 'package:http/http.dart' as http;

class PortalDetector {
  /// Tries to check if there's a captive portal redirect
  Future<String?> checkForPortal() async {
    const testUrl = 'http://clients3.google.com/generate_204';
    try {
      final response = await http.get(
        Uri.parse(testUrl),
        headers: {'User-Agent': 'Mozilla/5.0'},
      );

      // If it's a normal internet connection, Google returns 204 No Content
      if (response.statusCode == 204) {
        print("Internet is good");
        return null; // No redirect, internet is good
      }

      // If we get redirected, response.redirects will contain that info
      if (response.isRedirect || response.statusCode == 302 || response.statusCode == 301) {
        final redirectUrl = response.headers['location'];
        print("Redirected to $redirectUrl");
        return redirectUrl;
      }

      // Some networks return 200 OK with a custom login HTML instead of redirect
      // So check the body content
      if (response.statusCode == 200 && response.body.contains("login")) {
        print("Redirected to login page");
        return response.request?.url.toString();
      }

      print("Unknown redirect");
      return null;
    } catch (e) {
      print("Error detecting portal: $e");
      return null;
    }
  }
}
