import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;

// Local Libraries
import 'package:raptureready/utils/AppState.dart';
import 'package:raptureready/utils/WebView.dart';
import 'package:raptureready/utils/AppLayoutCache.dart';
import 'package:raptureready/utils/Color.dart';

import 'package:raptureready/tabs/HomeScreen.dart';
import 'package:raptureready/tabs/MoreScreen.dart';

void main() {
  runApp(AppStateWidget(
    appLayout: {},
    loaded: null,
    child: const MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  Future<Map<String, dynamic>> loadAppLayoutFromLocal() async {
    // Read first rrom Cache and then Assets
    try {
      print('Loading layout from cache');
      Map<String, dynamic> appLayout = (
        await AppLayoutCache().readJsonFromCache()
      );

      return appLayout;

    } catch (e) {
      print('Loading layout from assets');
      String jsonString = await rootBundle.loadString('assets/appLayout.json');
      return jsonDecode(jsonString);
    }
  }

  Future<Map<String, dynamic>> loadAppLayoutFromNetwork() async {
    final response = await http.get(
      Uri.parse('https://app.eternityready.com/data'),
    );

    throw Exception('Failed to load Network Request');

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load Network Request');
    }
  }

  Future<void> _initAsync() async {
    final localLayout = await loadAppLayoutFromLocal();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      AppStateWidget.of(context).setAppState(localLayout, "local");

      final networkLayout = await loadAppLayoutFromNetwork();
      final firstTab = localLayout['tabs'][0];
      firstTab['sections'] = networkLayout['data']['sections'];

      AppStateWidget.of(context).setAppState(localLayout, "network");
      await AppLayoutCache().writeJsonToCache(localLayout);
    });
  }

  @override
  void initState() {
    super.initState();
    _initAsync();
  }

  @override
  Widget build(BuildContext context) {
    final AppState appState = AppStateScope.of(context);
    if (appState.loaded == null) {
      return Center(child: CircularProgressIndicator());
    }

    return MaterialApp(
      title: 'RaptureReady',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: HexColor.fromHex(
            appState.appLayout['globalTheme']['color']!
          )
        ),
      ),
      home: AppNavigation()
    );
  }
}

class AppNavigation extends StatefulWidget {
  const AppNavigation({super.key});

  @override
  State<AppNavigation> createState() => _AppNavigationState();
}

class _AppNavigationState extends State<AppNavigation> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> appLayout = AppStateScope.of(context).appLayout;
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(appLayout['tabs'][currentPageIndex]['text']! as String),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),

      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: HexColor.fromHex(
                          appLayout['tabs'][currentPageIndex]['color']
                        ),
        selectedIndex: currentPageIndex,
        destinations: <Widget>[
          for (var tab in appLayout?['tabs'])
            NavigationDestination(
              selectedIcon: Image.asset(
                "assets${tab?['icon']}",
                width: 24,
                height: 24,
              ),
              icon: Image.asset(
                "assets${tab?['icon']}",
                width: 24,
                height: 24,
              ),
              label: tab?['text'],
            ),
        ],
      ),
      body:
          (() {
            final String link = appLayout['tabs'][currentPageIndex]['link']!;
            if (link.startsWith('http')) {
                return WebView(
                  key: ValueKey(link),
                  url: link,
                );
            } else if (link == "#") {
              return HomeScreen();
            } else if (link == "more") {
              return MoreScreen();
            }
          })()
    );
  }
}


