import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
// Local Libraries
import 'package:raptureready/utils/AppState.dart';
import 'package:raptureready/utils/WebView.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  String? _url;

  void _handleLinkClicked(String? linkUrl, String? android, String? ios) async {
    if (linkUrl == null) {
      return;
    }

    if (linkUrl == "ACTION_SEND") {
      await SharePlus.instance.share(
        ShareParams(text: Platform.isAndroid ? android : ios)
      );
      return;
    }

    if (!linkUrl.startsWith("http")) {
      return;
    }

    setState(() {
      _url = linkUrl;
    });
  }

  void customLastGoBack() {
    setState(() {
      _url = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_url != null) {
      return WebView(
        url: _url!,
        customLastGoBack: customLastGoBack,
        key: ValueKey(_url)
      );
    }

    final Map<String, dynamic> appLayout = AppStateScope.of(context).appLayout;
    return ListView(
      children: <Widget>[
        for (var section in appLayout['tabs'].last['sections']!)
        Card(
          child: GestureDetector(
           onTap: () {
              _handleLinkClicked(section?['link'], section?['android'], section?['ios']);
            },
            child: ListTile(
              leading: Image.asset(
                "assets${section?['icon']}",
                width: 24,
                height: 24,
              ),
              title: Text(section['text']!),
              trailing: Icon(Icons.chevron_right),
            ),
          ),
        ),
      ],
    );
  }
}
