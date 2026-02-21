import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:idmaf/new/services/controller.dart';
import '../models/id_card_model.dart';
import '../services/bc_service.dart';
import '../services/card_number_util.dart';
import '../services/image_utils.dart';
import '../services/white_background_controller.dart';
import 'crop_widget.dart';

class HorizontalIDTemplate extends StatefulWidget {
  final IDCardModel idData;
  final bool isFront;
  final Map<String, String> formData;
  final bool forPrint;

  const HorizontalIDTemplate({
    super.key,
    required this.idData,
    required this.isFront,
    this.formData = const {},
    this.forPrint = false,
  });

  @override
  State<HorizontalIDTemplate> createState() => _HorizontalIDTemplateState();
}

class _HorizontalIDTemplateState extends State<HorizontalIDTemplate> {

  final WhiteBackgroundController bgController = Get.find<WhiteBackgroundController>();
  String generateSerialNumber() {
    final random = Random();
    const digits = '123456789';
    return List.generate(7, (_) => digits[random.nextInt(digits.length)]).join();
  }

  bool _isCropping = false;

  // Add this method for cropping
  Future<void> _cropImage() async {
    if (_isCropping) return;

    setState(() {
      _isCropping = true;
    });

    try {
      Uint8List? imageBytes;

      if (widget.idData.processedPhotoBytes != null) {
        imageBytes = widget.idData.processedPhotoBytes;
      } else if (widget.idData.photoPath != null) {
        final file = File(widget.idData.photoPath!);
        imageBytes = await file.readAsBytes();
      }

      if (imageBytes == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No image to crop')),
        );
        return;
      }

      // Show manual crop dialog
      await showDialog(
        context: context,
        builder: (context) => Dialog.fullscreen(
          child: SmartCropWidget(
            imageBytes: imageBytes!,
            onCropped: (croppedBytes) async {
              // Remove background asynchronously
              setState(() {
                widget.idData.processedPhotoBytes = croppedBytes;
              });

              // Optionally save to file
              if (widget.idData.photoPath != null) {
                final newPath = widget.idData.photoPath!.replaceAll('.jpg', '_cropped.jpg');
                await File(newPath).writeAsBytes(croppedBytes);
                widget.idData.photoPath = newPath;
              }

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Image cropped successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },

          ),
        ),
      );
    } catch (e) {
      print('Error cropping image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to crop image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isCropping = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    final controller = FormController.instance;

    final String manualFan =
        widget.formData['fan']?.toString().trim() ?? '';

    final Uint8List? barcodeToUse =
    manualFan.isNotEmpty
        ? widget.idData.regeneratedBarcodeBytes
        : widget.idData.barcodeImageBytes;

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      child: InteractiveViewer(
        maxScale: 4,
        child: Container(
          //width: 330,
          width: 321.6,
          height: 201.6,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: widget.forPrint
                ? [] // No shadow for print
                : [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
            border: Border.all(color: Colors.grey.shade400, width: 1),
          ),
          child: widget.isFront ? _buildFrontSide(controller,barcodeToUse) : _buildBackSide(controller),
        ),
      ),
    );
  }

