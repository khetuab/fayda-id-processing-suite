// services/pdf_export_service.dart
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';
import '../models/id_card_model.dart';
import '../widgets/card_preview.dart';

class PdfExportService {
  static const double cardWidthPx = 321.6;
  static const double cardHeightPx = 201.6;
  static const double pdfDPI = 300.0;

  double pixelsToPoints(double pixels) {
    final inches = pixels / pdfDPI;
    final points = inches * 72;
    return points;
  }

  Future<pw.Document> createIDCardPDF(
      Uint8List frontImageBytes,
      Uint8List backImageBytes,
      ) async {
    final pdf = pw.Document();
    final pdfWidth = pixelsToPoints(cardWidthPx);
    final pdfHeight = pixelsToPoints(cardHeightPx);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(pdfWidth, pdfHeight),
        margin: pw.EdgeInsets.zero,
        build: (pw.Context context) {
          return pw.Stack(
            children: [
              pw.Positioned(
                left: 0,
                top: 0,
                child: pw.Image(
                  pw.MemoryImage(frontImageBytes),
                  width: pdfWidth,
                  height: pdfHeight,
                  fit: pw.BoxFit.fill,
                ),
              ),
            ],
          );
        },
      ),
    );

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(pdfWidth, pdfHeight),
        margin: pw.EdgeInsets.zero,
        build: (pw.Context context) {
          return pw.Stack(
            children: [
              pw.Positioned(
                left: 0,
                top: 0,
                child: pw.Image(
                  pw.MemoryImage(backImageBytes),
                  width: pdfWidth,
                  height: pdfHeight,
                  fit: pw.BoxFit.fill,
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  Future<Uint8List> captureHighQualityWidget(Widget widget) async {
    final globalKey = GlobalKey();

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: SizedBox(
          width: cardWidthPx,
          height: cardHeightPx,
          child: RepaintBoundary(
            key: globalKey,
            child: Material(
              color: Colors.white,
              child: widget,
            ),
          ),
        ),
      ),
    );

    await Future.delayed(const Duration(milliseconds: 400));

    try {
      final boundary = globalKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;

      if (boundary != null) {
        final targetDPI = 600.0;
        final pixelRatio = targetDPI / 72.0;
        final image = await boundary.toImage(pixelRatio: pixelRatio);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        Get.back();

        if (byteData != null) {
          return byteData.buffer.asUint8List();
        } else {
          throw Exception('Failed to convert image to byte data');
        }
      } else {
        Get.back();
        throw Exception('Failed to find render boundary');
      }
    } catch (e) {
      Get.back();
      rethrow;
    }
  }

  Future<Uint8List> captureUltraHighQualityWidget(Widget widget) async {
    final globalKey = GlobalKey();

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: SizedBox(
          width: cardWidthPx,
          height: cardHeightPx,
          child: RepaintBoundary(
            key: globalKey,
            child: Material(
              color: Colors.white,
              child: widget,
            ),
          ),
        ),
      ),
    );

    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final boundary = globalKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;

      if (boundary != null) {
        final targetDPI = 600.0;
        final pixelRatio = targetDPI / 72.0;
        final image = await boundary.toImage(pixelRatio: pixelRatio);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        Get.back();

        if (byteData != null) {
          return byteData.buffer.asUint8List();
        } else {
          throw Exception('Failed to convert image to byte data');
        }
      } else {
        Get.back();
        throw Exception('Failed to find render boundary');
      }
    } catch (e) {
      Get.back();
      rethrow;
    }
  }

  Future<void> downloadAsPNG(
      IDCardModel idData,
      Map<String, String> formData,
      ) async {
    bool shouldCloseDialog = true;

    try {
      final frontCard = Container(
        width: cardWidthPx,
        height: cardHeightPx,
        child: ClipRect(
          child: HorizontalIDTemplate(
            idData: idData,
            isFront: true,
            formData: formData,
          ),
        ),
      );

      final backCard = Container(
        width: cardWidthPx,
        height: cardHeightPx,
        child: ClipRect(
          child: HorizontalIDTemplate(
            idData: idData,
            isFront: false,
            formData: formData,
          ),
        ),
      );

      final frontImage = await captureHighQualityWidget(frontCard);
      final backImage = await captureHighQualityWidget(backCard);
      await _savePNGFiles(frontImage, backImage, idData);

    } catch (e) {
      shouldCloseDialog = true;
      rethrow;
    } finally {
      if (shouldCloseDialog && (Get.isDialogOpen ?? false)) {
        Get.back();
      }
    }
  }

  Future<void> _savePNGFiles(
      Uint8List frontImageBytes,
      Uint8List backImageBytes,
      IDCardModel idData,
      ) async {
    try {
      final publicDownloadsPath = '/storage/emulated/0/Download/ID_Cards';
      final downloadsDir = Directory(publicDownloadsPath);

      if (!await downloadsDir.exists()) {
        try {
          await downloadsDir.create(recursive: true);
        } catch (e) {
          final fallbackDir = await getExternalStorageDirectory();
          if (fallbackDir != null) {
            final fallbackDownloads = Directory('${fallbackDir.path}/Download');
            if (!await fallbackDownloads.exists()) {
              await fallbackDownloads.create(recursive: true);
            }
            await _saveToDirectory(fallbackDownloads, frontImageBytes, backImageBytes);
            return;
          } else {
            throw Exception('Cannot access any storage directory');
          }
        }
      }

      await _saveToDirectory(downloadsDir, frontImageBytes, backImageBytes);

    } catch (e) {
      rethrow;
    }
  }

  Future<void> _saveToDirectory(
      Directory directory,
      Uint8List frontImageBytes,
      Uint8List backImageBytes) async {

    final timestamp = _getTimestamp();

    final frontFilePath = '${directory.path}/ID_Card_Front_$timestamp.png';
    final frontFile = File(frontFilePath);
    await frontFile.writeAsBytes(frontImageBytes);

    final backFilePath = '${directory.path}/ID_Card_Back_$timestamp.png';
    final backFile = File(backFilePath);
    await backFile.writeAsBytes(backImageBytes);

    _showPNGSuccessDialog(frontFile, backFile, frontImageBytes.length, backImageBytes.length);
  }

  void _showPNGSuccessDialog(File frontFile, File backFile, int frontSize, int backSize) {
    showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('PNG Files Saved!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Front: ${frontFile.path.split('/').last}'),
            Text('Back: ${backFile.path.split('/').last}'),
            const SizedBox(height: 12),
            Text('Front Size: ${(frontSize / 1024).toStringAsFixed(1)} KB'),
            Text('Back Size: ${(backSize / 1024).toStringAsFixed(1)} KB'),
            Text('Dimensions: ${(cardWidthPx * 2).toInt()}x${(cardHeightPx * 2).toInt()} pixels'),
            Text('Quality: Ultra High (2x scale)'),
            const SizedBox(height: 16),
            const Text('Saved to Downloads folder'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('OK'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _openFile(frontFile);
            },
            child: const Text('Open Front'),
          ),
        ],
      ),
    );
  }

  Future<void> downloadCombinedPNG(
      IDCardModel idData,
      Map<String, String> formData,
      ) async {
    try {
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );

      final frontCard = Container(
        width: cardWidthPx,
        height: cardHeightPx,
        child: HorizontalIDTemplate(
          idData: idData,
          isFront: true,
          formData: formData,
        ),
      );

      final backCard = Container(
        width: cardWidthPx,
        height: cardHeightPx,
        child: HorizontalIDTemplate(
          idData: idData,
          isFront: false,
          formData: formData,
        ),
      );

      final frontImage = await captureUltraHighQualityWidget(frontCard);
      final backImage = await captureUltraHighQualityWidget(backCard);
      final combinedBytes = await _combineImagesSideBySideUltraQuality(frontImage, backImage);
      await _saveCombinedPNG(combinedBytes);
      Get.back();
      _showCombinedSuccessDialog(combinedBytes.length);

    } catch (e, st) {
      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar(
        'Error',
        'Failed to create combined PNG: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    }
  }

  Future<Uint8List> _combineImagesSideBySideUltraQuality(
      Uint8List frontBytes,
      Uint8List backBytes, {
        double spacing = 80.0, // Add this parameter for customizable spacing
      }) async {
    final frontCodec = await ui.instantiateImageCodec(
      frontBytes,
      targetWidth: null,
      allowUpscaling: false,
    );
    final frontFrame = await frontCodec.getNextFrame();
    final frontImage = frontFrame.image;

    final backCodec = await ui.instantiateImageCodec(
      backBytes,
      targetWidth: null,
      allowUpscaling: false,
    );
    final backFrame = await backCodec.getNextFrame();
    final backImage = backFrame.image;

    // Add spacing to total width
    final width = frontImage.width + backImage.width + spacing.toInt();
    final height = max(frontImage.height, backImage.height);

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final paint = Paint()
      ..filterQuality = FilterQuality.high
      ..isAntiAlias = true
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.drawRect(
      Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
      Paint()..color = Colors.white,
    );

    // Draw front image
    canvas.drawImage(frontImage, Offset(0, 0), paint);

    // Draw back image with spacing offset
    canvas.drawImage(
      backImage,
      Offset(frontImage.width.toDouble() + spacing, 0),
      paint,
    );

    canvas.restore();

    final picture = recorder.endRecording();
    final img = await picture.toImage(width, height);
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);

    if (byteData == null) {
      throw Exception('Failed to convert combined image to byte data');
    }

    return byteData.buffer.asUint8List();
  }
  Future<void> _saveCombinedPNG(Uint8List bytes) async {
    final path = '/storage/emulated/0/Download/ID_Cards';
    final dir = Directory(path);

    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    final timestamp = _getTimestamp();
    final file = File('${dir.path}/ID_Card_Combined_$timestamp.png');
    await file.writeAsBytes(bytes);
  }

  void _showCombinedSuccessDialog(int size) {
    showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '✨ Maximum Quality Settings Applied:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('• 600 DPI resolution (8.33x scale)'),
            const Text('• Lossless PNG format (no compression)'),
            const Text('• Anti-aliasing enabled'),
            const Text('• High quality filtering'),
            const SizedBox(height: 12),
            Text('File Size: ${(size / 1024).toStringAsFixed(1)} KB'),
            Text('Dimensions: ${(cardWidthPx * 2).toInt()} x ${cardHeightPx.toInt()} pixels (scaled)'),
            const SizedBox(height: 16),
            const Text('📁 Saved to: Downloads/ID_Cards/'),
            const Text('📄 Format: Front & Back side-by-side'),
            const Text('🖨️ Print-ready quality'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('OK'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _openDownloadsFolder();
            },
            child: const Text('Open Folder'),
          ),
        ],
      ),
    );
  }

  Future<void> _openDownloadsFolder() async {
    try {
      final path = '/storage/emulated/0/Download/ID_Cards';
      await OpenFile.open(path);
    } catch (e) {
      Get.snackbar(
        'Info',
        'Files saved in Downloads/ID_Cards folder',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );
    }
  }

  Future<void> downloadHighQualityPDF(
      IDCardModel idData,
      Map<String, String> formData,
      ) async {
    try {
      Get.dialog(
        const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Creating PDF...'),
            ],
          ),
        ),
        barrierDismissible: false,
      );

      final frontCard = Container(
        width: cardWidthPx,
        height: cardHeightPx,
        child: HorizontalIDTemplate(
          idData: idData,
          isFront: true,
          formData: formData,
        ),
      );

      final backCard = Container(
        width: cardWidthPx,
        height: cardHeightPx,
        child: HorizontalIDTemplate(
          idData: idData,
          isFront: false,
          formData: formData,
        ),
      );

      final frontImage = await captureHighQualityWidget(frontCard);
      final backImage = await captureHighQualityWidget(backCard);
      final pdf = await createIDCardPDF(frontImage, backImage);
      final bytes = await pdf.save();

      Get.back();
      await _saveAndSharePDF(bytes, idData);

    } catch (e) {
      Get.back();
      Get.snackbar(
        'Error',
        'Failed to create PDF: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _saveAndSharePDF(Uint8List pdfBytes, IDCardModel idData) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final fileName = 'ID_Card_${_getTimestamp()}.pdf';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(pdfBytes);
      _showPDFSuccessDialog(file, pdfBytes.length);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Cannot save file: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _showPDFSuccessDialog(File file, int fileSize) {
    showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('PDF Saved!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('File: ${file.path.split('/').last}'),
            const SizedBox(height: 8),
            Text('Size: ${(fileSize / 1024).toStringAsFixed(1)} KB'),
            Text('Dimensions: ${cardWidthPx.toInt()}x${cardHeightPx.toInt()} pixels'),
            Text('Quality: High Resolution'),
            const SizedBox(height: 16),
            const Text('Saved to temporary folder'),
            const Text('Ready to share'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('OK'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _openFile(file);
            },
            child: const Text('Open PDF'),
          ),
        ],
      ),
    );
  }

  Future<void> saveToDownloads(
      IDCardModel idData,
      Map<String, String> formData,
      ) async {
    try {
      Get.dialog(
        const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Saving PDF...'),
            ],
          ),
        ),
        barrierDismissible: false,
      );

      final frontCard = Container(
        width: cardWidthPx,
        height: cardHeightPx,
        child: HorizontalIDTemplate(
          idData: idData,
          isFront: true,
          formData: formData,
        ),
      );

      final backCard = Container(
        width: cardWidthPx,
        height: cardHeightPx,
        child: HorizontalIDTemplate(
          idData: idData,
          isFront: false,
          formData: formData,
        ),
      );

      final frontImage = await captureHighQualityWidget(frontCard);
      final backImage = await captureHighQualityWidget(backCard);
      final pdf = await createIDCardPDF(frontImage, backImage);
      final bytes = await pdf.save();

      final directory = await getExternalStorageDirectory();
      if (directory != null) {
        final downloadsDir = Directory('${directory.path}/Download/ID_Cards');

        if (!await downloadsDir.exists()) {
          await downloadsDir.create(recursive: true);
        }

        final fileName = 'ID_Card_${_getTimestamp()}.pdf';
        final file = File('${downloadsDir.path}/$fileName');
        await file.writeAsBytes(bytes);

        Get.back();
        _showPDFSavedDialog(file, bytes.length);
      } else {
        throw Exception('Cannot access Downloads');
      }

    } catch (e) {
      Get.back();
      Get.snackbar(
        'Error',
        'Failed to save PDF: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _showPDFSavedDialog(File file, int fileSize) {
    showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('PDF Saved Successfully!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('File: ${file.path.split('/').last}'),
            const SizedBox(height: 8),
            Text('Size: ${(fileSize / 1024).toStringAsFixed(1)} KB'),
            Text('Dimensions: ${cardWidthPx.toInt()}x${cardHeightPx.toInt()} pixels'),
            Text('Quality: High Resolution'),
            const SizedBox(height: 16),
            const Text('📁 Saved to: Downloads/ID_Cards/'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('OK'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _openFile(file);
            },
            child: const Text('Open PDF'),
          ),
        ],
      ),
    );
  }

  Future<void> _openFile(File file) async {
    try {
      await OpenFile.open(file.path);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Cannot open file',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  String _getTimestamp() {
    final now = DateTime.now();
    return '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
  }

  void showExportOptions(
      IDCardModel idData,
      Map<String, String> formData,
      ) {
    showModalBottomSheet(
      context: Get.context!,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Export ID Card',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '${cardWidthPx.toInt()} x ${cardHeightPx.toInt()} pixels | 600 DPI',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 9),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.share, color: Colors.blue),
              ),
              title: const Text('Share PDF'),
              subtitle: const Text('Create and share via apps'),
              onTap: () {
                Get.back();
                downloadHighQualityPDF(idData, formData);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.picture_as_pdf, color: Colors.red),
              ),
              title: const Text('Save as PDF'),
              subtitle: const Text('Save PDF to Downloads folder'),
              onTap: () {
                Get.back();
                saveToDownloads(idData, formData);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.image, color: Colors.green),
              ),
              title: const Text('Save as PNG'),
              subtitle: const Text('High-quality PNG images (Front & Back)'),
              onTap: () {
                Get.back();
                downloadAsPNG(idData, formData);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.view_week, color: Colors.orange),
              ),
              title: const Text('Save Combined PNG'),
              subtitle: const Text('Front & Back side-by-side (Ultra HD)'),
              onTap: () {
                Get.back();
                downloadCombinedPNG(idData, formData);
              },
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => Get.back(),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 45),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}