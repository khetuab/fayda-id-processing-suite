import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:idmaf/new/services/face_service.dart';
import 'package:idmaf/new/services/tesseract_amharic_ocr.dart';
import 'package:pdf_render/pdf_render.dart';
import 'package:image/image.dart' as img;
import 'bc_service.dart';
import 'controller.dart';
import 'ocr_service.dart';
import 'barcode_service.dart';
import 'image_utils.dart';
import '../models/id_card_model.dart';
import 'package:path_provider/path_provider.dart';

class PdfProcessor {
  final OcrService ocrService;
  final BarcodeService barcodeService;
  static  String barcodeNum = '';
  final TesseractAmharicOCR amharicOcr = TesseractAmharicOCR();
  final TesseractAmharicOCR englishOcr = TesseractAmharicOCR();
  PdfProcessor({required this.ocrService, required this.barcodeService});
  final controller = FormController.instance;
  late Uint8List cachedPagePng;

  Uint8List get pagePng => cachedPagePng;
  Future<void> preparePage(File pdfFile) async {
    cachedPagePng = await renderPdfPageToPngBytes(
      pdfFile,
      dpi: 200,
    );
  }

  Future<Uint8List> renderPdfPageToPngBytes(
      File pdfFile, {
        int pageNumber = 1,
        double dpi = 100.0,
      }) async {
    final doc = await PdfDocument.openFile(pdfFile.path);
    try {
      // get the page
      final page = await doc.getPage(pageNumber);

      // scale from 72 DPI (PDF points) to requested DPI
      final scale = dpi / 72.0;
      final fullWidth = (page.width * scale).toInt();
      final fullHeight = (page.height * scale).toInt();

      // render the full page (x/y = 0, width/height = fullWidth/fullHeight)
      final pageImage = await page.render(
        x: 0,
        y: 0,
        width: fullWidth,
        height: fullHeight,
        fullWidth: fullWidth.toDouble(),
        fullHeight: fullHeight.toDouble(),
        backgroundFill: true,
      );

      final pixels = pageImage.pixels;
      final w = pageImage.width;
      final h = pageImage.height;

      final im = img.Image.fromBytes(
        width: w,
        height: h,
        bytes: pixels.buffer, // ByteBuffer required by Image.fromBytes
        order: img.ChannelOrder.rgba,
      );

      // Encode to PNG bytes
      final pngBytes = img.encodePng(im);
      await doc.dispose();

      return Uint8List.fromList(pngBytes);
    } catch (e) {
      // Ensure document is disposed on error too
      try {
        await doc.dispose();
      } catch (_) {}
      rethrow;
    }
  }

  Uint8List cropByPercent(Uint8List pngBytes, double px, double py, double pw, double ph) {
    final decoded = img.decodeImage(pngBytes)!;
    final sw = decoded.width;
    final sh = decoded.height;
    final x = (px * sw).round();
    final y = (py * sh).round();
    final w = (pw * sw).round();
    final h = (ph * sh).round();
    final cropped = img.copyCrop(decoded, x: x, y: y, width: w, height: h);
    return Uint8List.fromList(img.encodePng(cropped));
  }

  Uint8List cropFromDecoded(
      img.Image decoded,
      double px,
      double py,
      double pw,
      double ph,
      ) {
    final x = (px * decoded.width).round();
    final y = (py * decoded.height).round();
    final w = (pw * decoded.width).round();
    final h = (ph * decoded.height).round();

    final cropped = img.copyCrop(
      decoded,
      x: x,
      y: y,
      width: w,
      height: h,
    );

    return Uint8List.fromList(img.encodePng(cropped));
  }

  Uint8List cropRawFromDecoded(
      img.Image decoded,
      double px,
      double py,
      double pw,
      double ph,
      ) {
    final x = (px * decoded.width).round();
    final y = (py * decoded.height).round();
    final w = (pw * decoded.width).round();
    final h = (ph * decoded.height).round();

    final cropped = img.copyCrop(
      decoded,
      x: x,
      y: y,
      width: w,
      height: h,
    );
    return Uint8List.fromList(cropped.getBytes());
  }


  Future<Map<String, dynamic>?> locateExpiryDatePositionFromPng(
      Uint8List pagePng) async {
    const stepX = 0.05;
    const stepY = 0.05;
    const cropWidth = 0.25;
    const cropHeight = 0.06;

    for (double y = 0; y <= 1.0 - cropHeight; y += stepY) {
      for (double x = 0; x <= 1.0 - cropWidth; x += stepX) {
        final crop = cropByPercent(pagePng, x, y, cropWidth, cropHeight);
        final text = await ocrService.recognizeTextFromBytes(crop);
        final cleanText = text.replaceAll('\n', ' ').trim();

        final dateInfo = _extractDatePair(cleanText);
        if (dateInfo != null) {
          return {
            'position': [x, y, cropWidth, cropHeight],
            'gregorian': dateInfo['gregorian'],
            'ethiopian': dateInfo['ethiopian'],
          };
        }
      }
    }
    return null;
  }

  Future<List<double>?> locateBarcodePositionFromPng( Uint8List pagePng) async {
    const stepX = 0.05;
    const stepY = 0.05;
    const cropWidth = 0.20;
    const cropHeight = 0.08;

    for (double y = 0; y <= 1.0 - cropHeight; y += stepY) {
      for (double x = 0; x <= 1.0 - cropWidth; x += stepX) {
        final crop = cropByPercent(pagePng, x, y, cropWidth, cropHeight);
        final barResults = await barcodeService.scanFromBytes(crop);

        if (barResults.isNotEmpty) {
          barcodeNum = barResults.first.rawValue!;
          return [x, y, cropWidth, cropHeight];
        }
      }
    }
    return null;
  }

