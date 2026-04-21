import 'dart:convert';
import 'package:http/http.dart' as http;

class CloudPasswordService {
  String? password;
  bool active = true;
  List<String> allowedDevices = []; // Add this to store allowed device IDs

  Future<void> fetch() async {
    print('🌐 [CloudPasswordService] Fetching password and devices from cloud...');

    try {
      // Fetch password from Sheet1
      await _fetchPassword();

      // Fetch allowed devices from Sheet2
      await _fetchAllowedDevices();

    } catch (e) {
      print('💥 Error fetching from cloud: $e');
      rethrow;
    }
  }

  // Fetch password and active status from Sheet1
  Future<void> _fetchPassword() async {
    final url = 'https://opensheet.elk.sh/16MJHlWklwAVGZrsNM5x2Uk7Xyi8F89VM-GpnjfkM-Cw/Sheet1';
    print('🔗 Request URL (Password): $url');

    try {
      final res = await http.get(Uri.parse(url));

      print('📥 Response status: ${res.statusCode}');
      print('📄 Raw response body: ${res.body}');

      if (res.statusCode == 200) {
        final data = json.decode(res.body)[0];
        print('🧩 Decoded JSON: $data');

        // Clean and normalize values
        password = data['password']?.toString().trim();
        final activeValue = data['active']?.toString().toLowerCase().trim();
        active = (activeValue == 'true' || activeValue == '1' || activeValue == 'yes');

        print('🔐 Password fetched: "$password"');
        print('🚦 Active status: $active');
      } else {
        print('❌ Failed to fetch password. HTTP ${res.statusCode}');
        throw Exception('Failed to fetch cloud password');
      }
    } catch (e) {
      print('💥 Error fetching password: $e');
      rethrow;
    }
  }

  // Fetch allowed device IDs from Sheet2
  Future<void> _fetchAllowedDevices() async {
    // Using the same spreadsheet ID but different sheet name: Sheet2
    final url = 'https://opensheet.elk.sh/16MJHlWklwAVGZrsNM5x2Uk7Xyi8F89VM-GpnjfkM-Cw/Sheet2';
    print('🔗 Request URL (Devices): $url');

    try {
      final res = await http.get(Uri.parse(url));

      print('📥 Device list response status: ${res.statusCode}');

      if (res.statusCode == 200) {
        final List<dynamic> data = json.decode(res.body);
        print('📱 Found ${data.length} devices in the list');

        // Extract device IDs from the sheet - FIXED VERSION
        allowedDevices = data
            .map((row) => row['device_id']?.toString().trim())
            .where((id) => id != null && id.isNotEmpty)
            .cast<String>()  // Add this to cast to non-nullable String
            .toList();

        print('✅ Loaded ${allowedDevices.length} allowed devices');
        print('📱 Device IDs: $allowedDevices');
      } else {
        print('⚠️ Could not fetch device list. HTTP ${res.statusCode}');
        // Don't throw, just set empty list
        allowedDevices = [];
      }
    } catch (e) {
      print('💥 Error fetching device list: $e');
      allowedDevices = [];
    }
  }

  bool verify(String input) {
    print('🧠 [verify] Checking password...');
    print('➡️ Entered: "${input.trim()}"');
    print('➡️ Cloud:   "${password?.trim()}"');
    print('➡️ Active:  $active');

    if (!active) {
      print('⛔ Access disabled by admin.');
      return false;
    }

    if (password == null) {
      print('⚠️ Password not fetched yet.');
      return false;
    }

    final result = input.trim() == password!.trim();
    print('✅ Match result: $result');

    return result;
  }

  // New method to verify if a device is allowed
  bool verifyDevice(String deviceId) {
    print('🧠 [verifyDevice] Checking device authorization...');
    print('➡️ Device ID: "$deviceId"');
    print('📱 Allowed devices: $allowedDevices');

    if (!active) {
      print('⛔ Access disabled by admin.');
      return false;
    }

    final isAllowed = allowedDevices.contains(deviceId);
    print(isAllowed ? '✅ Device is authorized' : '❌ Device is NOT authorized');

    return isAllowed;
  }

  // Helper method to get all allowed devices (for debugging)
  List<String> getAllowedDevices() {
    return allowedDevices;
  }
}