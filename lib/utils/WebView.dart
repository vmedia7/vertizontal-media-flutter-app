import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/services.dart';

import './GlobalControllers.dart';
import './AppState.dart';
import './Color.dart';

class WebView extends StatefulWidget {
  final String url;
  final void Function()? customLastGoBack;
  const WebView({ super.key, required this.url, this.customLastGoBack });

  @override
  State<WebView> createState() => _WebViewState();
}

class _WebViewState extends State<WebView> {
  var loadingPercentage = 0;
  Object? errorLoadingPage;
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (url) {
          setState(() {
            loadingPercentage = 0;
            print('Percentage in onPageStarted: $loadingPercentage');
          });
        },
        onProgress: (progress) {
          setState(() {
            loadingPercentage = progress;
            print('Percentage in loadingPercentage: $progress');
          });
        },
        onPageFinished: (url) {
          setState(() {
            loadingPercentage = 100;
          });
        },
        onHttpError: (HttpResponseError error) {
          print('HttpResponseError');
          print(error);
          /*
          setState(() {
            errorLoadingPage = error;
          });
          */
        },
        onWebResourceError: (WebResourceError error) {
          print('WebResourceError');
          print(error);
          if (error.isForMainFrame == true) {
            print('MainFrame Error');
            setState(() {
              errorLoadingPage = error;
            });
          }
        },
      ))
      ..loadRequest(
        Uri.parse(this.widget.url),
      );
    webViewControllers.add(controller);
  }

  @override
  Widget build(BuildContext context) {
    
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) {
          return;
        }

        final shouldPop = await controller.canGoBack();
        if (shouldPop) {
          await controller.goBack();
          return;
        }
        if (this.widget.customLastGoBack == null) {
          await SystemNavigator.pop();
          return;
        }

        this.widget.customLastGoBack?.call();
      },
      child: errorLoadingPage == null
      ? Stack(
          children: [
            WebViewWidget(
              controller: controller,
            ),
            if (loadingPercentage < 100)
              Center(
                child: CircularProgressIndicator()
              )
          ],
        )
      : _webviewErrorWidget(context)
    );
  }

  _webviewErrorWidget(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    String? errorMessage;
    if (errorLoadingPage is WebResourceError) {
      errorMessage = (errorLoadingPage as WebResourceError).description;
    } else if (errorLoadingPage is HttpResponseError) {
      errorMessage = (errorLoadingPage as HttpResponseError)
          .response?.statusCode.toString();
    } else {
      errorMessage = errorLoadingPage.toString();
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            double squareSize = constraints.maxWidth;

            return SingleChildScrollView(   // << wrap Column here
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: squareSize,
                    height: squareSize,
                    child: Image.asset(
                      'assets/icon/icon.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Looks Like there's a problem loading the corresponding page.",
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Try to reload again. Check your modem or router. Disconnect and reconnect to Wi-Fi.",
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Error Message: $errorMessage",
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 12),
                  ),

                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          errorLoadingPage = null;
                        });
                        controller.reload();
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      child: Text(
                        "Reload",
                        style: TextStyle(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