  // Future<void> saveImageToGallery(Uint8List bytes, String fileName) async {
  //   try {
  //     Directory? directory;
  //
  //     if (Platform.isAndroid) {
  //       directory = Directory('/storage/emulated/0/Pictures');
  //     } else {
  //       directory = await getApplicationDocumentsDirectory();
  //     }
  //
  //     if (!await directory.exists()) {
  //       await directory.create(recursive: true);
  //     }
  //
  //     final filePath =
  //         '${directory.path}/$fileName${DateTime.now().millisecondsSinceEpoch}.png';
  //
  //     final file = File(filePath);
  //     await file.writeAsBytes(bytes);
  //
  //     print('✅ Image saved to: $filePath');
  //   } catch (e) {
  //     print('❌ Error saving image: $e');
  //   }
  // }
  //

  Map<String, String>? _extractDatePair(String text) {
    final exactPattern = RegExp(r'(\d{4}/\d{2}/\d{2})\|(\d{4}/[A-Za-z]{3}/\d{2})');
    var match = exactPattern.firstMatch(text);
    if (match != null) {
      return {
        'gregorian': match.group(1)!,
        'ethiopian': match.group(2)!,
      };
    }

    final pipePattern = RegExp(r'(\d{4}[/\-\.]\d{1,2}[/\-\.]\d{1,2})\s*\|\s*(\d{4}[/\-\.](\d{1,2}|[A-Za-z]{3})[/\-\.]\d{1,2})');
    match = pipePattern.firstMatch(text);
    if (match != null) {
      return {
        'gregorian': match.group(1)!,
        'ethiopian': match.group(2)!,
      };
    }

    final datePattern = RegExp(r'\d{4}[/\-\.](\d{1,2}|[A-Za-z]{3})[/\-\.]\d{1,2}');
    final dates = datePattern.allMatches(text).toList();

    if (dates.length >= 2) {
      return {
        'gregorian': dates[0].group(0)!,
        'ethiopian': dates[1].group(0)!,
      };
    }

    return null;
  }

  Uint8List rotate90(Uint8List bytes) {
    final original = img.decodeImage(bytes);
    if (original == null) return bytes;

    final rotated = img.copyRotate(original, angle: 90);
    return Uint8List.fromList(img.encodePng(rotated));
  }

  Uint8List ensureMinSize(Uint8List bytes) {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return bytes;

    int width = decoded.width;
    int height = decoded.height;

    if (width < 32 || height < 32) {
      final resized = img.copyResize(
        decoded,
        width: width < 32 ? 64 : width,
        height: height < 32 ? 64 : height,
        interpolation: img.Interpolation.cubic,
      );

      return Uint8List.fromList(img.encodePng(resized));
    }

    return bytes;
  }

  Future<Uint8List> preprocessForNumbers(Uint8List imageBytes) async {
    final decoded = img.decodeImage(imageBytes);
    if (decoded == null) return imageBytes;

    // Convert to grayscale
    final grayscale = img.grayscale(decoded);

    // Apply adaptive threshold to make numbers clearer
    final thresholded = img.adjustColor(grayscale,
      contrast: 2.0,
      brightness: 10,
    );

    // Increase size if too small
    if (decoded.width < 100 || decoded.height < 30) {
      final resized = img.copyResize(thresholded,
          width: decoded.width * 2,
          height: decoded.height * 2,
          interpolation: img.Interpolation.cubic
      );
      return Uint8List.fromList(img.encodePng(resized));
    }

    return Uint8List.fromList(img.encodePng(thresholded));
  }



