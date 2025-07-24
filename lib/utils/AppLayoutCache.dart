import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class AppLayoutCache {

  // Get cache directory path
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  // Reference to the JSON file
  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/appLayoutCache.json');
  }

  // Read JSON from cache
  Future<Map<String, dynamic>> readJsonFromCache() async {
    final file = await _localFile;
    final contents = await file.readAsString();
    return jsonDecode(contents) as Map<String, dynamic>;
  }

  // Write JSON to cache
  Future<File> writeJsonToCache(Map<String, dynamic> jsonData) async {
    final file = await _localFile;
    return file.writeAsString(jsonEncode(jsonData));
  }
}
