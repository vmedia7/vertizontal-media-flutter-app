import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';


// Local Libraries
import 'utils/AppState.dart';
import 'utils/WebView.dart';
import 'utils/AppLayoutCache.dart';
import 'utils/Color.dart';
import 'utils/AppImage.dart';
import 'utils/NotificationService.dart';
import 'utils/Constants.dart';
import 'utils/LayoutLoaders.dart';
import 'utils/GlobalControllers.dart';

import 'tabs/HomeScreen.dart';
import 'tabs/MoreScreen.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);


  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await NotificationService.instance.initialize();

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

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  Future<void> _initAsync() async {
    Map<String, dynamic> localLayout;
    String loaded;

    try {
      localLayout = await loadAppLayoutFromCache();
      loaded = "cache";
    } catch (e) {
      localLayout = await loadAppLayoutFromAssets();
      loaded = "assets";
    }

    AppStateWidget.of(context).setAppState(localLayout, loaded);
    FlutterNativeSplash.remove();

    
    // Do background network work, update afterwards
    final networkLayout = await loadAppLayoutFromNetwork();
    final firstTab = localLayout['tabs'][0];
    for (int idx = 0; idx < networkLayout['data']['sections'].length; idx++) {
      networkLayout['data']['sections'][idx] = {
        ...networkLayout['data']['sections'][idx],
        "underlineColor": "#0066ff",
      };
    }

    firstTab['sections'] = networkLayout['data']['sections'];

    localLayout['tabs'] = [
      for (var tab in localLayout['tabs'])
        if (
          tab['text']!.toLowerCase() == "home" ||
          tab['text']!.toLowerCase() == "more"
          ) tab
    ];
    print(localLayout['tabs']);

    var insertAt = 0;
    for (int idx = 0; idx < networkLayout['data']['bottomNav'].length; idx++) {
      var networkTab = networkLayout['data']['bottomNav'][idx]!;
      if (networkTab['text'].toLowerCase() == "home") {
        continue;
      }

      localLayout['tabs'].insert(insertAt + 1, {
        ...networkTab,
        'color': "#0066ff",
      });
      insertAt += 1;
    }

    AppStateWidget.of(context).setAppState(localLayout, "network");
    await AppLayoutCache().writeJsonToCache(localLayout);
  }


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _clearTemporaryCache();
    _initAsync();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
      state == AppLifecycleState.detached) {
      _clearTemporaryCache();
    }
  }

  Future<void> _clearTemporaryCache() async {
    print('Clearing cache');

    // Clear WebView cache on all controllers
    for (var controller in webViewControllers) {
      try {
        await controller.clearCache();
      } catch (e) {
        print('Error clearing WebView controller cache: $e');
      }
    }

    // Clear cookies globally
    try {
      await WebViewCookieManager().clearCookies();
    } catch (e) {
      print('Error clearing WebView cookies: $e');
    }

    // Clear the temp directory as before
    try {
      final tempDir = await getTemporaryDirectory();
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
        print('Temporary cache folder cleared.');
      }
    } catch (e) {
      print('Error clearing cache folder: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    final AppState appState = AppStateScope.of(context);
    if (appState.loaded == null) {
      return Center(child: CircularProgressIndicator());
    }
    print(appState.loaded);

    return MaterialApp(
      title: 'VertiZontal Media',
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
    final String loaded = AppStateScope.of(context).loaded!;
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
              selectedIcon: AppImage(
                path: tab['icon']!,
                width: 24,
                height: 24,
              ),
              icon: AppImage(
                path: tab['icon']!,
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


