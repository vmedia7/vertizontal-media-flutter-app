import 'package:flutter/material.dart';

/*
   https://stackoverflow.com/questions/50081213/how-do-i-use-hexadecimal-color-strings-in-flutter
*/
extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    hexString = hexString.replaceFirst('#', '');

    if (hexString.length == 8) {
      buffer.write(hexString);
    }

    // RRGGBB -> FFRRGGBB
    if (hexString.length == 6) {
      buffer.write('FF');
      buffer.write(hexString);
    };

    // RGB -> FFRGB
    if (hexString.length == 3) {
      buffer.write('FF');
    }

    // Duplicate the hex
    if (hexString.length == 3 || hexString.length == 4) {
      for (int idx = 0; idx < hexString.length; idx++) {
        buffer.write(hexString[idx]);
        buffer.write(hexString[idx]);
      }
    }

    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `false`).
  String toHex({bool leadingHashSign = false}) => '${leadingHashSign ? '#' : ''}'
      '${(255 * a).toInt().toRadixString(16).padLeft(2, '0')}'
      '${(255 * r).toInt().toRadixString(16).padLeft(2, '0')}'
      '${(255 * g).toInt().toRadixString(16).padLeft(2, '0')}'
      '${(255 * b).toInt().toRadixString(16).padLeft(2, '0')}';
}
