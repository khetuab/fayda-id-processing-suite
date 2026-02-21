import 'dart:typed_data';
import 'dart:io';
import 'dart:ui';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:path_provider/path_provider.dart';

class FaceService {
  final FaceDetector _detector = FaceDetector(
    options: FaceDetectorOptions(
      performanceMode: FaceDetectorMode.accurate,
      enableLandmarks: false,
      enableContours: false,
    ),
  );

  Future<Rect?> detectFaceBounds(Uint8List bytes) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/face_${DateTime.now().millisecondsSinceEpoch}.png');
    await file.writeAsBytes(bytes);

    final inputImage = InputImage.fromFilePath(file.path);
    final faces = await _detector.processImage(inputImage);

    await file.delete();

    if (faces.isEmpty) return null;
    return faces.first.boundingBox;
  }

  void dispose() => _detector.close();
}