  Future<IDCardModel> processPdfFromPng(Uint8List pagePng) async {
    FaceService faceService = FaceService();
    final output = IDCardModel();
    final img.Image decodedPage = img.decodeImage(pagePng)!;
    final fullNameRect =  [0.056666,0.61092, 0.385666, 0.039675];
    final amfullNameRect =  [0.056666,0.579351, 0.385666, 0.036689];
    final dobRect =  [0.056666,0.665102, 0.385666, 0.036689];

    final issueDateRectyy = [0.43500, 0.168941, 0.053333, 0.335324];
    final issueDateRect = [0.43500, 0.168941, 0.053333, 0.171075];
    final issueDateRecte = [0.43500, 0.34982, 0.053333, 0.154863];
    final fanNumberRect = [0.12233, 0.805034, 0.24300, 0.0460194];
    final nationalityRectEn = [0.62200, 0.7329, 0.1706, 0.034129];
    final nationalityRectAm = [0.5440, 0.7329, 0.073333, 0.034515];
    final sexRect = [0.056666,0.71629, 0.385666, 0.03412];
    final expiryRect = [0.060000, 0.767918, 0.333333, 0.04394];

    final kaRect = [0.5453333, 0.787969, 0.45166, 0.034129];
    final keRect = [0.5453333, 0.81783, 0.45166, 0.034129];
    final zaRect = [0.5453333, 0.84257, 0.45166, 0.034129];
    final zeRect = [0.5453333, 0.87244, 0.45166, 0.034129];
    final waRect = [0.5453333, 0.90102, 0.45166, 0.034129];
    final weRect = [0.5453333, 0.92660, 0.45166, 0.034129];

    final realphotoRect = [0.14000, 0.14078, 0.2433, 0.39249];
    final finnRect = [0.8100, 0.6420 , 0.14400, 0.045648];
    final qrcodeRect = [0.549333, 0.115187, 0.398666, 0.504266];
    final barcodeRect = [0.143333, 0.85324, 0.19166, 0.0533327];
    final phoneRect = [0.54800, 0.6646, 0.15333, 0.031569];

    final regionRect = [0.04, 0.40, 0.40, 0.06];
    final addressRect = [0.05, 0.14, 0.50, 0.16];
    final serialRect = [0.65, 0.3, 0.2, 0.08];
    final qrRect =[0.55338, 0.141156, 0.3664, 0.4689];

    try {
      final nameCrop = cropFromDecoded(decodedPage, fullNameRect[0], fullNameRect[1], fullNameRect[2], fullNameRect[3]);
      final nameCropA = cropFromDecoded(decodedPage, amfullNameRect[0], amfullNameRect[1], amfullNameRect[2], amfullNameRect[3]);
      output.fullNameEnglish = await englishOcr.extractEnglishText(nameCrop);
      String amharicRaw = '';
      try {
        await TesseractAmharicOCR.initialize();
        amharicRaw = await amharicOcr.extractAmharicText(nameCropA);
        if (amharicRaw.isNotEmpty) {
          amharicRaw = _cleanAmharicText(amharicRaw);
        }
      } catch (e) {
        try {
          amharicRaw = await amharicOcr.extractTextWithConfig(nameCropA, psm: 6);
        } catch (e2) {
          amharicRaw = await ocrService.recognizeTextFromBytes(nameCropA);
        }
      }
      output.fullNameAmharic = _extractLikelyAmharicName(amharicRaw);


      final dobCrop = cropFromDecoded(decodedPage, dobRect[0], dobRect[1], dobRect[2], dobRect[3]);
      final dobText = await englishOcr.extractEnglishText(dobCrop);
      final parsedDates = _extractAllDates(dobText);
      if (parsedDates.isNotEmpty) {
        output.dateOfBirthGregorian = parsedDates[0];
        if (parsedDates.length > 1) {
          output.dateOfBirthEthiopian = parsedDates[1];
        } else {
          output.dateOfBirthEthiopian = '';
        }
      } else {
        output.dateOfBirthGregorian = '';
        output.dateOfBirthEthiopian = '';
      }

      final sexCrop = cropFromDecoded(decodedPage, sexRect[0], sexRect[1], sexRect[2], sexRect[3]);
      String rawSexText = (await englishOcr.extractEnglishText(sexCrop)).trim();
      final nationalityEnCrop = cropFromDecoded(decodedPage, nationalityRectEn[0], nationalityRectEn[1], nationalityRectEn[2], nationalityRectEn[3]);
      output.nationalityEnglish = await englishOcr.extractEnglishText(nationalityEnCrop);
      final nationalityAmCrop = cropFromDecoded(decodedPage, nationalityRectAm[0], nationalityRectAm[1], nationalityRectAm[2], nationalityRectAm[3]);
      output.nationalityAmharic = await amharicOcr.extractAmharicText(nationalityAmCrop);

      final kaCrop = cropFromDecoded(decodedPage, kaRect[0], kaRect[1], kaRect[2], kaRect[3]);
      output.kililAm =  await amharicOcr.extractAmharicText(kaCrop);

      final keCrop = cropFromDecoded(decodedPage, keRect[0], keRect[1], keRect[2], keRect[3]);
      output.kililEn =  await englishOcr.extractEnglishText(keCrop);

      final realphotoCrop = cropFromDecoded(decodedPage, realphotoRect[0], realphotoRect[1], realphotoRect[2], realphotoRect[3]);

      final zaCrop = cropFromDecoded(decodedPage, zaRect[0], zaRect[1], zaRect[2], zaRect[3]);
      output.zoneAm =  await amharicOcr.extractAmharicText(zaCrop);

      final zeCrop = cropFromDecoded(decodedPage, zeRect[0], zeRect[1], zeRect[2], zeRect[3]);
      output.zoneEn =  await englishOcr.extractEnglishText(zeCrop);

      final weCrop = cropFromDecoded(decodedPage, weRect[0], weRect[1], weRect[2], weRect[3]);
      output.weredaEn =  await englishOcr.extractEnglishText(weCrop);

      final waCrop = cropFromDecoded(decodedPage, waRect[0], waRect[1], waRect[2], waRect[3]);
      output.weredaAm =  await amharicOcr.extractAmharicText(waCrop);

      final finnCrop = cropFromDecoded(decodedPage, finnRect[0], finnRect[1], finnRect[2], finnRect[3]);
      output.finNumber =  await englishOcr.extractNumbersOnly(finnCrop);

      final issuecropy = cropFromDecoded(decodedPage, issueDateRectyy[0], issueDateRectyy[1], issueDateRectyy[2], issueDateRectyy[3]);
      final rotatedCrop = rotate90(issuecropy);
      final safeCrop = ensureMinSize(rotatedCrop);
      final issueText = await englishOcr.extractEnglishText(safeCrop);

      final cleanedText = issueText.replaceAll(RegExp(r'\s*/\s*'), '/');
      List<String> _extractAllDatees(String text) {
        final dateRegex = RegExp(
          r'\b\d{4}/(?:\d{2}|[A-Za-z]{3})/\d{2}\b',
        );

        return dateRegex
            .allMatches(text)
            .map((m) => m.group(0)!)
            .toList();
      }

      final parsedDatesIssue = _extractAllDatees(cleanedText);

      if (parsedDatesIssue.length >= 2) {
        output.givenDateEt = parsedDatesIssue[0];
        output.givenDate = parsedDatesIssue[1];
      } else if (parsedDatesIssue.length == 1) {
        output.givenDateEt = parsedDatesIssue[0];
        output.givenDate = '';
      } else {
        output.givenDateEt = '';
        output.givenDate = '';
      }

      print('ET: ${output.givenDateEt}');
      print('EN: ${output.givenDate}');

      output.sex = _formatGenderText(rawSexText);
      final fanNumberCrop = cropFromDecoded(decodedPage, fanNumberRect[0], fanNumberRect[1], fanNumberRect[2], fanNumberRect[3]);
      final enhanced = await preprocessForNumbers(fanNumberCrop);
      output.fanNumber = await englishOcr.extractEnglishText(fanNumberCrop);
      final expiryCrop = cropFromDecoded(decodedPage, expiryRect[0], expiryRect[1], expiryRect[2], expiryRect[3]);
      String rawExpiryText = (await ocrService.recognizeTextFromBytes(expiryCrop)).trim();
      output.expiryDate = _extractExpiryDates(rawExpiryText);

      final barcodeCrop = cropFromDecoded(decodedPage, barcodeRect[0], barcodeRect[1], barcodeRect[2], barcodeRect[3]);
      final safeCropfbar = ensureMinSize(barcodeCrop);
      Uint8List? barcodeBytes;

      final fan = output.fanNumber?.trim();

      if (fan != null && fan.isNotEmpty) {
        try {
          barcodeBytes = await buildBarcodeFile(fan);

          if (barcodeBytes.isNotEmpty) {
            output.barcodeImageBytes = barcodeBytes;
          } else {
            output.barcodeImageBytes = null;
          }
        } catch (e) {
          output.barcodeImageBytes = null;
        }
      } else {
        output.barcodeImageBytes = null;
      }



      final barResults = await barcodeService.scanFromBytes(safeCropfbar);
      if (barResults.isNotEmpty) {
        output.cardNumber = barResults.first.rawValue ?? '';
      } else {
        output.cardNumber = (await ocrService.recognizeTextFromBytes(barcodeCrop)).replaceAll(RegExp(r'\s+'), '');
      }

      final qrcodeCrop = cropFromDecoded(decodedPage, qrcodeRect[0], qrcodeRect[1], qrcodeRect[2], qrcodeRect[3]);
      output.qrcodeImageBytes = qrcodeCrop;

      final facecropp = cropFromDecoded(decodedPage, realphotoRect[0], realphotoRect[1], realphotoRect[2], realphotoRect[3]);
      Uint8List finalFaceCrop = facecropp;

      final faceBounds =
      await faceService.detectFaceBounds(facecropp);

      if (faceBounds != null) {
        final decoded = img.decodeImage(facecropp);

        if (decoded != null) {
          const double targetAspect = 3 / 4; // ID portrait ratio

          final faceCenterX =
              faceBounds.left + faceBounds.width / 2;
          final faceCenterY =
              faceBounds.top + faceBounds.height / 2;

          // Make height based on face size
          double cropHeight = faceBounds.height * 2.2;
          double cropWidth = cropHeight * targetAspect;

          // Center horizontally
          double cropX = faceCenterX - cropWidth / 2;

          // Shift slightly upward (ID style)
          double cropY = faceCenterY - cropHeight * 0.45;

          // Boundary correction (NO resizing, only shifting)
          if (cropX < 0) cropX = 0;
          if (cropY < 0) cropY = 0;

          if (cropX + cropWidth > decoded.width) {
            cropX = decoded.width - cropWidth;
          }

          if (cropY + cropHeight > decoded.height) {
            cropY = decoded.height - cropHeight;
          }

          final cropped = img.copyCrop(
            decoded,
            x: cropX.toInt(),
            y: cropY.toInt(),
            width: cropWidth.toInt(),
            height: cropHeight.toInt(),
          );

          finalFaceCrop =
              Uint8List.fromList(img.encodePng(cropped));
        }
      }





      final processedPhotoBytes = await ImageUtils.removeBackgroundUint8(finalFaceCrop);
      final rprocessedPhotoBytes = await ImageUtils.removeBackgroundUint8(realphotoCrop);

      final hasTransparency = await ImageUtils.verifyTransparency(processedPhotoBytes);

      if (!hasTransparency) {
        print('⚠️ Warning: Processed image has no transparency!');
      }

      final dir = await getTemporaryDirectory();
      final dir2 = await getTemporaryDirectory();
      final photoFile = File('${dir.path}/extracted_photo.png');
      final photoFiler = File('${dir2.path}/extracted_photo.png');
      await photoFile.writeAsBytes(processedPhotoBytes);

      await photoFiler.writeAsBytes(rprocessedPhotoBytes);
      output.photoPath = photoFiler.path;

      final cleanedPhoto = trimTransparent(processedPhotoBytes);
      output.processedPhotoBytes = cleanedPhoto; // Add this line

      final phoneCrop = cropFromDecoded(decodedPage, phoneRect[0], phoneRect[1], phoneRect[2], phoneRect[3]);
      output.phoneNumber = (await englishOcr.extractEnglishText(phoneCrop)).trim();
      final regionCrop = cropFromDecoded(decodedPage, regionRect[0], regionRect[1], regionRect[2], regionRect[3]);
      output.region = (await ocrService.recognizeTextFromBytes(regionCrop)).trim();

      final addressCrop = cropFromDecoded(decodedPage, addressRect[0], addressRect[1], addressRect[2], addressRect[3]);
      output.address = (await ocrService.recognizeTextFromBytes(addressCrop)).trim();

      final snCrop = cropFromDecoded(decodedPage, serialRect[0], serialRect[1], serialRect[2], serialRect[3]);
      output.serialNumber = (await ocrService.recognizeTextFromBytes(snCrop)).trim();

      final qrCrop = cropFromDecoded(decodedPage, qrRect[0], qrRect[1], qrRect[2], qrRect[3]);
      final qrResults = await barcodeService.scanFromBytes(qrCrop);
      if (qrResults.isNotEmpty) {
        output.qrCodeData = qrResults.first.rawValue;
      }

    } catch (e) {
      print('pdf processing error: $e');
    }

    return output;
  }

