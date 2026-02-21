class CardNumberUtils {
  /// Extracts only the last 16 digits as the card number
  static String extractCardNumber(String rawText) {
    if (rawText.isEmpty) return 'N/A';

    try {
      // Remove all non-digit characters
      String cleanNumber = rawText.replaceAll(RegExp(r'[^\d]'), '');

      print('🔍 Raw number: $cleanNumber (${cleanNumber.length} digits)');

      // Always take the LAST 16 digits
      if (cleanNumber.length >= 16) {
        final last16 = cleanNumber.substring(cleanNumber.length - 16);
        print('✅ Using last 16 digits: $last16');
        return _formatCardNumber(last16);
      }
      else if (cleanNumber.length >= 14) {
        // If between 14-15 digits, use what we have
        return _formatCardNumber(cleanNumber);
      }
      else {
        // Too short
        print('❌ Number too short: ${cleanNumber.length} digits');
        return 'N/A';
      }

    } catch (e) {
      print('❌ Error extracting card number: $e');
      return rawText;
    }
  }

  /// Format as XXXX XXXX XXXX XXXX
  static String _formatCardNumber(String number) {
    final buffer = StringBuffer();
    for (int i = 0; i < number.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write('');
      buffer.write(number[i]);
    }
    return buffer.toString();
  }

  /// Find card number in mixed text by looking for the last 16-digit sequence
  static String? findCardNumberInText(String text) {
    if (text.isEmpty) return null;

    try {
      // Extract all digits
      final digits = text.replaceAll(RegExp(r'[^\d]'), '');

      if (digits.length >= 16) {
        final last16 = digits.substring(digits.length - 16);
        print('✅ Found card number in text: $last16');
        return _formatCardNumber(last16);
      }

      return null;
    } catch (e) {
      print('❌ Error finding card number in text: $e');
      return null;
    }
  }
}