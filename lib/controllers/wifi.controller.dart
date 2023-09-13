import 'package:flutter/services.dart';

class WifiController {
  final platform = const MethodChannel('com.example.poc_inova/wifi');

  Future<void> connectToHardwareWiFi({
    required String ssid,
    required String pass,
  }) async {
    try {
      final result = await platform.invokeMethod('connectToWiFi', {
        "ssid": ssid,
        "pass": pass,
      });
      print('Connection successful: $result');
    } on PlatformException catch (e) {
      print('Connection failed: ${e.message}');
    }
  }

  Future<void> disconnectToHardwareWiFi() async {
    try {
      final result = await platform.invokeMethod('disconnectToWifi');
      print('Disconnection successful: $result');
    } on PlatformException catch (e) {
      print('Disconnection failed: ${e.message}');
    }
  }
}
