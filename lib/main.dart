import 'package:flutter/material.dart';

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
      home: DefaultTabController(
        length: 5,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Rapture Ready Tabs'),
          ),
          bottomNavigationBar: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.home_filled)),
                Tab(icon: Icon(Icons.people_alt)),
                Tab(icon: Icon(Icons.tv)),
                Tab(icon: Icon(Icons.radio)),
                Tab(icon: Icon(Icons.more_horiz)),
              ],
            ),

          body: const TabBarView(
            children: [
              Icon(Icons.home_filled),
              Icon(Icons.people_alt),
              Icon(Icons.tv),
              Icon(Icons.radio),
              Icon(Icons.more_horiz),
            ],
          ),
        ),
      ),
    );
  }
}
