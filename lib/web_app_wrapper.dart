import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebappWrapper extends StatefulWidget {
  final String url;

  const WebappWrapper({required this.url, Key? key}) : super(key: key);

  @override
  State<WebappWrapper> createState() => _WebappWrapperState();
}

class _WebappWrapperState extends State<WebappWrapper> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    // This is required to ensure the platform interface is initialized
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Demo App")),
      body: WebViewWidget(controller: _controller),
    );
  }
}