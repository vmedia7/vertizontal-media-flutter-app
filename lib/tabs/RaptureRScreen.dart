import 'package:flutter/material.dart';

class RaptureRScreen extends StatelessWidget {
  const RaptureRScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Center(
      child: Card(
        shadowColor: Colors.transparent,
        margin: const EdgeInsets.all(8.0),
        child: SizedBox.expand(
          child: Center(
            child: Text(
              'Rapture R page',
              style: theme.textTheme.titleLarge
            ),
          ),
        ),
      )
    );
  }
}
