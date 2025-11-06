import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../data/data_source/time_sync_service.dart';


class WebviewPage extends StatefulWidget {
  final String? gateway;
  final String? ipAddress;
  final String testPage;
  final DateTime? fetchedDate;


  const WebviewPage({super.key, this.gateway, this.ipAddress, required this.testPage, this.fetchedDate});

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
    // clear previous controller state (if any)
    await _controller?.clearCache();
    await WebViewCookieManager().clearCookies();

    // Use provided fetchedDate or fallback to now (UTC)
    final DateTime fetchedDate = (widget.fetchedDate ?? DateTime.now()).toUtc();

    // Ensure target has scheme
    final String targetUrl = widget.gateway != null ? "http://${widget.gateway == "0.0.0.0" ? "8.8.8.8" : widget.gateway}" : widget.ipAddress != null
        ? "http://${widget.ipAddress}" : widget.testPage; // <- use https for generic fallback

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) => setState(() => loadProgress = progress),
          onPageStarted: (String url) => setState(() => loadProgress = 0),
          onPageFinished: (String url) async {
            setState(() => loadProgress = 100);

            // inject ISO date for page JS (safe to parse with new Date(...))
            final iso = fetchedDate.toIso8601String();
            final js = """
            (function(){
              try {
                window.deviceTime = "$iso";
                console.log("Device time injected:", window.deviceTime);
              } catch(e) {
                console.error("JS inject failed:", e);
              }
            })();
          """;

            try {
              await _controller?.runJavaScript(js);
            } catch (e) {
              // swallow or log — don't crash the UI
              debugPrint('runJavaScript failed: $e');
            }
          },
        ),
      )
      ..setUserAgent(
        'Mozilla/5.0 (Linux; Android 9; SmartTV) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Safari/537.36',
      )
      ..enableZoom(true)
      ..loadRequest(
        Uri.parse(targetUrl),
        headers: <String, String>{
          'X-Device-Date': HttpDate.format(fetchedDate), // RFC1123 for headers
          'Cache-Control': 'no-cache',
        },
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
        if(context.mounted){
          if (shouldPop) Navigator.of(context).pop();
        }
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
