// services/pdf_export_service.dart
import 'dart:io';
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
  // Exact pixel dimensions you want
  // Line 13-15 - Correct conversion
  static const double cardWidthPx = 321.6;
  static const double cardHeightPx = 201.6;
  static const double pdfDPI = 300.0;
  double pixelsToPoints(double pixels) {
    final inches = pixels / pdfDPI;
    final points = inches * 72; // 72 points per inch
    return points;
  }

  // Create PDF with exact pixel dimensions
  Future<pw.Document> createIDCardPDF(
      Uint8List frontImageBytes,
      Uint8List backImageBytes,
      ) async {
    final pdf = pw.Document();

    // Convert your exact pixel dimensions to PDF points
    final pdfWidth = pixelsToPoints(cardWidthPx);
    final pdfHeight = pixelsToPoints(cardHeightPx);

    // Front side
    // Front side
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(pdfWidth, pdfHeight),
        margin: pw.EdgeInsets.zero, // ADD THIS LINE
        build: (pw.Context context) {
          return pw.Stack( // CHANGE from pw.Center to pw.Stack
            children: [
              pw.Positioned(
                left: 0,
                top: 0,
                child: pw.Image(
                  pw.MemoryImage(frontImageBytes),
                  width: pdfWidth, // ADD width
                  height: pdfHeight, // ADD height
                  fit: pw.BoxFit.fill,
                ),
              ),
            ],
          );
        },
      ),
    );

    // Back side
    // Front side
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(pdfWidth, pdfHeight),
        margin: pw.EdgeInsets.zero, // ADD THIS LINE
        build: (pw.Context context) {
          return pw.Stack( // CHANGE from pw.Center to pw.Stack
            children: [
              pw.Positioned(
                left: 0,
                top: 0,
                child: pw.Image(
                  pw.MemoryImage(backImageBytes),
                  width: pdfWidth, // ADD width
                  height: pdfHeight, // ADD height
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

  // Enhanced high-quality widget capture with logging
  Future<Uint8List> captureHighQualityWidget(Widget widget) async {
    print('🔄 [CAPTURE] Starting widget capture...');
    final globalKey = GlobalKey();

    // Show widget in dialog for capture
    print('📱 [CAPTURE] Showing capture dialog...');
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

    // Wait for proper rendering
    print('⏳ [CAPTURE] Waiting for rendering...');
    await Future.delayed(const Duration(milliseconds: 400));
    print('✅ [CAPTURE] Rendering completed');

    try {
      print('🔍 [CAPTURE] Finding render boundary...');
      final boundary = globalKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;

      if (boundary != null) {
        print('✅ [CAPTURE] Render boundary found');
        print('🔄 [CAPTURE] Converting to image with pixelRatio: 10.0...');

        // Ultra high quality for PNG (higher than PDF)
        final targetDPI = 600.0; // For high quality
        final pixelRatio = targetDPI / 72.0; // ~8.33
        final image = await boundary.toImage(pixelRatio: pixelRatio);
        print('✅ [CAPTURE] Image converted - size: ${image.width}x${image.height}');

        print('🔄 [CAPTURE] Converting to byte data...');
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

        print('📱 [CAPTURE] Closing capture dialog...');
        Get.back(); // Close dialog

        if (byteData != null) {
          final result = byteData.buffer.asUint8List();
          print('✅ [CAPTURE] Capture successful - ${result.length} bytes');
          return result;
        } else {
          print('❌ [CAPTURE] Byte data is null');
          throw Exception('Failed to convert image to byte data');
        }
      } else {
        print('❌ [CAPTURE] Render boundary not found');
        print('📱 [CAPTURE] Closing capture dialog due to error...');
        Get.back();
        throw Exception('Failed to find render boundary');
      }
    } catch (e) {
      print('❌ [CAPTURE] ERROR in capture: $e');
      print('📱 [CAPTURE] Closing capture dialog due to error...');
      Get.back();
      rethrow;
    }
  }

  // More robust version with better error handling and logging
  Future<void> downloadAsPNG(
      IDCardModel idData,
      Map<String, String> formData,
      ) async {
    print('🟦 [PNG] Starting PNG download process...');

    // Use a variable to track if we should close the dialog
    bool shouldCloseDialog = true;

    // Show loading dialog
    print('📱 [PNG] Showing loading dialog...');
    print('✅ [PNG] Loading dialog shown');

    try {
      print('🔄 [PNG] Creating front card widget...');
      // Your PNG creation logic here
      final frontCard = Container(
        width: cardWidthPx,
        height: cardHeightPx ,
        child: ClipRect(
          child: HorizontalIDTemplate(
            idData: idData,
            isFront: true,
            formData: formData,
          ),
        ),
      );
      print('✅ [PNG] Front card widget created');

      print('🔄 [PNG] Creating back card widget...');
      final backCard = Container(
        width: cardWidthPx ,
        height: cardHeightPx ,
        child: ClipRect(
          child: HorizontalIDTemplate(
            idData: idData,
            isFront: false,
            formData: formData,
          ),
        ),
      );
      print('✅ [PNG] Back card widget created');

      print('🔄 [PNG] Capturing front card image...');
      final frontImage = await captureHighQualityWidget(frontCard);
      print('✅ [PNG] Front card captured - ${frontImage.length} bytes');

      print('🔄 [PNG] Capturing back card image...');
      final backImage = await captureHighQualityWidget(backCard);
      print('✅ [PNG] Back card captured - ${backImage.length} bytes');

      print('🔄 [PNG] Saving PNG files...');
      await _savePNGFiles(frontImage, backImage, idData);
      print('✅ [PNG] PNG files saved successfully');

    } catch (e) {
      print('❌ [PNG] ERROR in downloadAsPNG: $e');
      print('🔍 [PNG] Error type: ${e.runtimeType}');
      print('🔍 [PNG] Stack trace: ${e.toString()}');

      shouldCloseDialog = true;
      rethrow;
    } finally {
      print('🔧 [PNG] Finally block executing...');
      print('🔧 [PNG] shouldCloseDialog: $shouldCloseDialog');
      print('🔧 [PNG] Get.isDialogOpen: ${Get.isDialogOpen}');

      // Always close the dialog in finally block
      if (shouldCloseDialog && (Get.isDialogOpen ?? false)) {
        print('📱 [PNG] Closing loading dialog...');
        Get.back();
        print('✅ [PNG] Loading dialog closed');
      } else {
        print('ℹ️ [PNG] No need to close dialog - shouldCloseDialog: $shouldCloseDialog, isDialogOpen: ${Get.isDialogOpen}');
      }

      print('🏁 [PNG] PNG download process completed');
    }
  }

// Save PNG files to Downloads
  // Save PNG files to PUBLIC Downloads directory
  Future<void> _savePNGFiles(
      Uint8List frontImageBytes,
      Uint8List backImageBytes,
      IDCardModel idData,
      ) async {
    print('💾 [SAVE] Starting PNG file save process...');

    try {
      // Use direct path to public Downloads folder
      final publicDownloadsPath = '/storage/emulated/0/Download/ID_Cards';
      final downloadsDir = Directory(publicDownloadsPath);

      print('🔍 [SAVE] Checking public Downloads directory: $publicDownloadsPath');

      // Check if directory exists, if not try to create it
      if (!await downloadsDir.exists()) {
        print('📁 [SAVE] Creating public Downloads directory...');
        try {
          await downloadsDir.create(recursive: true);
          print('✅ [SAVE] Public Downloads directory created');
        } catch (e) {
          print('❌ [SAVE] Failed to create directory: $e');
          // Fallback to getExternalStorageDirectory
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

      print('✅ [SAVE] Public Downloads directory accessible');
      await _saveToDirectory(downloadsDir, frontImageBytes, backImageBytes);

    } catch (e) {
      print('❌ [SAVE] ERROR in _savePNGFiles: $e');
      rethrow;
    }
  }

// Helper method to save files to a directory
  Future<void> _saveToDirectory(
      Directory directory,
      Uint8List frontImageBytes,
      Uint8List backImageBytes) async {

    final timestamp = _getTimestamp();

    // Save front side
    final frontFilePath = '${directory.path}/ID_Card_Front_$timestamp.png';
    print('💾 [SAVE] Saving front image to: $frontFilePath');
    final frontFile = File(frontFilePath);
    await frontFile.writeAsBytes(frontImageBytes);
    print('✅ [SAVE] Front image saved - ${frontImageBytes.length} bytes');

    // Save back side
    final backFilePath = '${directory.path}/ID_Card_Back_$timestamp.png';
    print('💾 [SAVE] Saving back image to: $backFilePath');
    final backFile = File(backFilePath);
    await backFile.writeAsBytes(backImageBytes);
    print('✅ [SAVE] Back image saved - ${backImageBytes.length} bytes');

    print('📱 [SAVE] Showing success dialog...');
    _showPNGSuccessDialog(frontFile, backFile, frontImageBytes.length, backImageBytes.length);
    print('✅ [SAVE] PNG files saved successfully');
  }

// Show success dialog for PNG files
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
  // Main PDF download function
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
      // Use your exact pixel dimensions
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

      // Convert to high-quality images
      final frontImage = await captureHighQualityWidget(frontCard);
      final backImage = await captureHighQualityWidget(backCard);

      // Create PDF with exact dimensions
      final pdf = await createIDCardPDF(frontImage, backImage);
      final bytes = await pdf.save();

      Get.back(); // Close loading

      // Save and share
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

  // Save PDF and share it
  Future<void> _saveAndSharePDF(Uint8List pdfBytes, IDCardModel idData) async {
    try {
      // Save to temporary directory
      final tempDir = await getTemporaryDirectory();
      final fileName = 'ID_Card_${_getTimestamp()}.pdf';
      final file = File('${tempDir.path}/$fileName');

      await file.writeAsBytes(pdfBytes);

      // Share the file

    } catch (e) {
      Get.snackbar(
        'Error',
        'Cannot share file: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Save PDF to PUBLIC Downloads folder
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
            ],
          ),
        ),
        barrierDismissible: false,
      );

      // Create PDF with exact dimensions
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

      // Save to PUBLIC Downloads
      print('🔍 [PDF] Getting external storage directory...');
      final directory = await getExternalStorageDirectory();
      if (directory != null) {
        final downloadsDir = Directory('${directory.path}/Download');

        // Create Downloads folder if it doesn't exist
        if (!await downloadsDir.exists()) {
          await downloadsDir.create(recursive: true);
        }

        final fileName = 'ID_Card_${_getTimestamp()}.pdf';
        final file = File('${downloadsDir.path}/$fileName');
        await file.writeAsBytes(bytes);

        Get.back();
        //_showPNGSuccessDialog(file, bytes.length);
      } else {
        throw Exception('Cannot access Downloads');
      }

    } catch (e) {
      Get.back();
      // Fallback to sharing
      await downloadHighQualityPDF(idData, formData);
    }
  }

  // Show success dialog
  void _showSuccessDialog(File file, int fileSize) {
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
            Text('Quality: High (3x resolution)'),
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
              _openFile(file);
            },
            child: const Text('Open File'),
          ),
        ],
      ),
    );
  }

  // Open PDF file
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

  // Simple timestamp
  String _getTimestamp() {
    final now = DateTime.now();
    return '${now.millisecondsSinceEpoch}';
  }

  // Simple export options
  // Enhanced export options with PNG
  void showExportOptions(
      IDCardModel idData,
      Map<String, String> formData,
      ) {
    showModalBottomSheet(
      context: Get.context!,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Export ID Card',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '${cardWidthPx.toInt()}x${cardHeightPx.toInt()} pixels',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),

            // Share PDF option
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share PDF'),
              subtitle: const Text('Create and share via apps'),
              onTap: () {
                Get.back();
                downloadHighQualityPDF(idData, formData);
              },
            ),

            // Save to Downloads - PDF
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('Save as PDF'),
              subtitle: const Text('Save PDF to Downloads folder'),
              onTap: () {
                Get.back();
                saveToDownloads(idData, formData);
              },
            ),

            // NEW: Save as PNG option
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Save as PNG'),
              subtitle: const Text('High-quality PNG images (Front & Back)'),
              onTap: () {
                Get.back();
                downloadAsPNG(idData, formData);
              },
            ),

            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}