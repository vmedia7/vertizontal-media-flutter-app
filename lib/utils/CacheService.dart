import 'dart:async';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:path_provider/path_provider.dart';

Future<void> clearAllCache() async {
  try {
    print('Trying to clear cache folder.');
    final tempDir = await getTemporaryDirectory();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  } catch (e) {
    print('Error clearing cache folder: $e');
  }
}

Future<void> initializeCacheClearService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    iosConfiguration: IosConfiguration(
      /*
      autoStart: false,
      onForeground: onStart,
      onBackground: onIosBackground,
      */
    ),
    androidConfiguration: AndroidConfiguration(
      autoStart: false,
      onStart: onStart,
      isForegroundMode: false,
      autoStartOnBoot: false,
    ),
  );
}

@pragma('vm:entry-point')
Future<void> onStart(ServiceInstance service) async {
  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  Timer periodicTimer = Timer.periodic(Duration(milliseconds: 10), (timer) {
    clearAllCache();
  });

  Timer(Duration(seconds: 60 * 5), () {
    periodicTimer.cancel();
    service.stopSelf();
    print("ClearCache Service stopped after 300 seconds");
  });
}


Future<void> stopBackgroundService() async {
  final service = FlutterBackgroundService();
  if (await service.isRunning()) {
    service.invoke("stopService");
  }
}

Future<void> runBackgroundService() async {
  final service = FlutterBackgroundService();
  if (! (await service.isRunning())) {
    service.startService();
  }
}
