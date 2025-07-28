import 'package:flutter_inappwebview/flutter_inappwebview.dart';

// Declare a global list to hold WebViewControllers
List<GlobalWebViewController> webViewControllers = [];

class GlobalWebViewController {
  final InAppWebViewController? controller;
  final void Function()? customLastGoBack;

  GlobalWebViewController({this.controller, this.customLastGoBack});
}
