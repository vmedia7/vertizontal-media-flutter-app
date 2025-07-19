import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:raptureready/utils/AppLayoutCache.dart';

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

  void _handleLinkClicked(String? linkUrl, String? android, String? ios, BuildContext context) async {
    if (linkUrl == null) {
      return;
    }

    if (linkUrl == "ACTION_SEND") {
      await SharePlus.instance.share(
        ShareParams(text: Platform.isAndroid ? android : ios)
      );
      return;
    }

    if (linkUrl == "ACTION_VIEW") {
      await launchUrl(
        Uri.parse((Platform.isAndroid ? android : ios) ?? "https://eternityready.com"),
        mode: LaunchMode.externalApplication
      );
      return;
    }

    if (linkUrl == "ACTION_THEME") {
      final selectedColor = await showColorPickerDialog(context);
      final AppState appState = AppStateScope.of(context);
      final Map<String, dynamic> appLayout = {
        ...appState.appLayout,
        "globalTheme": {
          ...appState.appLayout['globalTheme']!,
          'color': selectedColor
        }
      };

      await AppLayoutCache().writeJsonToCache(appLayout);
      AppStateWidget.of(context).setAppState(appLayout, appState.loaded!);
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

  Future<String?> showColorPickerDialog(BuildContext context) async {
    final colors = <String> [
        "FF263238",
        "FF212121",
        "FF3E2723",
        "FFBF360C",
        "FFE65100",
        "FFFF6D00",
        "FF33691E",
        "FF1B5E20",
        "FF004D40",
        "FF006064",
        "FF01579B",
        "FF0D47A1",
        "FF2962FF",
        "FF1A237E",
        "FF311B92",
        "FF880E4F",
        "FFB71C1C",
    ];

    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Choose a color'),
          content: SingleChildScrollView(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final color in colors)
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(color),
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Color(int.parse(color, radix: 16)),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black12),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
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
              _handleLinkClicked(section?['link'], section?['android'], section?['ios'], context);
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
