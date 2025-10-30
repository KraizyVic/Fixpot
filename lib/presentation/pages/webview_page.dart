import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';


class WebviewPage extends StatefulWidget {
  final String? gateway;
  final String? ipAddress;
  final String testPage;

  const WebviewPage({super.key, this.gateway, this.ipAddress, required this.testPage});

  @override
  State<WebviewPage> createState() => _WebviewPageState();
}

class _WebviewPageState extends State<WebviewPage> {

  WebViewController? _controller;
  var loadProgress = 0;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  Future<void> _initWebView() async {
    // Clear cache and cookies before creating the controller
    await _controller?.clearCache();
    await WebViewCookieManager().clearCookies();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() => loadProgress = progress);
          },
          onPageStarted: (String url) {
            setState(() => loadProgress = 0);
          },
          onPageFinished: (String url) {
            setState(() => loadProgress = 100);
          },
        ),
      )
      ..setUserAgent(
        'Mozilla/5.0 (Linux; Android 9; SmartTV) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Safari/537.36',
      )
      ..enableZoom(true)
      ..loadRequest(
        Uri.parse(
          widget.gateway != null ? "http://${widget.gateway == "0.0.0.0" ? "8.8.8.8" : widget.gateway}" : widget.ipAddress != null ? "http://${widget.ipAddress}" : widget.testPage,
        ),
      );
  }

  Future<bool> _handleBack() async {
    if (_controller != null) {
      if (await _controller!.canGoBack()) {
        _controller?.goBack();
        return false; // stay in the page
      }
    }
    return true; // exit if no more history
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop,object) async {
        if (didPop) return;
        final shouldPop = await _handleBack();
        if (shouldPop) Navigator.of(context).pop();
      },
      child: Scaffold(
        /*appBar: AppBar(
          title: const Text("WebView"),
          centerTitle: true,
        ),*/
        body: SafeArea(
          child: Column(
            children: [
              loadProgress < 100 ?LinearProgressIndicator(value: loadProgress/100,) : SizedBox(),
              Expanded(
                child: WebViewWidget(
                    controller: _controller!,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
