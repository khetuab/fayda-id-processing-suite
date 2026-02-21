import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tesseract_ocr/tesseract_ocr.dart';
import 'package:tesseract_ocr/ocr_engine_config.dart';

class TesseractAmharicOCR {
  static bool _initialized = false;

  /// Initialize OCR (assets are auto-copied by plugin in v0.5.0)
  static Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    print('✅ Tesseract OCR initialized (v0.5.0)');
  }

  /// Extract Amharic text from image bytes
  Future<String> extractAmharicText(Uint8List imageBytes) async {
    try {
      if (!_initialized) {
        await initialize();
      }

      final tempDir = await getTemporaryDirectory();
      final tempFile = File(
        '${tempDir.path}/ocr_${DateTime.now().millisecondsSinceEpoch}.png',
      );

      await tempFile.writeAsBytes(imageBytes);

      /// ✅ CORRECT CONFIG OBJECT
      final ocrConfig = OCRConfig(
        language: 'amh',
        engine: OCREngine.tesseract,
        options: {
          TesseractConfig.pageSegMode:
          PageSegmentationMode.singleLine, // PSM 7
        },
      );


      final result = await TesseractOcr.extractText(
        tempFile.path,
        config: ocrConfig,
      );

      await tempFile.delete().catchError((_) {});
      return result.trim();
    } catch (e, stackTrace) {
      print('❌ OCR error: $e');
      print(stackTrace);
      return '';
    }
  }

  Future<String> extractEnglishText(Uint8List imageBytes) async {
    try {
      if (!_initialized) {
        await initialize();
      }

      final tempDir = await getTemporaryDirectory();
      final tempFile = File(
        '${tempDir.path}/ocr_${DateTime.now().millisecondsSinceEpoch}.png',
      );

      await tempFile.writeAsBytes(imageBytes);

      /// ✅ CORRECT CONFIG OBJECT
      final ocrConfig = OCRConfig(
        language: 'eng',
        engine: OCREngine.tesseract,
        options: {
          TesseractConfig.pageSegMode:
          PageSegmentationMode.singleLine, // PSM 7
        },
      );


      final result = await TesseractOcr.extractText(
        tempFile.path,
        config: ocrConfig,
      );

      await tempFile.delete().catchError((_) {});
      return result.trim();
    } catch (e, stackTrace) {
      print('❌ OCR error: $e');
      print(stackTrace);
      return '';
    }
  }

  Future<String> extractNumbersOnly(Uint8List imageBytes) async {
    try {
      if (!_initialized) {
        await initialize();
      }

      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/ocr_${DateTime.now().millisecondsSinceEpoch}.png');
      await tempFile.writeAsBytes(imageBytes);

      final config = OCRConfig(
        language: 'eng',
        engine: OCREngine.tesseract,
        options: {
          TesseractConfig.pageSegMode: PageSegmentationMode.singleLine, // FIXED: no cast needed
          'tessedit_char_whitelist': '0123456789',
        },
      );

      final result = await TesseractOcr.extractText(
        tempFile.path,
        config: config,
      );

      await tempFile.delete().catchError((_) {});
      return result.replaceAll(RegExp(r'[^0-9]'), '').trim();
    } catch (e) {
      print('Number OCR error: $e');
      return '';
    }
  }

  Future<String> extractDateText(Uint8List imageBytes) async {
    try {
      if (!_initialized) {
        await initialize();
      }

      final tempDir = await getTemporaryDirectory();
      final tempFile = File(
        '${tempDir.path}/ocr_${DateTime.now().millisecondsSinceEpoch}.png',
      );

      await tempFile.writeAsBytes(imageBytes);

      /// ✅ CORRECT CONFIG OBJECT
      final ocrConfig = OCRConfig(
        language: 'eng',
        engine: OCREngine.tesseract,
        options: {
          TesseractConfig.pageSegMode:
          PageSegmentationMode.singleBlock,
      // PSM 7
        },
      );


      final result = await TesseractOcr.extractText(
        tempFile.path,
        config: ocrConfig,
      );

      await tempFile.delete().catchError((_) {});
      return result.trim();
    } catch (e, stackTrace) {
      print('❌ OCR error: $e');
      print(stackTrace);
      return '';
    }
  }

  Future<String> extractTextWithConfig(
      Uint8List imageBytes, {
        String language = 'amh',
        int psm = 7,
      }) async {
    try {
      if (!_initialized) {
        await initialize();
      }

      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/ocr_${DateTime.now().millisecondsSinceEpoch}.png');
      await tempFile.writeAsBytes(imageBytes);

      // Map PSM int to the actual string values expected by the package
      String pageSegMode;
      switch (psm) {
        case 6:
          pageSegMode = '6'; // or whatever string value the package expects
          break;
        case 7:
          pageSegMode = '7';
          break;
        case 8:
          pageSegMode = '8';
          break;
        default:
          pageSegMode = '3'; // auto mode
      }

      final config = OCRConfig(
        language: language,
        engine: OCREngine.tesseract,
        options: {
          'tessedit_pageseg_mode': pageSegMode, // Use string key instead of enum
          // If you need character whitelist for numbers:
          if (language == 'eng') 'tessedit_char_whitelist': '0123456789',
        },
      );

      final result = await TesseractOcr.extractText(
        tempFile.path,
        config: config,
      );

      await tempFile.delete().catchError((_) {});
      return result.trim();
    } catch (e) {
      print('OCR error: $e');
      return '';
    }
  }

  /// Generic OCR method
  Future<String> extractText(
      Uint8List imageBytes, {
        String language = 'amh',
      }) async {
    try {
      if (!_initialized) {
        await initialize();
      }

      final tempDir = await getTemporaryDirectory();
      final tempFile =
      File('${tempDir.path}/ocr_${DateTime.now().millisecondsSinceEpoch}.png');

      await tempFile.writeAsBytes(imageBytes);

      final config = OCRConfig(
        language: language,
        engine: OCREngine.tesseract,
      );

      final result = await TesseractOcr.extractText(
        tempFile.path,
        config: config,
      );

      await tempFile.delete().catchError((_) {});
      return result.trim();
    } catch (e) {
      print('OCR error: $e');
      return '';
    }
  }
}
