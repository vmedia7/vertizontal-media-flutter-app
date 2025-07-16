import 'package:flutter/material.dart';

// Local Libraries
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

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RaptureReady',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
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
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rapture Ready Navigation'),
      ),

      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: Colors.deepPurple,
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home_filled),
            icon: Icon(Icons.home_filled),
            label: 'Home',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.people_alt),
            icon: Icon(Icons.people_alt),
            label: 'Rapture R',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.tv),
            icon: Icon(Icons.tv),
            label: 'TV',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.radio),
            icon: Icon(Icons.radio),
            label: 'Radio',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.more),
            icon: Icon(Icons.more),
            label: 'More',
          ),
        ],
      ),
      body:
          <Widget>[
            HomeScreen(),
            RaptureRScreen(),
            TvScreen(),
            RadioScreen(),
            MoreScreen()
          ][currentPageIndex],
    );
  }
}
