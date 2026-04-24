import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'new/services/background_template_controller.dart';
import 'new/services/white_background_controller.dart';
import 'new/widgets/background_template_selector.dart';
import 'new/widgets/form_page.dart';
import 'new/models/id_card_model.dart';
import 'new/services/barcode_service.dart';
import 'new/services/controller.dart';
import 'new/services/ocr_service.dart';
import 'new/services/pdf_processor.dart';
import 'new/services/print_service.dart';
import 'new/services/tesseract_amharic_ocr.dart';
import 'new/widgets/card_preview.dart';
import 'new/widgets/change_password_screen.dart';
import 'new/widgets/password_page.dart';
import 'new/widgets/the_new_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(WhiteBackgroundController());
  Get.put(BackgroundTemplateController());
  await TesseractAmharicOCR.initialize();
  if (!kIsWeb) {
    await FilePicker.platform.clearTemporaryFiles();
  }

  await GetStorage.init();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(FormController());

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ID Card Processor',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0066FF),
          brightness: Brightness.light,
          primary: const Color(0xFF0066FF),
          secondary: const Color(0xFFFF6B6B),
          tertiary: const Color(0xFF4ECDC4),
          background: const Color(0xFFF8FAFC),
          surface: const Color(0xFFFFFFFF),
          surfaceVariant: const Color(0xFFF1F5F9),
        ),
        fontFamily: 'Poppins',
        textTheme: TextTheme(
          displayLarge: GoogleFonts.poppins(
            fontSize: 36,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
          displayMedium: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          displaySmall: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          titleLarge: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          titleMedium: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          titleSmall: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
          bodyLarge: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.black87,
          ),
          bodyMedium: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.black87,
          ),
          bodySmall: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Colors.black54,
          ),
          labelLarge: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
          labelMedium: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
          labelSmall: GoogleFonts.poppins(
            fontSize: 10,
            fontWeight: FontWeight.w400,
            color: Colors.grey,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: const Color(0xFF0066FF),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            textStyle: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
            shadowColor: const Color(0xFF0066FF).withOpacity(0.3),
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 6,
          shadowColor: Colors.black.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          surfaceTintColor: Colors.transparent,
          margin: const EdgeInsets.symmetric(vertical: 8),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.all(16),
          hintStyle: GoogleFonts.poppins(
            color: Colors.grey[500],
            fontSize: 14,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Color(0xFF0066FF),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF0066FF),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1E293B),
          ),
          iconTheme: const IconThemeData(
            color: Color(0xFF0066FF),
          ),
        ),
      ),
      home: const PasswordEntryScreenc(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  IDCardModel? _model;
  bool _loading = false;

  final ocrService = OcrService();
  final barcodeService = BarcodeService();

  final GlobalKey _cardPreviewKey = GlobalKey();


  @override
  void initState() {
    super.initState();
    _setupFormListener();
    _model = IDCardModel();
  }

  void _setupFormListener() {
    final controller = Get.find<FormController>();
  }

  Map<String, String> _getFormData() {
    try {
      final controller = Get.find<FormController>();
      return {
        'amName': controller.amName.text,
        'fin': controller.fin.text,
        'fan': controller.fan.text,
        'fon': controller.fon.text,
        'amCountry': controller.amCountry.text,
        'enCountry': controller.enCountry.text,
        'amRegion': controller.amRegion.text,
        'enRegion': controller.enRegion.text,
        'amCity': controller.amCity.text,
        'enCity': controller.enCity.text,
        'amSubcity': controller.amSubcity.text,
        'enSubcity': controller.enSubcity.text,
        'finNumber': controller.finNumber.text,
        'serialNo': controller.serialNo.text,
      };
    } catch (e) {
      print('Error getting form data: $e');
      return {};
    }
  }

  Future<void> pickAndProcess() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: kIsWeb,
      );

      if (result == null) return;

      final file = File(result.files.single.path!);
      setState(() => _loading = true);

      final processor = PdfProcessor(
        ocrService: ocrService,
        barcodeService: barcodeService,
      );

      // 🔥 STEP 1: Render PDF ONCE
      await processor.preparePage(file);

      // 🔥 STEP 2: Reuse rendered page
      final model = await processor.processPdfFromPng(processor.pagePng);


      setState(() {
        _model = model;
        _loading = false;
      });

      _cardPreviewKey.currentState?.setState(() {});
    } catch (e, st) {
      debugPrint("Error picking file: $e\n$st");
      setState(() => _loading = false);
    }
  }


  void _refreshIDCardDisplay() {
    setState(() {});
    _cardPreviewKey.currentState?.setState(() {});
  }

  @override
  void dispose() {
    ocrService.dispose();
    barcodeService.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      // floatingActionButton: FloatingActionButton(
      //   child:  Icon(Icons.photo, color: Colors.white),
      //   onPressed: (){ },
      // ),
      appBar: AppBar(
        title: Text(
          'ID Card Processor',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: colorScheme.primary,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        iconTheme: IconThemeData(color: colorScheme.primary),
        actions: [
          IconButton(
            icon: Icon(Icons.photo_size_select_large_rounded,
                color: colorScheme.primary),
            onPressed: () {
              Get.to(() => PhotoSizeSettingsPage());
            },
            tooltip: 'Photo Settings',
          ),

          if (_model != null)
            IconButton(
              icon: Icon(Icons.refresh, color: colorScheme.primary),
              onPressed: _refreshIDCardDisplay,
              tooltip: 'Refresh with latest form data',
            ),
        ],
      ),
      body: _loading
          ? _buildLoadingState()
          : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16,horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Header Section
            _buildHeaderCard(context),
            const SizedBox(height: 32),

            // Action Buttons Section
            _buildActionButtonsCard(context),
            const SizedBox(height: 32),

            // Results Section (if data exists)
            if (_model != null) _buildResultsCard(context),
            const SizedBox(height: 32),
            const BackgroundTemplateSelector(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }


  Widget _buildHeaderCard(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32,vertical: 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0066FF).withOpacity(0.08),
            const Color(0xFF4ECDC4).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0066FF), Color(0xFF4ECDC4)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0066FF).withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.credit_card_outlined,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'ID Card Processing',
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Extract and manage ID card information with our processing system',
            style: GoogleFonts.poppins(
              fontSize: 15,
              height: 1.6,
              color: const Color(0xFF64748B),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtonsCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildActionButton(
              context,
              icon: Icons.person_add_alt_1_rounded,
              title: 'Add Personal Information',
              subtitle: 'Fill form with personal details',
            onPressed: () {
              if (_model == null) {
                _model = IDCardModel();
              }

              Get.to(() => FormPage(idData: _model!));
            },

              color: const Color(0xFF10B981),
              iconBgColor: const Color(0xFF10B981).withOpacity(0.1),
            ),
            const SizedBox(height: 16),
            _buildActionButton(
              context,
              icon: Icons.picture_as_pdf_rounded,
              title: 'Select ID Card PDF',
              subtitle: 'Upload and process document',
              onPressed: pickAndProcess,
              color: const Color(0xFF0066FF),
              iconBgColor: const Color(0xFF0066FF).withOpacity(0.1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required VoidCallback onPressed,
        required Color color,
        required Color iconBgColor,
      }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: color,
                  size: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultsCard(BuildContext context) {
    return Container(
      key: _cardPreviewKey,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF10B981),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              MediaQuery(
                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                child: Text(
                  'Extracted Information',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Extracted Name Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF10B981).withOpacity(0.1),
                  const Color(0xFF10B981).withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF10B981).withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: Color(0xFF10B981),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Full Name',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF10B981),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _model!.fullNameEnglish,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          Text(
            'ID Card Preview',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 20),

          Column(
            children: [
              _buildPreviewSection('Front Side', true, context),
              const SizedBox(height: 24),
              _buildWhiteBackgroundControls(),
              const SizedBox(height: 24),
              _buildPreviewSection('Back Side', false, context),
            ],
          ),
          const SizedBox(height: 32),
          // _buildWhiteBackgroundControls(),

          const SizedBox(height: 24),

          Center(
            child: ElevatedButton.icon(
              onPressed: () {
                final pdfService = PdfExportService();
                pdfService.showExportOptions(_model!, _getFormData());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0066FF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                shadowColor: const Color(0xFF0066FF).withOpacity(0.3),
              ),
              icon: const Icon(Icons.download_rounded, size: 20, color: Colors.white),
              label: Text(
                'Download PDF',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhiteBackgroundControls() {
    final controller = Get.find<WhiteBackgroundController>();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.layers, color: const Color(0xFF0066FF), size: 20),
                  const SizedBox(width: 8),
                  MediaQuery(
                    data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                    child: Text(
                      ' Controls',

                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                  ),
                ],
              ),
              Obx(() => Switch(
                value: controller.showWhiteBackground.value,
                onChanged: (value) => controller.showWhiteBackground.value = value,
                activeColor: const Color(0xFF0066FF),
              )),
            ],
          ),

          const SizedBox(height: 16),
          // Grayscale Toggle
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.photo_filter, color: const Color(0xFF0066FF), size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Photo Mode',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      'Color',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: !controller.isGrayscale.value
                            ? const Color(0xFF0066FF)
                            : const Color(0xFF94A3B8),
                      ),
                    ),
                    Obx(() => Switch(
                      value: controller.isGrayscale.value,
                      onChanged: (value) {
                        controller.isGrayscale.value = value;
                        // Force rebuild of the card preview
                        setState(() {});
                        if (_cardPreviewKey.currentState != null) {
                          _cardPreviewKey.currentState!.setState(() {});
                        }
                      },
                      activeColor: const Color(0xFF0066FF),
                    )),
                    Text(
                      'Gray',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: controller.isGrayscale.value
                            ? const Color(0xFF0066FF)
                            : const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Obx(() => Column(
            children: [
              _buildControlSlider(
                label: 'Photo Opacity',
                value: controller.photoOpacity.value,
                min: 0,
                max: 1,
                onChanged: (value) => controller.photoOpacity.value = value,
              ),
              const SizedBox(height: 2),
              _buildControlSlider(
                label: 'Left Position',
                value: controller.whiteBgLeft.value,
                min: -50,
                max: 100,
                onChanged: (value) => controller.whiteBgLeft.value = value,
              ),
              const SizedBox(height: 2),
              _buildControlSlider(
                label: 'Bottom Position',
                value: controller.whiteBgBottom.value,
                min: -50,
                max: 100,
                onChanged: (value) => controller.whiteBgBottom.value = value,
              ),
              const SizedBox(height: 2),
              _buildControlSlider(
                label: 'Width',
                value: controller.whiteBgWidth.value,
                min: 50,
                max: 250,
                onChanged: (value) => controller.whiteBgWidth.value = value,
              ),
              const SizedBox(height: 2),
              _buildControlSlider(
                label: 'Height',
                value: controller.whiteBgHeight.value,
                min: 50,
                max: 250,
                onChanged: (value) => controller.whiteBgHeight.value = value,
              ),
            ],
          )),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => controller.resetToDefaults(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF64748B),
                    padding: const EdgeInsets.symmetric(vertical: 16,horizontal: 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    side: BorderSide(color: const Color(0xFFE2E8F0)),
                  ),
                  icon: Icon(Icons.restore, size: 18),
                  label: Text(
                    'Reset to Default',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF475569),
              ),
            ),
            Text(
              '${value.toStringAsFixed(1)}',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0066FF),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Slider(
          value: value,
          min: min,
          max: max,
          onChanged: onChanged,
          activeColor: const Color(0xFF0066FF),
          inactiveColor: const Color(0xFFE2E8F0),
        ),
      ],
    );
  }
  Widget _buildPreviewSection(String title, bool isFront, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: HorizontalIDTemplate(
              idData: _model!,
              isFront: isFront,
              formData: _getFormData(),
            ),
          ),
        ),
      ],
    );
  }
}

Widget _buildLoadingState() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _PulseRipple(),
        const SizedBox(height: 30),
        Text(
          'Processing Document...',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Extracting information from PDF',
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: const Color(0xFF94A3B8),
          ),
        ),
      ],
    ),
  );
}

class _PulseRipple extends StatefulWidget {
  @override
  State<_PulseRipple> createState() => _PulseRippleState();
}

class _PulseRippleState extends State<_PulseRipple>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    )..repeat();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            ...List.generate(3, (index) {
              return Container(
                width: 70 + (_controller.value * 50 * (index + 1)),
                height: 70 + (_controller.value * 50 * (index + 1)),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF0066FF)
                        .withOpacity(0.6 - (index * 0.2)),
                    width: 2,
                  ),
                ),
              );
            }),
            Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: Color(0xFF0066FF),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF0066FF),
                    blurRadius: 15,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: const Icon(
                Icons.picture_as_pdf_rounded,
                color: Colors.white,
                size: 12,
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}