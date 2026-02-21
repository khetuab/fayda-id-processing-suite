// services/password_service.dart
import 'package:get_storage/get_storage.dart';

class PasswordService {
  final _storage = GetStorage();
  static const String _passwordKey = 'app_password';
  static const String _initialPassword = '1234k4321'; // Static initial password

  // Initialize GetStorage
  Future<void> init() async {
    await GetStorage.init();
  }

  // Check if password is set (always true since we have initial password)
  bool get isPasswordSet => true;

  // Set new password
  Future<bool> setPassword(String newPassword) async {
    if (newPassword.length < 4) return false;

    try {
      await _storage.write(_passwordKey, newPassword);
      return true;
    } catch (e) {
      print('Error setting password: $e');
      return false;
    }
  }

  // Verify password
  bool verifyPassword(String inputPassword) {
    try {
      final storedPassword = _storage.read(_passwordKey) ?? _initialPassword;
      return inputPassword == storedPassword;
    } catch (e) {
      print('Error verifying password: $e');
      // Fallback to initial password
      return inputPassword == _initialPassword;
    }
  }

  // Get current password (for display purposes)
  String getCurrentPassword() {
    try {
      return _storage.read(_passwordKey) ?? _initialPassword;
    } catch (e) {
      return _initialPassword;
    }
  }

  // Reset to initial password
  Future<bool> resetToInitial() async {
    try {
      await _storage.remove(_passwordKey);
      return true;
    } catch (e) {
      print('Error resetting password: $e');
      return false;
    }
  }

  // Check if using initial password
  bool get isUsingInitialPassword {
    return !_storage.hasData(_passwordKey);
  }
}