  String _cleanAmharicText(String rawText) {
    if (rawText.isEmpty) return '';

    // Remove common OCR artifacts
    String cleaned = rawText
        .replaceAll(RegExp(r'[|\\]'), '') // Remove pipe characters
        .replaceAll(RegExp(r'\s+'), ' ') // Normalize spaces
        .trim();

    // Filter out non-Amharic characters (basic filtering)
    final amharicPattern = RegExp(r'[\u1200-\u137F\s]+');
    final matches = amharicPattern.allMatches(cleaned);

    if (matches.isEmpty) return cleaned;

    // Join all Amharic character sequences
    return matches.map((m) => m.group(0)).join(' ').trim();
  }

  String _extractLikelyAmharicName(String raw) {
    if (raw.isEmpty) return '';

    // Split into lines
    final lines = raw.split('\n');

    // Look for lines with Amharic characters
    final amharicLines = lines.where((line) {
      return RegExp(r'[\u1200-\u137F]').hasMatch(line) && line.trim().isNotEmpty;
    }).toList();

    if (amharicLines.isEmpty) return '';

    // Heuristic: Usually the Amharic name is the longest line with Amharic text
    String longestLine = amharicLines.reduce((a, b) => a.length > b.length ? a : b);

    // Remove any English characters that might have been mixed in
    final cleaned = longestLine.replaceAll(RegExp(r'[A-Za-z]'), '').trim();

    // If cleaned is too short, try the first line instead
    if (cleaned.length < 2 && amharicLines.isNotEmpty) {
      return amharicLines.first.trim();
    }

    return cleaned;
  }

