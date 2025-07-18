import 'package:flutter/material.dart';

// Local Libraries
import 'package:raptureready/utils/AppState.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  Widget build(BuildContext context) {
    final Map<String, dynamic> appLayout = AppStateScope.of(context).appLayout;
    return ListView(
      children: <Widget>[
        for (var section in appLayout['tabs'].last['sections']!)
        Card(
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
      ],
    );
  }
}
