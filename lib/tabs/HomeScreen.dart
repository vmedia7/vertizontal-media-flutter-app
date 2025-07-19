import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:raptureready/utils/WebView.dart';
import 'package:raptureready/utils/AppState.dart';

Future<HomeLayout> fetchHomeLayout() async {
  final response = await http.get(
    Uri.parse('https://app.eternityready.com/data'),
  );

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return HomeLayout.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>
    );
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load Home Layout');
  }
}

class HomeLayout {
  final bool status;
  final String message;
  final Map<String, dynamic> data;

  const HomeLayout({
    required this.status,
    required this.message,
    required this.data
  });

  factory HomeLayout.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'status': bool status,
        'message': String message,
        'data': Map<String, dynamic> data
      } => HomeLayout(
          status: status,
          message: message,
          data: data,
        ),
        _ => throw const FormatException('Failed to load Home Layout.'),
    };
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<HomeLayout> futureHomeLayout;

  String? _url;

  void _handleLinkClicked(String linkUrl) {
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
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> appLayout = AppStateScope.of(context).appLayout;
    return Center(
      child: (() {
        if (_url == null) {
          return HomeLayoutWidget(
            data: appLayout['tabs'][0]!,
            handleLinkClicked: _handleLinkClicked,
          );
        }
        else {
          return WebView(url: _url!, customLastGoBack: customLastGoBack);
        }
      })()
    );
  }
}

class MatrixCell {
  final String name;
  final String value;

  MatrixCell({
    required this.name,
    required this.value,
  });
}

class HomeLayoutWidget extends StatelessWidget {
  Map<String, dynamic> data;
  final void Function(String) handleLinkClicked;

  HomeLayoutWidget({
    super.key,
    required this.data,
    required this.handleLinkClicked,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        for (var section in data['sections']) DynamicGrid(
          data: flatToMatrix(section['buttons']!),
          header: section["title"],
          handleLinkClicked: handleLinkClicked,
        )
      ]
    );
  }

  List<List<dynamic>> flatToMatrix(List<dynamic> buttons) {
    int rows = sqrt(buttons.length).toInt();
    int columns = (buttons.length / rows).toInt();
    List<List<dynamic>> matrix = [];
    List<dynamic> current = [];
    int current_idx = 0;

    for (var row = 0; row < rows; row++) {
      for (var column = 0; column < columns; column++) {
        current.add(buttons[current_idx]);
        current_idx += 1;
      }
      matrix.add(current);
      current = [];
    }
    return matrix;
  }
}

class DynamicGrid extends StatelessWidget {
  final List<List<dynamic>> data;
  final String header;
  final void Function(String) handleLinkClicked;

  DynamicGrid({
    required this.data,
    required this.header,
    required this.handleLinkClicked,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    int rows = data.length;
    int columns = data.isNotEmpty ? data[0].length : 0;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IntrinsicWidth(
                  child: Column(
                    children: [
                      Text(
                        header,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Container(
                        height: 3,
                        color: theme.primaryColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          GridView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              childAspectRatio: 1.5,
            ),
            itemCount: rows * columns,
            itemBuilder: (context, index) {
              int row = index ~/ columns;
              int col = index % columns;
              return GridCellWidget(
                gridCell: data[row][col],
                handleLinkClicked: handleLinkClicked
              );
            },
          ),
        ],
      ),
    );
  }
}

class GridCellWidget extends StatelessWidget {
  dynamic gridCell;
  final void Function(String) handleLinkClicked;

  GridCellWidget({
    required this.gridCell,
    required this.handleLinkClicked,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        handleLinkClicked(gridCell['link']);
      },
      child: Container(
        margin: EdgeInsets.all(4.0),
        /*
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8.0),
        ),
        */
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                constraints: BoxConstraints(
                  maxHeight: 60,
                  maxWidth: 60,
                ),
                child: FractionallySizedBox(
                  widthFactor: 0.5,
                  heightFactor: 0.5,
                  child: Image.network(
                    "https://app.eternityready.com/${gridCell['icon']}",
                  ),
                ),
              ),
              Text(
                gridCell['text'].toString(),
                style: TextStyle(fontSize: 12),
              ),
            ]
          )
        ),
      )
    );
  }
}