  String _extractExpiryDates(String rawText) {


    // Clean the text
    String cleanText = rawText.replaceAll('\n', ' ').replaceAll(RegExp(r'\s+'), ' ').trim();

    print("Raw expiry text: '$rawText'");
    print("Cleaned expiry text: '$cleanText'");

    // Look for "Date of Expiry" or similar labels and extract everything after it
    final expiryLabels = [
      'Date of Expiry',
      'Expiry Date',
      'Expiration Date',
      'Valid Until',
      'Valid Till',
      'የሚያበቃበት ቀን',
      'ያበቃል',
      'ተጠቃሚ እስከ'
    ];

    String textAfterLabel = cleanText;
    bool foundLabel = false;

    for (final label in expiryLabels) {
      final labelIndex = cleanText.indexOf(label);
      if (labelIndex != -1) {
        // Found the label, take everything after it
        textAfterLabel = cleanText.substring(labelIndex + label.length).trim();
        foundLabel = true;
        break;
      }
    }

    // If no label found, use the original text
    if (!foundLabel) {
      textAfterLabel = cleanText;
    }
    final datePattern = RegExp(r'\d{4}[/\-\.](\d{1,2}|[A-Za-z]{3,})[/\-\.]\d{1,2}');
    final dates = datePattern.allMatches(textAfterLabel).toList();

    if (dates.length >= 2) {
      // Take the first two dates found after the label
      final firstDate = dates[0].group(0)!;
      final secondDate = dates[1].group(0)!;

      return '$firstDate | $secondDate';
    } else if (dates.length == 1) {
      // Only one date found
      return dates[0].group(0)!;
    }

    // Fallback: if no dates found after label, try the entire text
    final fallbackDates = datePattern.allMatches(cleanText).toList();
    if (fallbackDates.length >= 2) {
      final firstDate = fallbackDates[0].group(0)!;
      final secondDate = fallbackDates[1].group(0)!;
      return '$firstDate | $secondDate';
    } else if (fallbackDates.length == 1) {
      return fallbackDates[0].group(0)!;
    }

    return 'Not found';
  }

  String _formatGenderText(String rawText) {
    // Clean the text - remove extra spaces and newlines
    String cleanText = rawText.replaceAll(RegExp(r'\s+'), ' ').trim().toLowerCase();

    // Check for female patterns
    if (cleanText.toLowerCase().contains('female')  ) {
      return 'Female | ሴት';
    }
    if (cleanText.toLowerCase().contains('male')  ) {
      return 'Male | ወንድ';
    }
    // If no clear pattern found, try to extract just the gender part
    final words = cleanText.split(' ');
    for (final word in words) {
      if (word == 'male' ) {
        return 'Male | ወንድ';
      }
      if (word == 'female') {
        return 'Female | ሴት';
      }
    }

    return cleanText;
  }

  Map<String, String> parseOcrDatePair(String rawText) {

    // Try to find date patterns in the text
    final allMatches = _findAllDatePatterns(rawText);

    if (allMatches.isEmpty) {
      return {'gregorian': '', 'ethiopian': ''};
    }


    // Classify each date
    List<Map<String, dynamic>> classified = [];
    for (String match in allMatches) {
      final result = _classifyAndParseSingleDate(match);
      if (result['valid']) {
        classified.add(result);
      }
    }

    // Separate by type
    final gregorianDates = classified.where((c) => c['type'] == 'gregorian').toList();
    final ethiopianDates = classified.where((c) => c['type'] == 'ethiopian').toList();

    return {
      'gregorian': gregorianDates.isNotEmpty ? gregorianDates.first['normalized'] : '',
      'ethiopian': ethiopianDates.isNotEmpty ? ethiopianDates.first['normalized'] : '',
    };
  }

