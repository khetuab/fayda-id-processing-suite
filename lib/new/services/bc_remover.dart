// // lib/new/services/background_removal_service.dart
//
// import 'dart:typed_data';
// import 'dart:ui' as ui;
// import 'package:flutter/material.dart';
// import 'package:image/image.dart' as img;
//
// class BackgroundRemovalService {
//   static final BackgroundRemovalService _instance = BackgroundRemovalService._internal();
//   factory BackgroundRemovalService() => _instance;
//   BackgroundRemovalService._internal();
//
//   bool _isInitialized = false;
//
//   /// Initialize the background remover (call once at app startup)
//   Future<void> initialize() async {
//     if (!_isInitialized) {
//       await BackgroundRemover.instance.initializeOrt();
//       _isInitialized = true;
//     }
//   }
//
//   /// Dispose resources (call when app closes)
//   void dispose() {
//     if (_isInitialized) {
//       BackgroundRemover.instance.dispose();
//       _isInitialized = false;
//     }
//   }
//
//   /// Remove background from image bytes
//   Future<Uint8List?> removeBackground(Uint8List imageBytes) async {
//     try {
//       if (!_isInitialized) {
//         await initialize();
//       }
//
//       // Remove background
//       final ui.Image? result = await BackgroundRemover.instance.removeBg(imageBytes);
//
//       if (result == null) {
//         print('⚠️ Background removal returned null');
//         return null;
//       }
//
//       // Convert ui.Image to bytes
//       final byteData = await result.toByteData(format: ui.ImageByteFormat.png);
//       if (byteData == null) {
//         print('⚠️ Failed to convert image to bytes');
//         return null;
//       }
//
//       return byteData.buffer.asUint8List();
//     } catch (e) {
//       print('❌ Background removal error: $e');
//       return null;
//     }
//   }
//
//   /// Remove background and add a new background color
//   Future<Uint8List?> removeBackgroundWithColor(
//       Uint8List imageBytes, {
//         Color bgColor = Colors.white,
//       }) async {
//     try {
//       if (!_isInitialized) {
//         await initialize();
//       }
//
//       // First remove background
//       final ui.Image? noBgImage = await BackgroundRemover.instance.removeBg(imageBytes);
//       if (noBgImage == null) return null;
//
//       // Convert to bytes
//       final byteData = await noBgImage.toByteData(format: ui.ImageByteFormat.png);
//       if (byteData == null) return null;
//
//       final noBgBytes = byteData.buffer.asUint8List();
//
//       // Add new background color
//       final ui.Image? withBgImage = (await BackgroundRemover.instance.addBackground(
//         image: noBgBytes,
//         bgColor: bgColor,
//       )) as ui.Image?;
//
//       if (withBgImage == null) return null;
//
//       final finalByteData = await withBgImage.toByteData(format: ui.ImageByteFormat.png);
//       return finalByteData?.buffer.asUint8List();
//     } catch (e) {
//       print('❌ Background removal with color error: $e');
//       return null;
//     }
//   }
//
//   /// Optimize face crop by removing background and trimming
//   Future<Uint8List> processFaceImage(Uint8List faceCrop) async {
//     try {
//       // First remove background
//       final Uint8List? noBgBytes = await removeBackground(faceCrop);
//
//       if (noBgBytes == null) {
//         print('⚠️ Background removal failed, returning original');
//         return faceCrop;
//       }
//
//       // Trim transparent pixels to get tighter crop
//       final trimmed = _trimTransparent(noBgBytes);
//
//       return trimmed;
//     } catch (e) {
//       print('❌ Face image processing error: $e');
//       return faceCrop;
//     }
//   }
//
//   /// Trim transparent pixels from image
//   Uint8List _trimTransparent(Uint8List bytes) {
//     try {
//       final image = img.decodeImage(bytes);
//       if (image == null) return bytes;
//
//       int minX = image.width;
//       int minY = image.height;
//       int maxX = 0;
//       int maxY = 0;
//       bool foundPixel = false;
//
//       for (int y = 0; y < image.height; y++) {
//         for (int x = 0; x < image.width; x++) {
//           final pixel = image.getPixel(x, y);
//           final a = pixel.a; // Alpha channel
//
//           if (a > 10) { // Not transparent (alpha > 10/255)
//             foundPixel = true;
//             if (x < minX) minX = x;
//             if (y < minY) minY = y;
//             if (x > maxX) maxX = x;
//             if (y > maxY) maxY = y;
//           }
//         }
//       }
//
//       if (!foundPixel) {
//         return bytes;
//       }
//
//       // Crop the image
//       final cropped = img.copyCrop(
//         image,
//         x: minX,
//         y: minY,
//         width: maxX - minX + 1,
//         height: maxY - minY + 1,
//       );
//
//       return Uint8List.fromList(img.encodePng(cropped));
//     } catch (e) {
//       print("Error trimming transparent pixels: $e");
//       return bytes;
//     }
//   }
// }