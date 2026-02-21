import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path_provider/path_provider.dart';

class OcrService {
  final TextRecognizer _recognizer = TextRecognizer();

  Future<String> recognizeTextFromBytes(Uint8List bytes) async {
    try {
      // Save the image bytes into a temporary PNG file
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(bytes);

      // Create InputImage from file path
      final inputImage = InputImage.fromFilePath(file.path);

      // Process image with ML Kit
      final result = await _recognizer.processImage(inputImage);

      return result.text;
    } catch (e) {
      print('OCR error: $e');
      return '';
    }
  }

  void dispose() {
    _recognizer.close();
  }

  Future<String> ocrInIsolate(Uint8List bytes) {
    return compute(_ocrWorker, bytes);
  }

  static Future<String> _ocrWorker(Uint8List bytes) async {
    final ocr = OcrService();
    return await ocr.recognizeTextFromBytes(bytes);
  }

}