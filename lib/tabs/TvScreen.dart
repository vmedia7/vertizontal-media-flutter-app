import 'package:flutter/material.dart';
import 'package:raptureready/utils/WebView.dart';

class TvScreen extends StatelessWidget {
  const TvScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const WebView(url: "https://eternityready.tv/live-tv");
  }
}

