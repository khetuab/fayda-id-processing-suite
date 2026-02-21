import 'dart:typed_data';
import 'dart:io';
import 'dart:math';
import 'package:google_mlkit_selfie_segmentation/google_mlkit_selfie_segmentation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

class ImageUtils {
  static final SelfieSegmenter _segmenter = SelfieSegmenter(
    mode: SegmenterMode.single,
    enableRawSizeMask: true,
  );

  /// Remove background aggressively and return PNG with transparency.
  static Future<Uint8List> removeBackgroundUint8(
    Uint8List pngBytes, {
    bool convertToGrayscale = true,
  }) async {
    final original = img.decodeImage(pngBytes)!;

    final dir = await getTemporaryDirectory();
    final tempFile =
        File('${dir.path}/seg_${DateTime.now().millisecondsSinceEpoch}.png');
    await tempFile.writeAsBytes(pngBytes);

    final inputImage = InputImage.fromFilePath(tempFile.path);
    final maskResult = await _segmenter.processImage(inputImage);

    try {
      await tempFile.delete();
    } catch (_) {}

    if (maskResult == null || maskResult.confidences == null) {
      return _removeBackgroundFallback(pngBytes,
          convertToGrayscale: convertToGrayscale);
    }

    final confidences = maskResult.confidences!;
    final mwidth = maskResult.width!;
    final mheight = maskResult.height!;

    final out = img.Image.from(original);

    const double keepThreshold = 0.55;
    const double softRange = 0.15;

    for (int y = 0; y < original.height; y++) {
      for (int x = 0; x < original.width; x++) {
        final maskX =
            (x * mwidth / original.width).toInt().clamp(0, mwidth - 1);
        final maskY =
            (y * mheight / original.height).toInt().clamp(0, mheight - 1);
        final idx = maskY * mwidth + maskX;

        final confidence = confidences[idx];

        // 🧠 Soft alpha (prevents holes in white areas)
        int alpha;
        if (confidence >= keepThreshold + softRange) {
          alpha = 255;
        } else if (confidence <= keepThreshold - softRange) {
          alpha = 0;
        } else {
          alpha =
              (((confidence - (keepThreshold - softRange)) / (2 * softRange)) *
                      255)
                  .clamp(0, 255)
                  .toInt();
        }

        if (alpha == 0) {
          out.setPixelRgba(x, y, 0, 0, 0, 0);
        } else {
          final pixel = original.getPixel(x, y);

          if (convertToGrayscale) {
            final gray =
                (pixel.r * 0.299 + pixel.g * 0.587 + pixel.b * 0.114).toInt();
            out.setPixelRgba(x, y, gray, gray, gray, alpha);
          } else {
            out.setPixelRgba(x, y, pixel.r, pixel.g, pixel.b, alpha);
          }
        }
      }
    }

    return Uint8List.fromList(img.encodePng(out));
  }

  /// Fallback method using SAFE edge-only color removal
  static Uint8List _removeBackgroundFallback(
    Uint8List pngBytes, {
    bool convertToGrayscale = false,
  }) {
    final original = img.decodeImage(pngBytes)!;
    final out = img.Image(width: original.width, height: original.height);

    final edgeMarginX = (original.width * 0.08).toInt();
    final edgeMarginY = (original.height * 0.08).toInt();

    final bgSamples = <img.Pixel>[];

    for (int x = 0; x < original.width; x += 10) {
      bgSamples.add(original.getPixel(x, 0));
      bgSamples.add(original.getPixel(x, original.height - 1));
    }
    for (int y = 0; y < original.height; y += 10) {
      bgSamples.add(original.getPixel(0, y));
      bgSamples.add(original.getPixel(original.width - 1, y));
    }

    for (int y = 0; y < original.height; y++) {
      for (int x = 0; x < original.width; x++) {
        final pixel = original.getPixel(x, y);

        final isNearEdge = x < edgeMarginX ||
            y < edgeMarginY ||
            x > original.width - edgeMarginX ||
            y > original.height - edgeMarginY;

        bool isBackground = false;

        if (isNearEdge) {
          for (final bg in bgSamples) {
            if (_colorDistance(pixel, bg) < 45) {
              isBackground = true;
              break;
            }
          }
        }

        final alpha = isBackground ? 0 : 255;

        if (convertToGrayscale && alpha == 255) {
          final gray =
              (pixel.r * 0.299 + pixel.g * 0.587 + pixel.b * 0.114).toInt();
          out.setPixelRgba(x, y, gray, gray, gray, alpha);
        } else {
          out.setPixelRgba(x, y, pixel.r, pixel.g, pixel.b, alpha);
        }
      }
    }

    return Uint8List.fromList(img.encodePng(out));
  }

  static Future<bool> verifyTransparency(Uint8List imageBytes) async {
    try {
      final image = img.decodeImage(imageBytes);
      if (image == null) return false;
      bool hasTransparency = false;
      for (int y = 0; y < image.height; y++) {
        for (int x = 0; x < image.width; x++) {
          final pixel = image.getPixel(x, y);
          if (pixel.a < 255) {
            hasTransparency = true;
            break;
          }
        }
        if (hasTransparency) break;
      }
      print('🔍 [Verify] Image has transparency: $hasTransparency');
      return hasTransparency;
    } catch (e) {
      print('❌ [Verify] Error checking transparency: $e');
      return false;
    }
  }

  /// Fallback metho
  static double _colorDistance(img.Pixel c1, img.Pixel c2) {
    final r = c1.r - c2.r;
    final g = c1.g - c2.g;
    final b = c1.b - c2.b;
    return sqrt(r * r + g * g + b * b);
  }
}
