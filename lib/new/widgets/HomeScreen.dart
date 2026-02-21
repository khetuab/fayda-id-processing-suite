import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tesseract_ocr/ocr_engine_config.dart';
import 'package:tesseract_ocr/tesseract_ocr.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _scanning = false;
  String _extractText = '';
  XFile? _pickedImage;

  final ImagePicker _picker = ImagePicker();

  final tesseractConfig = OCRConfig(
    language: 'amh', // Must match a .traineddata file in assets/tessdata
    engine: OCREngine.tesseract,
    // Optional Tesseract options:
    // options: {
    //   TesseractConfig.preserveInterwordSpaces: '1',
    //   TesseractConfig.pageSegMode: PageSegmentationMode.autoOsd,
    //   TesseractConfig.debugFile: '/path/to/debug.log', // Example option
    // },
  );
  Future<void> _pickAndExtractText() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    setState(() {
      _pickedImage = picked;
      _scanning = true;
      _extractText = '';
    });

    try {
      final text = await TesseractOcr.extractText(picked.path,config: tesseractConfig);
      setState(() {
        _extractText = text;
      });
    } catch (e) {
      setState(() {
        _extractText = 'Error extracting text: $e';
      });
    } finally {
      setState(() {
        _scanning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tesseract OCR'),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: ListView(
        children: [
          Container(
            height: 300,
            color: Colors.grey[300],
            child: _pickedImage == null
                ? const Icon(Icons.image, size: 100, color: Colors.grey)
                : Image.file(File(_pickedImage!.path), fit: BoxFit.cover),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: _scanning ? null : _pickAndExtractText,
              child: const Text(
                'Pick Image with Text',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
          const SizedBox(height: 30),
          if (_scanning)
            const Center(child: CircularProgressIndicator())
          else if (_extractText.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _extractText,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            )
          else
            const Center(child: Text('No text extracted yet')),
        ],
      ),
    );
  }
}
