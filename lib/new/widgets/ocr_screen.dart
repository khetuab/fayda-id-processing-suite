import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/tesseract_amharic_ocr.dart';

class OCRScreen extends StatefulWidget {
  const OCRScreen({super.key});

  @override
  State<OCRScreen> createState() => _OCRScreenState();
}

class _OCRScreenState extends State<OCRScreen> {
  final picker = ImagePicker();
  final TesseractAmharicOCR ocr = TesseractAmharicOCR();
  String extractedText = '';
  bool isProcessing = false;

  Future<void> _pickAndProcessImage() async {
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    setState(() {
      isProcessing = true;
      extractedText = 'Processing...';
    });

    try {
      final imageBytes = await pickedFile.readAsBytes();
      final text = await ocr.extractAmharicText(imageBytes);
      setState(() {
        extractedText = text.isNotEmpty ? text : 'No Amharic text detected.';
      });
    } catch (e) {
      setState(() {
        extractedText = 'Error during OCR: $e';
      });
    } finally {
      setState(() {
        isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Amharic OCR'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: isProcessing ? null : _pickAndProcessImage,
              child: const Text('Pick Image for OCR'),
            ),
            const SizedBox(height: 20),
            if (isProcessing)
              const CircularProgressIndicator()
            else
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    extractedText,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}