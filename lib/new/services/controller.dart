// controllers/form_controller.dart
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/id_card_model.dart';
import 'bc_service.dart';

class FormController extends GetxController {
  static FormController get instance => Get.find<FormController>();
  // TextEditingControllers
  TextEditingController amName = TextEditingController();
  TextEditingController amCountry = TextEditingController();
  TextEditingController enCountry = TextEditingController();
  TextEditingController amRegion = TextEditingController();
  TextEditingController enRegion = TextEditingController();
  TextEditingController amCity = TextEditingController();
  TextEditingController enCity = TextEditingController();
  TextEditingController amSubcity = TextEditingController();
  TextEditingController enSubcity = TextEditingController();
  TextEditingController finNumber = TextEditingController();
  TextEditingController serialNo = TextEditingController();
  // Add these to your TextEditingControllers
  TextEditingController gregorianIssueDate = TextEditingController();
  TextEditingController gregorianExDate = TextEditingController();
  TextEditingController ethiopianIssueDate = TextEditingController();
  TextEditingController ethiopianExDate = TextEditingController();
  TextEditingController englishName = TextEditingController();
  TextEditingController fin = TextEditingController();
  TextEditingController fan = TextEditingController();
  TextEditingController fon = TextEditingController();



  Rx<double> widthOfPhoto = 0.32.obs;
  Rx<double> heightOfPhoto = 0.35.obs;

  // Focus nodes for better keyboard management
  final List<FocusNode> focusNodes = List.generate(20, (index) => FocusNode());

  // Validation
  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  // Current focused field index
  final RxInt _currentFocusIndex = (-1).obs;
  int get currentFocusIndex => _currentFocusIndex.value;

  // Form key
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  FormController() {
    // Initialize focus node listeners
    _initializeFocusNodes();
  }

  void _initializeFocusNodes() {
    for (int i = 0; i < focusNodes.length; i++) {
      focusNodes[i].addListener(() {
        if (focusNodes[i].hasFocus) {
          _currentFocusIndex.value = i;
        }
      });
    }
  }

  // Method to move to next field
  void moveToNextField(int currentIndex) {
    if (currentIndex < focusNodes.length - 1) {
      focusNodes[currentIndex + 1].requestFocus();
    } else {
      // If last field, unfocus to hide keyboard
      focusNodes[currentIndex].unfocus();
    }
  }

  // Submit method
  Future<void> submitForm(IDCardModel idData) async {
    _unfocusAll();

    if (!formKey.currentState!.validate()) return;

    _isLoading.value = true;

    try {
      final manualFan = fan.text.trim();

      /// 🔥 If FAN is entered manually → regenerate barcode
      if (manualFan.isNotEmpty) {
        final barcodeBytes = await buildBarcodeFile(manualFan);

        if (barcodeBytes.isNotEmpty) {
          idData.regeneratedBarcodeBytes = barcodeBytes;
          idData.barcodeImageBytes = barcodeBytes;

          print("✅ Barcode regenerated from manual FAN input.");
        } else {
          idData.regeneratedBarcodeBytes = null;
          print("⚠️ Barcode generation returned empty bytes.");
        }
      } else {
        /// If manual FAN empty → keep existing extracted barcode
        print("ℹ️ Manual FAN empty. Using existing barcode.");
      }

      print('Amharic Name: ${amName.text}');
      print('FAN: ${fan.text}');
      print('Serial No: ${serialNo.text}');
      Get.back();
      Get.snackbar(
        'Success',
        'Form submitted successfully!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print("❌ Error during submit: $e");

      Get.snackbar(
        'Error',
        'Something went wrong!',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }


  // Clear all fields
  void clearAllFields() {
    englishName.clear();
    fin.clear();
    fan.clear();
    fon.clear();
    amName.clear();
    amCountry.clear();
    enCountry.clear();
    amRegion.clear();
    // Add to clearAllFields method:
    gregorianIssueDate.clear();
    gregorianExDate.clear();
    ethiopianIssueDate.clear();
    ethiopianExDate.clear();
    enRegion.clear();
    amCity.clear();
    enCity.clear();
    amSubcity.clear();
    enSubcity.clear();
    finNumber.clear();
    serialNo.clear();
    _unfocusAll();
  }

  void _unfocusAll() {
    for (var node in focusNodes) {
      node.unfocus();
    }
    _currentFocusIndex.value = -1;
  }

  @override
  void onClose() {
    // Dispose all controllers and focus nodes
    amName.dispose();
    englishName.dispose();
    fin.dispose();
    fan.dispose();
    fon.dispose();
    amCountry.dispose();
    enCountry.dispose();
    amRegion.dispose();
    enRegion.dispose();
    amCity.dispose();
    enCity.dispose();
    amSubcity.dispose();
    enSubcity.dispose();
    finNumber.dispose();
    serialNo.dispose();
    gregorianIssueDate.dispose();
    gregorianExDate.dispose();
    ethiopianIssueDate.dispose();
    ethiopianExDate.dispose();

    for (var node in focusNodes) {
      node.dispose();
    }

    super.onClose();
  }
}