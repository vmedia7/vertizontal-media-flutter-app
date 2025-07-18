import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

// Local Libraries
import 'package:raptureready/utils/AppState.dart';

import 'package:raptureready/tabs/HomeScreen.dart';
import 'package:raptureready/tabs/RaptureRScreen.dart';
import 'package:raptureready/tabs/TvScreen.dart';
import 'package:raptureready/tabs/RadioScreen.dart';
import 'package:raptureready/tabs/MoreScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Map<String, dynamic>> loadAppLayoutJson() async {
    String jsonString = await rootBundle.loadString('assets/appLayout.json');
    return jsonDecode(jsonString);
  }


  @override
  Widget build(BuildContext context) {
    print('Executing lol');
    return FutureBuilder<Map<String, dynamic>>(
      future: loadAppLayoutJson(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error loading layout'));
        } else {
          final appLayout = snapshot.data!;
          return AppStateWidget(
            appLayout: snapshot.data!,
            child: MaterialApp(
              title: 'RaptureReady',
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              ),
              home: AppNavigation()
            )
          );
        }
      },
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

  var tabs = [
    {
      'title': 'Home',
      'screen': HomeScreen(),
    },
    {
      'title': 'Rapture R',
      'screen': RaptureRScreen(),
    },
    {
      'title': 'TV',
      'screen': TvScreen(),
    },
    {
      'title': 'Radio',
      'screen': RadioScreen(),
    },
    {
      'title': 'More',
      'screen': MoreScreen(),
    }
  ];

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> appLayout = AppStateScope.of(context).appLayout;
    print('HELLO');
    print(appLayout);
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(tabs[currentPageIndex]['title']! as String),
      ),

      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: Colors.deepPurple,
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
          <Widget>[
            for (var tab in tabs) tab['screen'] as Widget
          ][currentPageIndex],
    );
  }
}


