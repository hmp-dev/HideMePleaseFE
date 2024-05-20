import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:mobile/features/common/presentation/views/base_scaffold.dart';

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key, required this.title, required this.url});

  final String title;
  final String url;

  static push({
    required BuildContext context,
    required String title,
    required String url,
  }) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WebViewScreen(
          title: title,
          url: url,
        ),
      ),
    );
  }

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: widget.title,
      isCenterTitle: true,
      onBack: () {
        Navigator.pop(context);
      },
      body: InAppWebView(
        initialData: InAppWebViewInitialData(
          data: """
      <!DOCTYPE html><html>
      <head><title>WebPage to Redeem Free NFT Reward</title>
      <style>
        body {
          display: flex;
          justify-content: center;
          align-items: center;
          height: 100vh;
          flex-direction: column;
          margin: 0;
          padding: 0;
          box-sizing: border-box;
        }
      </style>
      </head>
      <body>
      <H1>WebPage to Redeem Free NFT Reward</H1>
      <p> URL is${widget.url}</p></body>
      </html>
    """,
        ),
        initialUrlRequest: URLRequest(
          url: WebUri.uri(Uri.parse(widget.url)),
        ),
      ),
    );
  }
}