  Widget _buildFrontSide(FormController controller,Uint8List? barcodeToUse) {
    return Stack(
      children: [
        // Background with gradient
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFBBF4F4),
                Colors.white,
                Color(0xFFCDEACD),
              ],
            ),
          ),
        ),

        Positioned(
          left: 0,
          top: 0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ethiopian Flag Image
              Opacity(
                opacity:0.9,
                child: Container(

                  width: 321.6,
                  height: 201,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(1),
                    image: const DecorationImage(
                      image: AssetImage('assets/bbb.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        Positioned(
          left: 16,
          top: 6,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ethiopian Flag Image
              Container(
                width: 45,
                height: 23.5,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(1),
                  image: const DecorationImage(
                    image: AssetImage('assets/ethiopia_flag.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),

        Positioned(
          left: 90,
          top: 6,
          child: Container(
            width: 120,
            height: 20.5,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(1),
              image: const DecorationImage(
                image: AssetImage('assets/nationalidf.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),

        Positioned(
          left: 230,
          top: 6,
          child: Container(
            width: 75,
            height: 21.8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(1),
              image: const DecorationImage(
                image: AssetImage('assets/bitmap.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),


        Positioned(
          left: 227,
          top: 97,
          child: Container(
            width: 82,
            height: 39.8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(1),
              image: const DecorationImage(
                image: AssetImage('assets/fayida.png'),
                fit: BoxFit.fill,
              ),
            ),
          ),
        ),


        Obx(() => bgController.showWhiteBackground.value
            ? Positioned(
          left: bgController.whiteBgLeft.value,
          bottom: bgController.whiteBgBottom.value,
          child: Container(
            width: bgController.whiteBgWidth.value,
            height: bgController.whiteBgHeight.value,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(1),
              image: const DecorationImage(
                image: AssetImage('assets/whiteb.png'),
                fit: BoxFit.fill,
              ),
            ),
          ),
        )
            : SizedBox.shrink(),
        ),

        Positioned(
          left: 20,
          bottom: 25,
          child: widget.idData.processedPhotoBytes != null
              ? GestureDetector(
            onDoubleTap: _cropImage,
                child: Image.memory(
                            widget.idData.processedPhotoBytes!,
                            width: 100,
                            height: 125,
                            fit: BoxFit.cover,

                          ),
              )
              : widget.idData.photoPath != null
              ? Image.file(
            File(widget.idData.photoPath!),
            width: 115,
            height: 115,
            fit: BoxFit.cover,
          )
              : _buildPhotoPlaceholder(),
        ),


        Positioned(
          right: 30,
          bottom: 25,
          child: widget.idData.processedPhotoBytes != null
              ? Obx(
                () => Opacity(
              opacity: bgController.photoOpacity.value, // reactive only here
              child: Image.memory(
                widget.idData.processedPhotoBytes!,
                width: 38,
                height: 45,
                fit: BoxFit.contain,
              ),
            ),
          )
              : widget.idData.photoPath != null
              ? Image.file(
            File(widget.idData.photoPath!),
            width: 120,
            height: 115,
            fit: BoxFit.cover,
          )
              : _buildPhotoPlaceholder(),
        ),

        // Personal Information - Right Side
        // Full Name
        Positioned(
          left: 125,
          top: 45,
          child: _buildInfoField(
            label: 'ሙሉ ስም | Full Name',
            amharicValue: controller.amName.text.isNotEmpty
                ? controller.amName.text
                : (widget.idData.fullNameAmharic ?? ''),
            englishValue: controller.englishName.text.isNotEmpty
                ? controller.englishName.text
                : (widget.idData.fullNameEnglish ?? ''),
            labelSize: 6,
            valueSize: 9,
            amharicSize: 9,
          ),
        ),


        //Date of Birth
        Positioned(
          left: 125,
          top: 80,
          child: _buildInfoField(
            label: 'የትውልድ ቀን | Date of Birth',
            englishValue: "" ?? 'N/A',
            amharicValue: widget.idData.dateOfBirthGregorian?.isNotEmpty == true
                ? '${widget.idData.dateOfBirthGregorian} | '
                '${formatDateWithMonthName(widget.idData.dateOfBirthEthiopian ?? '')}'
                : null,

            labelSize: 6,
            valueSize: 8,
            amharicSize: 9,
          ),
        ),

        //Sex
        Positioned(
          left: 125,
          top: 100,
          child: _buildInfoField(
            label: 'ፆታ | Sex',
            englishValue: widget.idData.sex ?? 'N/A',
            labelSize: 6,
            valueSize: 8,
          ),
        ),

        // Date of Expiry
        Positioned(
          left: 125,
          top: 120,
          child: _buildInfoField(
            label: 'የሚያበቃበት ቀን | Date of Expiry',
            amharicValue: (controller.ethiopianExDate.text.isNotEmpty && controller.gregorianExDate.text.isNotEmpty )
                ? ('${controller.ethiopianExDate.text} | ${controller.gregorianExDate.text}')
                : (widget.idData.expiryDate ?? ''),
            amharicSize: 9,
            labelSize: 6,
            valueSize: 9,
            englishValue: '',
          ),
        ),

        // Date of Issue - Top Left
        Positioned(
          left: -69,
          top: 103,
          child: Transform.rotate(
            angle: 270 * 3.1415926535 / 180, // 90 degrees in radians
            child: Row(
              children: [
                Text(
                  'የተሰጠበት ቀን:',
                  style: GoogleFonts.notoSansEthiopic(
                    fontSize: 5.3,
                    color: Color(0xffa8822e),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  widget.idData.givenDateEt,
                  style: GoogleFonts.roboto(
                    fontSize: 7,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  ' Date of Issue:',
                  style: TextStyle(
                    fontSize: 5.3,
                    color: Color(0xffa8822e),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  controller.gregorianIssueDate.text.isNotEmpty
                      ? controller.gregorianIssueDate.text
                      : (widget.idData.givenDate ?? ''),
                  style: GoogleFonts.roboto(
                    fontSize: 7,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),

        Positioned(
          left: 126,
            top: 147,
            child: Text('ካርድ\nቁጥር\nFAN',style: TextStyle(color: Color(0xffa8822e),fontSize: 6,fontWeight: FontWeight.w500),)
        ),

        Positioned(
          left: 140,
          top: 145,
          child: Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(1.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${(widget.formData['fan']?.isNotEmpty == true)
                        ? widget.formData['fan']
                        : _getFormattedCardNumber(widget.idData)} ',
                    style: GoogleFonts.roboto(fontSize: 7.5,fontWeight: FontWeight.w700),),
                  SizedBox(height: 0),
                  // Actual Barcode Image (cropped from PDF)
                  if (barcodeToUse != null)
                    Container(
                      width: 79,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade300, width: 0.5),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: SvgPicture.memory(
                        barcodeToUse,
                        fit: BoxFit.contain,
                      ),
                    )
                  else
                    Container(
                      width: 120,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Center(
                        child: Text(
                          'No Barcode Image',
                          style: TextStyle(
                            fontSize: 6,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),

                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBackSide(FormController controller) {
    return Stack(
      children: [
        // Background
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFE9F8E9),
                Colors.white,
                Color(0xFFBBF4F4)

              ],
            ),
          ),
        ),
        Positioned(
          left: 0,
          top: 0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ethiopian Flag Image
              Opacity(
                opacity:0.9,
                child: Container(

                  width: 321.6,
                  height: 201,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(1),
                    image: const DecorationImage(
                      image: AssetImage('assets/bbbbb.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: 8,
          top: 10,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ስልክ | Phone Number',
                style: GoogleFonts.notoSansEthiopic(
                  color: Color(0xff9c7824),
                  fontSize: 6,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 1),
              Text(
                '${(widget.formData['fon']?.isNotEmpty == true)
                    ? widget.formData['fon']
                    : _extractPhoneNumber(widget.idData.phoneNumber ?? '')} ',
                style: GoogleFonts.notoSansEthiopic(
                  color: Color(0xff000000),
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  height: 1,
                  letterSpacing: 0.2,
                ),
              ),
              SizedBox(height: 1),
              Text(
                'ዜግነት | Nationality',
                style: GoogleFonts.notoSansEthiopic(
                  color: Color(0xff9c7824),
                  fontSize: 6,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 1),
              Text(
                'በተገለጸው መሰረት | Self Declared',
                style: GoogleFonts.notoSansEthiopic(
                  color: Color(0xff9c7824),
                  fontSize: 5,
                  height: 0.6,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 1),
              Text(
                "${(widget.formData['amCountry']?.isNotEmpty == true)
                    ? widget.formData['amCountry']!
                    : (widget.idData.nationalityAmharic ?? '')} | ${_extractNationality(widget.idData.nationalityEnglish ?? '')}",
                style: GoogleFonts.notoSansEthiopic(
                  color: Color(0xff000000),
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  height: 1,
                  letterSpacing: 0.2,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'አድራሻ | Address',
                style: GoogleFonts.notoSansEthiopic(
                  color: Color(0xff9c7824),
                  fontSize: 6,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                (widget.formData['amRegion']?.isNotEmpty == true)
                    ? widget.formData['amRegion']!
                    : (widget.idData.kililAm ?? ''),
                style: GoogleFonts.notoSansEthiopic(
                  color: Color(0xff000000),
                  fontSize: 8.5,
                  fontWeight: FontWeight.w600,
                  height: 1,
                  letterSpacing: 0.2,
                ),
              ),
              SizedBox(height: 4),
              Text(
                (widget.formData['enRegion']?.isNotEmpty == true)
                    ? widget.formData['enRegion']!
                    : (widget.idData.kililEn ?? ''),
                style: GoogleFonts.notoSansEthiopic(
                  color: Color(0xff000000),
                  fontSize: 8.5,
                  fontWeight: FontWeight.w600,
                  height: 1,
                  letterSpacing: 0.2,
                ),
              ),
              SizedBox(height: 4),
              Text(
                (widget.formData['amCity']?.isNotEmpty == true)
                    ? widget.formData['amCity']!
                    : (widget.idData.zoneAm ?? ''),
                style: GoogleFonts.notoSansEthiopic(
                  color: Color(0xff000000),
                  fontSize: 8.5,
                  fontWeight: FontWeight.w600,
                  height: 1,
                  letterSpacing: 0.2,
                ),
              ),
              SizedBox(height: 4),
              Text(
                (widget.formData['enCity']?.isNotEmpty == true)
                    ? widget.formData['enCity']!
                    : (widget.idData.zoneEn ?? ''),
                style: GoogleFonts.notoSansEthiopic(
                  color: Color(0xff000000),
                  fontSize: 8.5,
                  fontWeight: FontWeight.w600,
                  height: 1,
                  letterSpacing: 0.2,
                ),
              ),
              SizedBox(height: 4),
              Text(
                (widget.formData['amSubcity']?.isNotEmpty == true)
                    ? widget.formData['amSubcity']!
                    : widget.idData.weredaAm,
                style: GoogleFonts.notoSansEthiopic(
                  color: Color(0xff000000),
                  fontSize: 8.5,
                  fontWeight: FontWeight.w600,
                  height: 1,
                  letterSpacing: 0.2,
                ),
              ),
              SizedBox(height: 4),
              Text(
                (widget.formData['enSubcity']?.isNotEmpty == true)
                    ? widget.formData['enSubcity']!
                    : (widget.idData.weredaEn ?? ''),
                style: GoogleFonts.notoSansEthiopic(
                  color: Color(0xff000000),
                  fontSize: ((widget.formData['enSubcity']?.length ?? 0) > 25 ||
                      (widget.idData.weredaEn?.length ?? 0) > 25)
                      ? 7.5
                      : 8.5,
                  fontWeight: FontWeight.w600,
                  height: 1,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),

        Positioned(
          left: 8,
            top: 160,
            child: Container(
              color: Colors.white,
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('ፋይዳ',style: TextStyle(color: Color(
                          0xff000000),fontSize: 4 ,fontWeight: FontWeight.w600,height: 1,letterSpacing: 0.2),),
                      Text(' ልዩ ቁጥር',style: TextStyle(color: Color(
                          0xff000000),fontSize: 4 ,fontWeight: FontWeight.w600,height: 1,letterSpacing: 0.2),),
                    ],
                  ),
                  SizedBox(width: 2,),
                  Container(
                    width: .5,
                    height: 10,
                    color: Colors.black,
                  ),
                  Text(' FIN ',style: TextStyle(color: Colors.black,fontSize: 6,fontWeight: FontWeight.w600),),
                Text(
                  '${(widget.formData['fin']?.isNotEmpty == true)
                      ? widget.formData['fin']
                      : widget.idData.finNumber ?? ''} ',
                style: GoogleFonts.roboto(color: Colors.black,fontSize:8 ,fontWeight: FontWeight.w600),)
                ],
              ),
            )
        ),
        Positioned(
          right: 10,
          top: 10,
          child: Container(
            color: Colors.white,
            width: 163.5,
            height: 164.5,
            child: Padding(
              padding: const EdgeInsets.all(1.0),
              child: widget.idData.qrcodeImageBytes != null
                  ? Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300, width: 0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Image.memory(widget.idData.qrcodeImageBytes!),
                ),
              )
                  : const SizedBox(),

            ),
          ),
        ),
        Positioned(
          left: 8,
          bottom: 8,
          child: Text('ይህ መታወቂያ ጠፍቶ ካገኙ በአቅራቢያዎ ላለ ፖሊስ ጣቢያ ወይም ለተቋሙ ያስረክቡ ። ለተጨማሪ 9779 ላይ ይደውሉ ወይም id.et/cardprint ይጎብኙ ።\nIf lost and found, please return to nearby police station or to the institution .Call 9779 or visit id.et/cardprint for more',style: GoogleFonts.roboto(fontSize: 4),),
        ),
        Positioned(
          right: 10,
          bottom: 8,
          child: Container(
            color: Colors.white,
            child: Row(
              children: [
                Text(
                  ' SN : ',
                  style: TextStyle(
                    color: Color(0xff9c7824),
                    fontSize: 6,
                  ),
                ),
                Text(
                  "${generateSerialNumber()} ",
                  style: GoogleFonts.roboto(
                    color: Colors.black,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoField({
    required String label,
    String? label2,
    required String englishValue,
    String? amharicValue,
    bool alignRight = false,
    double labelSize = 6,
    double labelSize2 = 6,
    double valueSize = 8,
    double amharicSize = 7,
  }) {
    return Column(
      crossAxisAlignment:
      alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label (Amharic + English mixed)
        Text(
          label,
          style: GoogleFonts.roboto(
            fontSize: labelSize,
            color: const Color(0xff9c7824),
            height: 0.9,
            fontWeight: FontWeight.w600,
          ),
        ),

        if (label2 != null && label2.isNotEmpty)
          Text(
            label2,
            style: GoogleFonts.abyssinicaSil(
              fontSize: labelSize2,
              color: const Color(0xff9c7824),
              height: 0.9,
              fontWeight: FontWeight.w600,
            ),
          ),

        // Amharic value → Ethiopic font
        if (amharicValue != null && amharicValue.isNotEmpty)
          Text(
            amharicValue,
            style: GoogleFonts.notoSansEthiopic(
              fontSize: amharicSize,
              color: Colors.black,
              fontWeight: FontWeight.w600,
              height: 1.25,
            ),
          ),

        // English value → Latin font
        Text(
          englishValue,
          style: GoogleFonts.roboto(
            fontSize: valueSize,
            fontWeight: FontWeight.w600,
            color: Colors.black,
            height: 1.1,
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoPlaceholder() {
    return const Center(
      child: Icon(
        Icons.person,
        size: 40,
        color: Colors.grey,
      ),
    );
  }

  String _extractNationality(String rawText) {
    // Clean the text
    String cleanText = rawText.replaceAll('\n', ' ').replaceAll(RegExp(r'\s+'), ' ').trim();

    print("Raw nationality text: '$rawText'");
    print("Cleaned nationality text: '$cleanText'");
    print("Cleaned nationality text: '${widget.idData.nationality!}'");

    // Remove common nationality-related labels
    final nationalityLabels = [
      'nationality', 'citizenship', 'country', 'citizen',
      'ዜግነት', 'ብሔር', 'ተወላጅ', 'ዜግ'
    ];

    String textWithoutLabels = cleanText.toLowerCase();
    for (final label in nationalityLabels) {
      textWithoutLabels = textWithoutLabels.replaceAll(label, '|');
    }

    // Common nationalities (Ethiopian context)
    final nationalities = [
      'ethiopian', 'ethiopia', 'ኢትዮጵያ', 'ኢትዮጵያዊ',
      'american', 'united states', 'usa',
      'british', 'united kingdom', 'uk',
      'canadian', 'canada',
      'kenyan', 'kenya',
      'somali', 'somalia',
      'eritrean', 'eritrea',
      'sudanese', 'sudan',
    ];

    // Look for nationality keywords
    for (final nationality in nationalities) {
      if (textWithoutLabels.contains(nationality)) {
        print("✅ Nationality extracted: $nationality");
        print("✅ phone number: $nationality");
        // Capitalize the result
        return nationality[0].toUpperCase() + nationality.substring(1);
      }
    }

    // Look for single words that might be nationalities
    final words = textWithoutLabels.split(' ');
    for (final word in words) {
      if (word.length > 3 && !RegExp(r'\d').hasMatch(word)) {
        // Check if it's a potential nationality (not a number, not too short)
        final cleanWord = word.replaceAll(RegExp(r'[^a-zA-Z፩፪፫፬፭፮፯፰፱፲፳፴፵፶፷፸፹፺፻፼]'), '');
        if (cleanWord.length >= 4) {
          print("⚠️ Potential nationality (unrecognized): $cleanWord");
          return cleanWord[0].toUpperCase() + cleanWord.substring(1);
        }
      }
    }

    print("⚠️ Could not extract nationality from text: '$cleanText'");
    return 'Not specified';
  }


  String _getFormattedCardNumber(IDCardModel idData) {
    if (idData.fanNumber.isEmpty) return 'N/A';

    // Try to extract clean card number
    final extracted = CardNumberUtils.extractCardNumber(idData.fanNumber);

    // If extraction didn't change much, try finding in text
    if (extracted == idData.fanNumber && idData.fanNumber.length > 16) {
      final found = CardNumberUtils.extractCardNumber(idData.fanNumber);
      return found ?? extracted;
    }

    return extracted;
  }
  static String formatDateWithMonthName(String dateString) {
    if (dateString.isEmpty) return 'N/A';

    try {
      // Match the date pattern YYYY/MM/DD or YYYY-MM-DD
      final datePattern = RegExp(r'^(\d{4})[/-](\d{1,2})[/-](\d{1,2})$');
      final match = datePattern.firstMatch(dateString);

      if (match != null) {
        final year = match.group(1)!;
        final monthNumber = int.parse(match.group(2)!);
        final day = match.group(3)!;

        final monthName = _getMonthName(monthNumber);
        return '$year/$monthName/$day';
      }

      // If it's already in the correct format, return as is
      final textMonthPattern = RegExp(r'^\d{4}/[A-Za-z]{3}/\d{1,2}$');
      if (textMonthPattern.hasMatch(dateString)) {
        return dateString;
      }

      return dateString; // Return original if pattern doesn't match
    } catch (e) {
      print('❌ Error formatting date with month name: $e');
      return dateString; // Return original on error
    }
  }

  /// Get month name from month number (1-12)
  static String _getMonthName(int monthNumber) {
    switch (monthNumber) {
      case 1: return 'Jan';
      case 2: return 'Feb';
      case 3: return 'Mar';
      case 4: return 'Apr';
      case 5: return 'May';
      case 6: return 'Jun';
      case 7: return 'Jul';
      case 8: return 'Aug';
      case 9: return 'Sep';
      case 10: return 'Oct';
      case 11: return 'Nov';
      case 12: return 'Dec';
      default: return 'N/A';
    }
  }

  String _extractPhoneNumber(String rawText) {
    // Clean the text
    String cleanText = rawText.replaceAll('\n', ' ').replaceAll(RegExp(r'\s+'), ' ').trim();

    print("Raw phone text: '$rawText'");
    print("Cleaned phone text: '$cleanText'");

    // Remove common phone-related labels
    final phoneLabels = [
      'phone', 'telephone', 'mobile', 'cell', 'phone number', 'mobile number',
      'ስልክ', 'ስልክ ቁጥር', 'ተሌፎን', 'ሞባይል'
    ];

    String textWithoutLabels = cleanText.toLowerCase();
    for (final label in phoneLabels) {
      textWithoutLabels = textWithoutLabels.replaceAll(label, '|');
    }

    // Ethiopian phone number patterns
    final phonePatterns = [
      RegExp(r'\+251\s?\d{1,2}\s?\d{3}\s?\d{4}'), // +251 XX XXX XXXX
      RegExp(r'09\d{8}'), // 09XXXXXXXX
      RegExp(r'9\d{8}'),  // 9XXXXXXXX
      RegExp(r'\d{10}'),  // XXXXXXXXXX
      RegExp(r'\d{9}'),   // XXXXXXXXX
      RegExp(r'\d{3}[-.\s]?\d{3}[-.\s]?\d{4}'), // XXX-XXX-XXXX
      RegExp(r'\d{2}[-.\s]?\d{3}[-.\s]?\d{4}'), // XX-XXX-XXXX
    ];

    // Try each pattern
    for (final pattern in phonePatterns) {
      final match = pattern.firstMatch(textWithoutLabels);
      if (match != null) {
        String phone = match.group(0)!;
        // Clean the phone number
        phone = phone.replaceAll(RegExp(r'[^\d+]'), '');
        print("✅ Phone number extracted: $phone");
        return phone;
      }
    }

    // Fallback: look for any sequence of 9-10 digits
    final digitPattern = RegExp(r'\b\d{9,10}\b');
    final digitMatch = digitPattern.firstMatch(textWithoutLabels);
    if (digitMatch != null) {
      String phone = digitMatch.group(0)!;
      print("✅ Phone number extracted (fallback): $phone");
      return phone;
    }

    print("⚠️ Could not extract phone number from text: '$cleanText'");
    return 'Not found';
  }
}

class DateExtractor {
  /// Extracts both dates from strings like '20 18/02/10 2025/0ct/20'
  static Map<String, String> extractBothDates(String dateText) {
    return {
      'firstDate': extractFirstDate(dateText),
      'secondDate': extractSecondDate(dateText),
    };
  }

  /// Extract only the FIRST date from text
  static String extractFirstDate(String text) {
    if (text.isEmpty) return 'empty';

    try {
      // Clean the text
      String cleanText = text.replaceAll(RegExp(r'\s+'), ' ').trim();

      // Pattern to match dates in various formats
      final datePattern = RegExp(
          r'\b(\d{4})[/\-\.](\d{1,2}|[A-Za-z]{3,})[/\-\.](\d{1,2})\b',
          caseSensitive: false
      );

      // Find first date match
      final match = datePattern.firstMatch(cleanText);

      if (match != null) {
        return _normalizeDate(match.group(0)!);
      }

    } catch (e) {
      print('❌ Error extracting first date: $e');
    }

    return '';
  }

  /// Extract only the SECOND date from text
  static String extractSecondDate(String text) {
    if (text.isEmpty) return 'empty';

    try {
      // Clean the text
      String cleanText = text.replaceAll(RegExp(r'\s+'), ' ').trim();

      // Pattern to match dates in various formats
      final datePattern = RegExp(
          r'\b(\d{4})[/\-\.](\d{1,2}|[A-Za-z]{3,})[/\-\.](\d{1,2})\b',
          caseSensitive: false
      );

      // Find all date matches
      final matches = datePattern.allMatches(cleanText).toList();

      // Return the second date if it exists
      if (matches.length >= 2) {
        return _normalizeDate(matches[1].group(0)!);
      }

    } catch (e) {
      print('❌ Error extracting second date: $e');
    }

    return '';
  }

  /// Normalize date format and fix common OCR errors
  static String _normalizeDate(String dateString) {
    String normalized = dateString;

    // Fix common OCR errors in month names
    normalized = normalized.replaceAll('0ct', 'Oct')
        .replaceAll('0CT', 'Oct')
        .replaceAll('oCT', 'Oct')
        .replaceAll('0cT', 'Oct')
        .replaceAll('jan', 'Jan')
        .replaceAll('feb', 'Feb')
        .replaceAll('mar', 'Mar')
        .replaceAll('apr', 'Apr')
        .replaceAll('may', 'May')
        .replaceAll('jun', 'Jun')
        .replaceAll('jul', 'Jul')
        .replaceAll('aug', 'Aug')
        .replaceAll('sep', 'Sep')
        .replaceAll('nov', 'Nov')
        .replaceAll('dec', 'Dec');

    // Remove extra spaces around separators
    normalized = normalized.replaceAll(RegExp(r'\s*[/\-\.]\s*'), '/');

    return normalized;
  }

}
