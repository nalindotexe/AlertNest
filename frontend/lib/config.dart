import 'package:flutter/foundation.dart';

class AppConfig {
  // Machine's local IP address so real Android devices can connect.
  static const String _localIp = '10.49.90.65'; 

  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8000'; // Default for local web dev
    }
    // For Android, 10.0.2.2 is usually the host machine in emulator.
    // However, for a real device, we need the actual local IP.
    return 'http://$_localIp:8000';
  }

  static String get wsUrl {
    if (kIsWeb) {
      return 'ws://localhost:8000/ws/'; // Default for local web dev
    }
    return 'ws://$_localIp:8000/ws/';
  }
}