  String? parseGregorianDate(String input) {
    if (input.isEmpty) return null;

    // First, try to extract the month name BEFORE cleaning digits
    final monthPattern = RegExp(r'([A-Za-z]{3,4})');
    final monthMatch = monthPattern.firstMatch(input);
    String? monthName = monthMatch?.group(0);

    // Clean the input - but be careful with month names
    String cleaned = input
        .replaceAll(RegExp(r'\s+'), '')  // Remove all spaces
        .replaceAll('l', '/')            // Common OCR error for /
        .replaceAll('I', '/')            // Common OCR error for /
        .replaceAll('|', '/')            // Common OCR error for /
        .replaceAll('\\', '/')           // Common OCR error for /
        .trim();

    final patterns = [
      // Pattern 1: YYYY/MMM/DD (with month name)
      RegExp(r'^(\d{4})[/\-\.]?([A-Za-z]{3,4})[/\-\.]?(\d{1,2})$'),

      // Pattern 2: YYYY/MM/DD (with month number)
      RegExp(r'^(\d{4})[/\-\.]?(\d{1,2})[/\-\.]?(\d{1,2})$'),

      // Pattern 3: DD/MM/YYYY (European format)
      RegExp(r'^(\d{1,2})[/\-\.]?(\d{1,2})[/\-\.]?(\d{4})$'),

      // Pattern 4: YYYYMMMDD (compact with month name)
      RegExp(r'^(\d{4})([A-Za-z]{3,4})(\d{2})$'),

      // Pattern 5: YYYYMMDD (compact with month number)
      RegExp(r'^(\d{4})(\d{2})(\d{2})$'),

      // Pattern 6: MMM/DD/YYYY (American format with month name)
      RegExp(r'^([A-Za-z]{3,4})[/\-\.]?(\d{1,2})[/\-\.]?(\d{4})$'),
    ];

    // Try patterns with original month name first
    if (monthName != null) {
      for (final pattern in patterns) {
        final match = pattern.firstMatch(input); // Use original input
        if (match != null) {
          try {
            int year = 0, monthNum = 0, day = 0;
            bool isMonthName = false;
            String monthStr = "";

            if (pattern == patterns[0] || pattern == patterns[3]) {
              year = int.parse(match.group(1)!);
              monthStr = match.group(2)!.toLowerCase();
              day = int.parse(match.group(3)!);
              isMonthName = true;
            } else if (pattern == patterns[1] || pattern == patterns[4]) {
              // YYYY/MM/DD or YYYYMMDD
              year = int.parse(match.group(1)!);
              monthNum = int.parse(match.group(2)!);
              day = int.parse(match.group(3)!);
            } else if (pattern == patterns[2]) {
              // DD/MM/YYYY
              day = int.parse(match.group(1)!);
              monthNum = int.parse(match.group(2)!);
              year = int.parse(match.group(3)!);
            } else if (pattern == patterns[5]) {
              // MMM/DD/YYYY
              monthStr = match.group(1)!.toLowerCase();
              day = int.parse(match.group(2)!);
              year = int.parse(match.group(3)!);
              isMonthName = true;
            } else {
              continue;
            }

            // Validate year range for Gregorian dates
            if (year < 1900 || year > 2100) {
              continue;
            }

            // Parse month
            String monthAbbrev;
            if (isMonthName) {
              monthAbbrev = _parseGregorianMonthAbbrev(monthStr);
              monthNum = _monthAbbrevToNumber(monthAbbrev);
            } else {
              if (monthNum < 1 || monthNum > 12) {
                continue;
              }
              monthAbbrev = _parseGregorianMonthNumber(monthNum.toString());
            }

            // Validate day
            if (day < 1 || day > 31) {
              continue;
            }

            // Special validation for February
            if (monthNum == 2 && day > 29) {
              continue;
            }

            // Validate days in month
            final daysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
            if (monthNum >= 1 && monthNum <= 12 && day > daysInMonth[monthNum - 1]) {
              // Check for leap year for February
              if (monthNum == 2 && day == 29) {
                bool isLeapYear = (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
                if (!isLeapYear) {
                  continue;
                }
              } else {
                continue;
              }
            }

            // Format: YYYY/MMM/DD
            final result = '$year/$monthAbbrev/${day.toString().padLeft(2, '0')}';
            return result;

          } catch (e) {
            continue;
          }
        }
      }
    }

    for (final pattern in patterns) {
      final match = pattern.firstMatch(cleaned);
      if (match != null) {
        try {
          int year = 0, monthNum = 0, day = 0;
          bool isMonthName = false;
          String monthStr = "";

          // Determine which pattern matched and extract components
          if (pattern == patterns[0] || pattern == patterns[3]) {
            // YYYY/MMM/DD or YYYYMMMDD
            year = int.parse(match.group(1)!);
            monthStr = match.group(2)!.toLowerCase();
            day = int.parse(match.group(3)!);
            isMonthName = true;
          } else if (pattern == patterns[1] || pattern == patterns[4]) {
            // YYYY/MM/DD or YYYYMMDD
            year = int.parse(match.group(1)!);
            monthNum = int.parse(match.group(2)!);
            day = int.parse(match.group(3)!);
          } else if (pattern == patterns[2]) {
            // DD/MM/YYYY
            day = int.parse(match.group(1)!);
            monthNum = int.parse(match.group(2)!);
            year = int.parse(match.group(3)!);
          } else if (pattern == patterns[5]) {
            // MMM/DD/YYYY
            monthStr = match.group(1)!.toLowerCase();
            day = int.parse(match.group(2)!);
            year = int.parse(match.group(3)!);
            isMonthName = true;
          } else {
            continue;
          }

          // Validate year range for Gregorian dates
          if (year < 1900 || year > 2100) {
            continue;
          }

          // Parse month
          String monthAbbrev;
          if (isMonthName) {
            monthAbbrev = _parseGregorianMonthAbbrev(monthStr);
            monthNum = _monthAbbrevToNumber(monthAbbrev);
          } else {
            if (monthNum < 1 || monthNum > 12) {
              continue;
            }
            monthAbbrev = _parseGregorianMonthNumber(monthNum.toString());
          }

          // Validate day
          if (day < 1 || day > 31) {
            continue;
          }

          // Special validation for February
          if (monthNum == 2 && day > 29) {
            continue;
          }

          // Validate days in month
          final daysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
          if (monthNum >= 1 && monthNum <= 12 && day > daysInMonth[monthNum - 1]) {
            // Check for leap year for February
            if (monthNum == 2 && day == 29) {
              bool isLeapYear = (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
              if (!isLeapYear) {
                continue;
              }
            } else {
              continue;
            }
          }

          final result = '$year/$monthAbbrev/${day.toString().padLeft(2, '0')}';
          return result;

        } catch (e) {
          continue;
        }
      }
    }

    return null;
  }

  String? parseEthiopianDate(String input) {
    if (input.isEmpty) return null;

    String cleaned = input
        .replaceAll(RegExp(r'\s+'), '')  // Remove ALL spaces
        .replaceAll('l', '/')            // Common OCR error for /
        .replaceAll('I', '/')            // Common OCR error for /
        .replaceAll('|', '/')            // Common OCR error for /
        .replaceAll('\\', '/')           // Common OCR error for /
        .replaceAll('O', '0')            // OCR: O vs 0 (safe for Ethiopian dates)
        .replaceAll('o', '0')            // OCR: o vs 0
        .replaceAll('S', '5')            // OCR: S vs 5
        .replaceAll('s', '5')            // OCR: s vs 5
        .trim();

    final patterns = [
      // Pattern 1: YYYY/MM/DD (standard)
      RegExp(r'^(\d{4})[/\-\.](\d{1,2})[/\-\.](\d{1,2})$'),

      // Pattern 2: YYYYMMDD (compact)
      RegExp(r'^(\d{4})(\d{2})(\d{2})$'),

      // Pattern 3: Short year YY/MM/DD -> convert to YYYY
      RegExp(r'^(\d{2})[/\-\.](\d{1,2})[/\-\.](\d{1,2})$'),

      // Pattern 4: With possible spaces in year "20 18/02/15"
      RegExp(r'^(\d{2})\s*(\d{2})[/\-\.](\d{1,2})[/\-\.](\d{1,2})$'),

      // Pattern 5: Ethiopian year with prefix (ex: 1996/...)
      RegExp(r'^(1[0-9]{3})[/\-\.](\d{1,2})[/\-\.](\d{1,2})$'),

      // Pattern 6: Very flexible with mixed separators
      RegExp(r'^(\d{2,4})[/\-\.\s]?(\d{1,2})[/\-\.\s]?(\d{1,2})$'),

      // Pattern 7: Ethiopian year range 1900-2100
      RegExp(r'^(19\d{2}|20\d{2}|21\d{2})[/\-\.](\d{1,2})[/\-\.](\d{1,2})$'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(cleaned);
      if (match != null) {
        try {
          int year = 0, month = 0, day = 0;

          // Determine pattern and extract components
          if (pattern == patterns[0] || pattern == patterns[1] ||
              pattern == patterns[5] || pattern == patterns[6] || pattern == patterns[7]) {
            // Standard patterns
            year = int.parse(match.group(1)!);
            month = int.parse(match.group(2)!);
            day = int.parse(match.group(3)!);
          } else if (pattern == patterns[2]) {
            // Short year: YY -> YYYY
            int shortYear = int.parse(match.group(1)!);
            year = 2000 + shortYear; // Ethiopian years are usually 2000+
            month = int.parse(match.group(2)!);
            day = int.parse(match.group(3)!);
          } else if (pattern == patterns[3]) {
            // Split year like "20 18" -> "2018"
            year = int.parse(match.group(1)! + match.group(2)!);
            month = int.parse(match.group(3)!);
            day = int.parse(match.group(4)!);
          } else {
            continue;
          }

          // Validate Ethiopian year range (usually 1990-2100 for Ethiopian calendar)
          if (year < 1990 || year > 2100) {
            continue;
          }

          // Ethiopian months: 1-13 (13th month is Pagume)
          if (month < 1 || month > 13) {
            continue;
          }

          // Validate days
          if (day < 1) {
            continue;
          }

          if (month == 13) {
            // Pagume has 5-6 days (6 in leap year)
            if (day > 6) {
              continue;
            }
          } else if (day > 30) {
            // All other months have 30 days
            continue;
          }

          // Format: YYYY/MM/DD
          final result = '$year/${month.toString().padLeft(2, '0')}/${day.toString().padLeft(2, '0')}';
          return result;

        } catch (e) {
          continue;
        }
      }
    }

    // Fallback: Try to extract numbers and reconstruct
    final allNumbers = RegExp(r'\d+').allMatches(input).map((m) => m.group(0)!).toList();
    if (allNumbers.length >= 3) {
      try {
        // Try different combinations
        for (int i = 0; i <= allNumbers.length - 3; i++) {
          String yearStr = allNumbers[i];
          String monthStr = allNumbers[i + 1];
          String dayStr = allNumbers[i + 2];

          // Try to parse as Ethiopian date
          int year = int.parse(yearStr);
          if (yearStr.length == 2) year = 2000 + year;

          int month = int.parse(monthStr);
          int day = int.parse(dayStr);

          // Validate
          if (year >= 1990 && year <= 2100 &&
              month >= 1 && month <= 13 &&
              day >= 1 && day <= (month == 13 ? 6 : 30)) {

            final result = '$year/${month.toString().padLeft(2, '0')}/${day.toString().padLeft(2, '0')}';
            return result;
          }
        }
      } catch (e) {
      }
    }

    return null;
  }

// Helper function to convert month abbreviation to number
  int _monthAbbrevToNumber(String monthAbbrev) {
    final monthMap = {
      'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4,
      'May': 5, 'Jun': 6, 'Jul': 7, 'Aug': 8,
      'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12,
    };
    return monthMap[monthAbbrev] ?? 1;
  }

// Enhanced month abbreviation parser
  String _parseGregorianMonthAbbrev(String monthAbbrev) {
    final monthMap = {
      // Correct abbreviations
      'jan': 'Jan', 'feb': 'Feb', 'mar': 'Mar', 'apr': 'Apr',
      'may': 'May', 'jun': 'Jun', 'jul': 'Jul', 'aug': 'Aug',
      'sep': 'Sep', 'oct': 'Oct', 'nov': 'Nov', 'dec': 'Dec',

      // Full month names
      'january': 'Jan', 'february': 'Feb', 'march': 'Mar', 'april': 'Apr',
      'june': 'Jun', 'july': 'Jul', 'august': 'Aug', 'september': 'Sep',
      'october': 'Oct', 'november': 'Nov', 'december': 'Dec',

      // Common OCR errors
      'ian': 'Jan', 'lan': 'Jan', 'i an': 'Jan', 'j an': 'Jan', 'ian': 'Jan',
      'fe b': 'Feb', 'f eb': 'Feb', 'ebr': 'Feb',
      'mar': 'Mar', 'm ar': 'Mar', 'ma r': 'Mar',
      'apr': 'Apr', 'a pr': 'Apr', 'ap r': 'Apr',
      'may': 'May', 'ma y': 'May', 'm ay': 'May',
      'iun': 'Jun', 'i un': 'Jun', 'iu n': 'Jun', 'iune': 'Jun',
      'iul': 'Jul', 'i ul': 'Jul', 'iu l': 'Jul', 'iuly': 'Jul',
      'aug': 'Aug', 'au g': 'Aug', 'a ug': 'Aug',
      'sep': 'Sep', 'se p': 'Sep', 's ep': 'Sep', 'sept': 'Sep',
      'oct': 'Oct', 'oc t': 'Oct', 'o ct': 'Oct', 'ocf': 'Oct',
      'nov': 'Nov', 'no v': 'Nov', 'n ov': 'Nov', 'n0v': 'Nov', 'nav': 'Nov',
      'dec': 'Dec', 'de c': 'Dec', 'd ec': 'Dec', 'del': 'Dec', 'dei': 'Dec',
      'decl': 'Dec', 'deci': 'Dec',
    };

    // Clean the input
    String clean = monthAbbrev
        .toLowerCase()
        .replaceAll(RegExp(r'[\s\/lI|\.]'), '')  // Remove spaces and OCR artifacts
        .trim();

    // Direct match
    if (monthMap.containsKey(clean)) {
      return monthMap[clean]!;
    }

    // Try first 3 characters
    if (clean.length >= 3) {
      String firstThree = clean.substring(0, 3);
      for (var key in monthMap.keys) {
        if (key.startsWith(firstThree)) {
          return monthMap[key]!;
        }
      }
    }

    // Try fuzzy matching (common OCR errors)
    for (var key in monthMap.keys) {
      if (_isSimilarMonth(clean, key)) {
        return monthMap[key]!;
      }
    }
    return 'Jan'; // Default fallback
  }

  bool _isSimilarMonth(String input, String target) {
    // Simple similarity check for common OCR errors
    if (input.length < 2 || target.length < 2) return false;

    // Common substitutions
    Map<String, List<String>> commonErrors = {
      'jan': ['ian', 'lan', 'ian'],
      'feb': ['feb', 'febr'],
      'mar': ['mar', 'march'],
      'apr': ['apr', 'april'],
      'may': ['may'],
      'jun': ['iun', 'iune', 'june'],
      'jul': ['iul', 'iuly', 'july'],
      'aug': ['aug', 'august'],
      'sep': ['sep', 'sept', 'september'],
      'oct': ['oct', 'october', 'ocf'],
      'nov': ['nov', 'november', 'n0v', 'nav'],
      'dec': ['dec', 'december', 'del', 'dei'],
    };

    for (var correctMonth in commonErrors.keys) {
      if (commonErrors[correctMonth]!.contains(input) && target.startsWith(correctMonth)) {
        return true;
      }
    }

    return false;
  }

  String _parseGregorianMonthNumber(String monthNum) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    int num = int.tryParse(monthNum) ?? 1;
    if (num < 1 || num > 12) num = 1;
    return months[num - 1];
  }

  List<String> _findAllDatePatterns(String text) {
    String cleanText = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    final pattern = RegExp(r'\b(\d{4}[\/lI|]?[A-Za-z]{3,4}[\/lI|]?\d{1,2}|\d{4}[\/lI|]\d{1,2}[\/lI|]\d{1,2}|\d{2}[\/lI|]\d{1,2}[\/lI|]\d{1,2})\b');

    return pattern.allMatches(cleanText)
        .map((m) => m.group(0)!)
        .where((match) => match.length >= 8) // Minimum length for a date
        .toList();
  }

  Map<String, dynamic> _classifyAndParseSingleDate(String dateStr) {
    // Try as Gregorian first
    String? gregorian = parseGregorianDate(dateStr);
    if (gregorian != null) {
      return {
        'type': 'gregorian',
        'normalized': gregorian,
        'valid': true,
      };
    }

    // Try as Ethiopian
    String? ethiopian = parseEthiopianDate(dateStr);
    if (ethiopian != null) {
      return {
        'type': 'ethiopian',
        'normalized': ethiopian,
        'valid': true,
      };
    }

    return {'type': 'unknown', 'normalized': '', 'valid': false};
  }

  List<String> _extractAllDates(String raw) {
    raw = _normalizeDateText(raw);

    final regex = RegExp(
      r'(\d{4}[\/\-](?:\d{1,2}|Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[\/\-]\d{1,2}|\d{1,2}[\/\-]\d{1,2}[\/\-]\d{4})',
      caseSensitive: false,
    );

    return regex.allMatches(raw).map((m) => m.group(0)!).toList();
  }

  String _normalizeDateText(String raw) {
    return raw.replaceAllMapped(
      RegExp(
        r'(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec|[0-9][a-zA-Z]{2})',
        caseSensitive: false,
      ),
          (match) {
        String m = match.group(0)!;

        return m
            .replaceAll('0', 'O') // 0ct → Oct
            .replaceAll('1', 'l') // 1an → Jan
            .replaceAll('5', 'S') // May OCR errors
            .replaceAll('8', 'B'); // Feb OCR errors
      },
    );
  }

  Uint8List trimTransparent(Uint8List bytes) {
    try {
      final image = img.decodeImage(bytes);
      if (image == null) return bytes;

      int minX = image.width;
      int minY = image.height;
      int maxX = 0;
      int maxY = 0;
      bool foundPixel = false;

      for (int y = 0; y < image.height; y++) {
        for (int x = 0; x < image.width; x++) {
          final pixel = image.getPixel(x, y);

          // Get alpha from the Pixel object
          final num a = pixel.a; // Pixel has a, r, g, b properties

          if (a > 10) { // not transparent (alpha > 10/255)
            foundPixel = true;
            if (x < minX) minX = x;
            if (y < minY) minY = y;
            if (x > maxX) maxX = x;
            if (y > maxY) maxY = y;
          }
        }
      }

      if (!foundPixel) {
        print("No non-transparent pixels found");
        return bytes;
      }

      // Crop the image
      final cropped = img.copyCrop(
        image,
        x: minX,
        y: minY,
        width: maxX - minX + 1,
        height: maxY - minY + 1,
      );

      return Uint8List.fromList(img.encodePng(cropped));

    } catch (e) {
      print("Error trimming transparent pixels: $e");
      return bytes;
    }
  }
}