import 'dart:typed_data';

class IDCardModel {
  // Front
  String fullNameEnglish;
  String fullNameAmharic;
  String dateOfBirthGregorian;
  String dateOfBirthEthiopian;
  String dateOfExpiryEthiopian;
  String nationalityEnglish;
  String nationalityAmharic;
  String kililAm;
  String kililEn;
  String zoneAm;
  String zoneEn;
  String weredaAm;
  String weredaEn;
  String sex;
  String expiryDate;
  String cardNumber;
  String givenDate;
  String givenDateEt;
  String fanNumber;
  String? photoPath;
  Uint8List? processedPhotoBytes;
  Uint8List? barcodeImageBytes;
  Uint8List? regeneratedBarcodeBytes;
  Uint8List? qrcodeImageBytes;
  Uint8List? realphotoImageBytes;
  String phoneNumber;
  String nationality;
  String region;
  String address;
  String finNumber;
  String serialNumber;
  String? qrCodeData;

  IDCardModel({
    this.fullNameEnglish = '',
    this.fullNameAmharic = '',
    this.dateOfBirthGregorian = '',
    this.dateOfBirthEthiopian = '',
    this.dateOfExpiryEthiopian = '',
    this.sex = '',
    this.kililAm = '',
    this.kililEn = '',
    this.zoneAm = '',
    this.zoneEn = '',
    this.weredaAm = '',
    this.weredaEn = '',
    this.fanNumber = '',
    this.nationalityEnglish = '',
    this.nationalityAmharic = '',
    this.expiryDate = '',
    this.cardNumber = '',
    this.givenDate = '',
    this.givenDateEt = '',
    this.photoPath,
    this.processedPhotoBytes, // Add to constructor
    this.barcodeImageBytes, // Add to constructor
    this.regeneratedBarcodeBytes, // Add to constructor
    this.qrcodeImageBytes, // Add to constructor
    this.realphotoImageBytes, // Add to constructor
    this.phoneNumber = '',
    this.nationality = '',
    this.region = '',
    this.address = '',
    this.finNumber = '',
    this.serialNumber = '',
    this.qrCodeData,
  });

  // Optional: Add a copyWith method for easier updates
  IDCardModel copyWith({
    String? fullNameEnglish,
    String? fullNameAmharic,
    String? dateOfBirthGregorian,
    String? dateOfBirthEthiopian,
    String? sex,
    String? kililAm,
    String? kililEn,
    String? zoneAm,
    String? zoneEn,
    String? weredaAm,
    String? weredaEn,
    String? fanNumber,
    String? expiryDate,
    String? cardNumber,
    String? nationalityEnglish,
    String? nationalityAmharic,
    String? givenDate,
    String? givenDateEt,
    String? photoPath,
    Uint8List? processedPhotoBytes,
    Uint8List? qrcodeImageBytes,
    Uint8List? realphotoImageBytes,
    String? phoneNumber,
    String? nationality,
    String? region,
    String? address,
    String? finNumber,
    String? serialNumber,
    String? qrCodeData,
  }) {
    return IDCardModel(
      fullNameEnglish: fullNameEnglish ?? this.fullNameEnglish,
      fullNameAmharic: fullNameAmharic ?? this.fullNameAmharic,
      dateOfBirthGregorian: dateOfBirthGregorian ?? this.dateOfBirthGregorian,
      dateOfBirthEthiopian: dateOfBirthEthiopian ?? this.dateOfBirthEthiopian,
      sex: sex ?? this.sex,
      kililEn: kililEn ?? this.kililEn,
      kililAm: kililAm ?? this.kililAm,
      zoneEn: zoneEn ?? this.zoneEn,
      zoneAm: zoneAm ?? this.zoneAm,
      weredaEn: weredaEn ?? this.weredaEn,
      weredaAm: weredaAm ?? this.weredaAm,
      fanNumber: fanNumber ?? this.fanNumber,
      expiryDate: expiryDate ?? this.expiryDate,
      cardNumber: cardNumber ?? this.cardNumber,
      nationalityEnglish: nationalityEnglish ?? this.nationalityEnglish,
      nationalityAmharic: nationalityAmharic ?? this.nationalityAmharic,
      givenDate: givenDate ?? this.givenDate,
      givenDateEt: givenDateEt ?? this.givenDateEt,
      photoPath: photoPath ?? this.photoPath,
      processedPhotoBytes: processedPhotoBytes ?? this.processedPhotoBytes,
      barcodeImageBytes: barcodeImageBytes ?? this.barcodeImageBytes,
      regeneratedBarcodeBytes: regeneratedBarcodeBytes ?? this.regeneratedBarcodeBytes,
      qrcodeImageBytes: qrcodeImageBytes ?? this.qrcodeImageBytes,
      realphotoImageBytes: realphotoImageBytes ?? this.realphotoImageBytes,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      nationality: nationality ?? this.nationality,
      region: region ?? this.region,
      address: address ?? this.address,
      finNumber: finNumber ?? this.finNumber,
      serialNumber: serialNumber ?? this.serialNumber,
      qrCodeData: qrCodeData ?? this.qrCodeData,
    );
  }

  @override
  String toString() {
    return 'IDCardModel(fullNameEnglish: $fullNameEnglish, fullNameAmharic: $fullNameAmharic, dobG: $dateOfBirthGregorian, realphotoImageBytes: $realphotoImageBytes, dobE: $dateOfBirthEthiopian, sex: $sex,kililAm: $kililAm ,kililEn: $kililEn , zoneEn: $zoneEn , zoneAm: $zoneAm , weredaEn: $weredaEn , weredaAm: $weredaAm,nationalityAmharic: $nationalityAmharic, nationalityEnglish: $nationalityEnglish,expiry: $expiryDate, card#: $cardNumber, given: $givenDate,givenEt: $givenDateEt, fanNumber: $fanNumber,photoPath: $photoPath, processedPhotoBytes: ${processedPhotoBytes?.length} bytes,barcodeImageBytes: ${barcodeImageBytes?.length} bytes,qrcodeImageBytes: ${qrcodeImageBytes?.length} bytes, phone: $phoneNumber, nat: $nationality, region: $region, addr: $address, fin: $finNumber, sn: $serialNumber, qr: $qrCodeData)';
  }
}