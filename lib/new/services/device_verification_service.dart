import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DeviceIdService {
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  static const String _cachedDeviceIdKey = 'cached_device_id';

  /// Get unique device identifier
  Future<String> getDeviceId() async {
    try {
      // Check if we have cached device ID first
      String? cachedId = await _secureStorage.read(key: _cachedDeviceIdKey);
      if (cachedId != null && cachedId.isNotEmpty) {
        print('📱 Using cached device ID: $cachedId');
        return cachedId;
      }

      String deviceId = '';

      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await _deviceInfo.androidInfo;
        // Use Android ID as unique identifier
        deviceId = androidInfo.id ?? '';

        // For additional uniqueness, you can combine with other identifiers
        if (deviceId.isEmpty) {
          deviceId = 'android_${androidInfo.device}_${androidInfo.model}';
        }
        print('📱 Android device ID: $deviceId');

      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await _deviceInfo.iosInfo;
        // Use identifierForVendor for iOS
        deviceId = iosInfo.identifierForVendor ?? '';

        if (deviceId.isEmpty) {
          deviceId = 'ios_${iosInfo.name}_${iosInfo.model}';
        }
        print('📱 iOS device ID: $deviceId');

      } else if (kIsWeb) {
        // For web, create a persistent ID using localStorage
        deviceId = await _getWebDeviceId();
        print('🌐 Web device ID: $deviceId');

      } else {
        // Fallback for other platforms
        deviceId = '${Platform.operatingSystem}_${DateTime.now().millisecondsSinceEpoch}';
        print('📱 Other platform device ID: $deviceId');
      }

      // Cache the device ID for future use
      if (deviceId.isNotEmpty) {
        await _secureStorage.write(key: _cachedDeviceIdKey, value: deviceId);
      }

      return deviceId;
    } catch (e) {
      print('💥 Error getting device ID: $e');
      return '';
    }
  }

  /// Get web device fingerprint
  Future<String> _getWebDeviceId() async {
    String? deviceId = await _secureStorage.read(key: _cachedDeviceIdKey);

    if (deviceId == null || deviceId.isEmpty) {
      // Generate a unique ID for web
      deviceId = _generateWebDeviceId();
      await _secureStorage.write(key: _cachedDeviceIdKey, value: deviceId);
    }

    return deviceId;
  }

  String _generateWebDeviceId() {
    // Generate a unique ID based on browser properties
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = timestamp.toString();
    return 'web_$random';
  }

  /// Clear cached device ID (useful for testing)
  Future<void> clearCachedDeviceId() async {
    await _secureStorage.delete(key: _cachedDeviceIdKey);
    print('🗑️ Cached device ID cleared');
  }
}