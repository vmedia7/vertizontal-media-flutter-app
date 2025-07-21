import 'package:flutter/material.dart';
import '../utils/WebView.dart';

class RaptureRScreen extends StatelessWidget {
  const RaptureRScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const WebView(url: "https://www.raptureready.com/");
  }
}
