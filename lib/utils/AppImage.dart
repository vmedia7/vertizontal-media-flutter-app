import 'dart:typed_data';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

import './AppState.dart';

class AppImage extends StatefulWidget {
  final String path;

  final double? width;
  final double? height;
  final Color? color;

  const AppImage({
    Key? key,
    required this.path,
    this.width,
    this.height,
    this.color,
  }) : super(key: key);

  @override
  _AppImageState createState() => _AppImageState();
}

class _AppImageState extends State<AppImage> {
  Future<Uint8List>? _futureBytes;

  Future<Uint8List> _loadImage(String path, String loadedState) async {
    final AppImageCache imageCache = AppImageCache();
    if (loadedState == "assets") {
      final assetPath = "assets${path}";
      print("Loading image from assets folder ${assetPath}");
      ByteData byteData = await rootBundle.load("${assetPath}");
      final data = byteData.buffer.asUint8List();
      await imageCache.writeImageToCache(path, data);
      return data;
    }

    try {
      print("Loading Image from cache folder ${path}");
      final bytes = await imageCache.readImageFromCache(path);
      return bytes;

    } catch (e) {
      print('Loading from cache failed, now loading image from network');

      final response = await http.get(Uri.parse(
          "https://777.vertizontalmedia.com/${path}"
      ));
      if (response.statusCode == 200) {

        final Uint8List responseBytes = response.bodyBytes;
        await imageCache.writeImageToCache(path, responseBytes);
        return responseBytes;

      } else {
        throw Exception(
          'Failed to load image, status code: ${response.statusCode}'
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    _futureBytes ??= _loadImage(
      this.widget.path,
      AppStateScope.of(context).loaded!
    );

    return FutureBuilder<Uint8List>(
      future: _futureBytes,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            width: widget.width ?? 24,
            height: widget.height ?? 24,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );

        } else if (snapshot.hasError) {
          print(snapshot.error);
          return Icon(
            Icons.error,
            size: (widget.width != null && widget.height != null)
              ? min(widget.width!, widget.height!)
              : 24,
            color: Colors.red,
          );

        } else if (snapshot.hasData) {
          return Image.memory(
            snapshot.data!,
            width: widget.width,
            height: widget.height,
            color: widget.color,
          );
        }

        else {
          return Icon(
            Icons.info,
            size: (widget.width != null && widget.height != null)
              ? min(widget.width!, widget.height!)
              : 24,
            color: Colors.red,
          );
        }
      },
    );
  }
}

class AppImageCache {
  // Get cache directory path
  Future<String> get _localPath async {
    final directory = await getTemporaryDirectory();
    return directory.path;
  }

  // Read image bytes from cache as Uint8List
  Future<Uint8List> readImageFromCache(String path) async {
    final String localPath = await _localPath;
    final newPath = path.replaceAll('/', '.');
    final file = File('$localPath/${newPath}');
    print(file);
    return await file.readAsBytes();
  }

  // Write image bytes (Uint8List) to cache file
  Future<File> writeImageToCache(String path, Uint8List bytes) async {
    final String localPath = await _localPath;
    final newPath = path.replaceAll('/', '.');
    final file = File('$localPath/${newPath}');
    return await file.writeAsBytes(bytes, flush: true);
  }
}

