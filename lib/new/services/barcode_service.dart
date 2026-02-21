import 'dart:typed_data';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:barcode/barcode.dart' as bc;
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:path_provider/path_provider.dart';

class BarcodeService {
  final BarcodeScanner _scanner = BarcodeScanner();

  Future<List<Barcode>> scanFromBytes(Uint8List bytes) async {
    try {
      final path = await _saveTemp(bytes);
      final inputImage = InputImage.fromFilePath(path);
      final barcodes = await _scanner.processImage(inputImage);
      print(',,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,, bar'+barcodes.length.toString());
      return barcodes;
    } catch (e) {
      print('barcode scan error------------------------------------------: $e');
      return [];
    }
  }



  Future<String> _saveTemp(Uint8List bytes) async {
    final dir = await getTemporaryDirectory();
    final f = File('${dir.path}/barcode_${DateTime.now().millisecondsSinceEpoch}.png');
    await f.writeAsBytes(bytes);
    return f.path;
  }

  void dispose() {
    _scanner.close();
  }
}
