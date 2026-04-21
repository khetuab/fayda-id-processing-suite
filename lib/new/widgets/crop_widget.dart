import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

import '../services/image_utils.dart';

class SmartCropWidget extends StatefulWidget {
  final Uint8List imageBytes;
  final Function(Uint8List) onCropped;

  const SmartCropWidget({
    Key? key,
    required this.imageBytes,
    required this.onCropped,
  }) : super(key: key);

  @override
  State<SmartCropWidget> createState() => _SmartCropWidgetState();
}

class _SmartCropWidgetState extends State<SmartCropWidget> {
  late img.Image originalImage;
  late Uint8List currentImageBytes;
  late Uint8List originalImageBytes; // Store original for cropping

  bool _isProcessing = false;
  Rect cropRect = Rect.zero;
  double scale = 1.0;
  Size? imageDisplaySize;

  @override
  void initState() {
    super.initState();
    currentImageBytes = widget.imageBytes;
    originalImageBytes = widget.imageBytes; // Store original
    originalImage = img.decodeImage(currentImageBytes)!;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initCropRect();
    });
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await File(pickedFile.path).readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) return;

      setState(() {
        currentImageBytes = bytes;
        originalImageBytes = bytes; // Update original bytes
        originalImage = decoded;
        cropRect = Rect.zero;
        imageDisplaySize = null;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initCropRect();
      });
    }
  }

  void _initCropRect() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final scaleX = screenWidth / originalImage.width;
    final scaleY = screenHeight / originalImage.height;
    scale = scaleX < scaleY ? scaleX : scaleY;

    final displayWidth = originalImage.width * scale;
    final displayHeight = originalImage.height * scale;

    imageDisplaySize = Size(displayWidth, displayHeight);

    final left = originalImage.width * 0.1;
    final top = originalImage.height * 0.1;
    final width = originalImage.width * 0.8;
    final height = originalImage.height * 0.8;

    setState(() {
      cropRect = Rect.fromLTWH(left, top, width, height);
    });
  }


  Future<void> _cropImage() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final cropped = img.copyCrop(
        originalImage,
        x: cropRect.left.toInt(),
        y: cropRect.top.toInt(),
        width: cropRect.width.toInt(),
        height: cropRect.height.toInt(),
      );

      final croppedBytes = Uint8List.fromList(img.encodePng(cropped));

      final bgRemovedBytes = await ImageUtils.removeBackgroundUint8(
        croppedBytes,
        convertToGrayscale: false,
      );

      widget.onCropped(bgRemovedBytes);
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Processing failed")),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    if (imageDisplaySize == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final maxWidth = originalImage.width.toDouble();
    final maxHeight = originalImage.height.toDouble();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Crop Image",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        actions: [

          TextButton(
            onPressed: _cropImage,
            child: Container(
              width: 60,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
              ),
              child: const Text(
                "Crop",
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // ✅ FIX: use currentImageBytes
            Image.memory(
              currentImageBytes,
              width: imageDisplaySize!.width,
              height: imageDisplaySize!.height,
              fit: BoxFit.contain,
            ),

            Positioned(
              left: 0,
              top: 0,
              width: imageDisplaySize!.width,
              height: imageDisplaySize!.height,
              child: CustomPaint(
                painter: CropOverlayPainter(
                  cropRect: cropRect,
                  scale: scale,
                ),
              ),
            ),

            Positioned(
              left: cropRect.left * scale,
              top: cropRect.top * scale,
              width: cropRect.width * scale,
              height: cropRect.height * scale,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    double newLeft = (cropRect.left + details.delta.dx / scale)
                        .clamp(0, maxWidth - cropRect.width);
                    double newTop = (cropRect.top + details.delta.dy / scale)
                        .clamp(0, maxHeight - cropRect.height);

                    cropRect = Rect.fromLTWH(
                        newLeft, newTop, cropRect.width, cropRect.height);
                  });
                },
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.green, width: 2),
                      ),
                    ),
                    _buildHandle(Alignment.topLeft, maxWidth, maxHeight),
                    _buildHandle(Alignment.topRight, maxWidth, maxHeight),
                    _buildHandle(Alignment.bottomLeft, maxWidth, maxHeight),
                    _buildHandle(Alignment.bottomRight, maxWidth, maxHeight),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle(
      Alignment alignment, double maxWidth, double maxHeight) {
    return Align(
      alignment: alignment,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            double left = cropRect.left;
            double top = cropRect.top;
            double right = cropRect.right;
            double bottom = cropRect.bottom;

            switch (alignment) {
              case Alignment.topLeft:
                left = (left + details.delta.dx / scale).clamp(0, right - 20);
                top = (top + details.delta.dy / scale).clamp(0, bottom - 20);
                break;
              case Alignment.topRight:
                right = (right + details.delta.dx / scale)
                    .clamp(left + 20, maxWidth);
                top = (top + details.delta.dy / scale).clamp(0, bottom - 20);
                break;
              case Alignment.bottomLeft:
                left = (left + details.delta.dx / scale).clamp(0, right - 20);
                bottom = (bottom + details.delta.dy / scale)
                    .clamp(top + 20, maxHeight);
                break;
              case Alignment.bottomRight:
                right = (right + details.delta.dx / scale)
                    .clamp(left + 20, maxWidth);
                bottom = (bottom + details.delta.dy / scale)
                    .clamp(top + 20, maxHeight);
                break;
              default:
            }

            cropRect = Rect.fromLTRB(left, top, right, bottom);
          });
        },
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }



}


class CropOverlayPainter extends CustomPainter {
  final Rect cropRect;
  final double scale;

  CropOverlayPainter({required this.cropRect, required this.scale});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.blue.withOpacity(0.4); // blue overlay

    // Left overlay
    canvas.drawRect(
        Rect.fromLTWH(0, 0, cropRect.left * scale, size.height), paint);
    // Right overlay
    canvas.drawRect(
        Rect.fromLTWH(cropRect.right * scale, 0,
            size.width - cropRect.right * scale, size.height),
        paint);
    // Top overlay
    canvas.drawRect(
        Rect.fromLTWH(cropRect.left * scale, 0, cropRect.width * scale,
            cropRect.top * scale),
        paint);
    // Bottom overlay
    canvas.drawRect(
        Rect.fromLTWH(cropRect.left * scale, cropRect.bottom * scale,
            cropRect.width * scale, size.height - cropRect.bottom * scale),
        paint);

    // Crop rectangle border
    final borderPaint = Paint()
      ..color = Colors.green // green border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawRect(
      Rect.fromLTWH(cropRect.left * scale, cropRect.top * scale,
          cropRect.width * scale, cropRect.height * scale),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CropOverlayPainter oldDelegate) {
    return oldDelegate.cropRect != cropRect;
  }
}
