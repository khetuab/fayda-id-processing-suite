import 'dart:convert';
import 'package:http/http.dart' as http;

class CloudPasswordService {
  String? password;
  bool active = true;

  Future<void> fetch() async {
    print('🌐 [CloudPasswordService] Fetching password from cloud...');

    final url = 'https://opensheet.elk.sh/16MJHlWklwAVGZrsNM5x2Uk7Xyi8F89VM-GpnjfkM-Cw/Sheet1';
    print('🔗 Request URL: $url');

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
}
