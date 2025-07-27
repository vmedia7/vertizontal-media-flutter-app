/// Utility to load the App Layout JSON from Cache, Asset or Newtork

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;

import './AppLayoutCache.dart';
import '../global/Constants.dart';

/// Reads from cache using [AppLayoutCache]
Future<Map<String, dynamic>> loadAppLayoutFromCache() async {
  print('Loading layout from cache');
  Map<String, dynamic> appLayout = (
    await AppLayoutCache().readJsonFromCache()
  );
  return appLayout;
}

/// Reads from assets using [rootBundle]
Future<Map<String, dynamic>> loadAppLayoutFromAssets() async {
  print('Loading layout from assets');
  String jsonString = await rootBundle.loadString('assets/appLayout.json');
  return jsonDecode(jsonString);
}

/// Reads from network using [BACKEND_URL]
Future<Map<String, dynamic>> loadAppLayoutFromNetwork() async {
  print('Loading layout from network');
  final response = await http.get(Uri.parse('${BACKEND_URL}/data'));

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
