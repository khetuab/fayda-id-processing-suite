import 'dart:io';
import 'dart:typed_data';
import 'package:barcode/barcode.dart';

Future<Uint8List> buildBarcodeFile(String data) async {
  if (data.trim().isEmpty) {
    return Uint8List(0);
  }

  final barcode = Barcode.code128(
    useCode128A: false,
    useCode128B: false,
  );

  final svg = barcode.toSvg(
    data,
    width: 800,
    height: 200,
    drawText: false,
  );

  return Uint8List.fromList(svg.codeUnits);
}

