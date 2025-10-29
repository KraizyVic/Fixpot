import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';


class WebviewPage extends StatefulWidget {
  final String? gateway;
  final String? ipAddress;
  const WebviewPage({super.key, required this.gateway, required this.ipAddress});

  @override
  State<WebviewPage> createState() => _WebviewPageState();
}

class _WebviewPageState extends State<WebviewPage> {

  late WebViewController _controller;
  var loadProgress = 0;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
    ..setNavigationDelegate(NavigationDelegate(
      onProgress: (int progress) {
        // Update loading bar.
        setState(() {
          loadProgress = progress;
        });
      },
      onPageStarted: (String url) {
        setState(() {
          loadProgress = 0;
        });
      },
      onPageFinished: (String url) {
        setState(() {
          loadProgress = 100;
        });
      },
      onWebResourceError: (WebResourceError error) {},
    ))..loadRequest(Uri.parse("http://8.8.8.8"))..setJavaScriptMode(JavaScriptMode.unrestricted);
  }

  Future<bool> _handleBack() async {
    if (await _controller.canGoBack()) {
      _controller.goBack();
      return false; // stay in the page
    }
    return true; // exit if no more history
  }

  @override
  Widget build(BuildContext context) {
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
                    controller: _controller,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
