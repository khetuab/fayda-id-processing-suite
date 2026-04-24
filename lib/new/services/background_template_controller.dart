// new/services/background_template_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BackgroundTemplateController extends GetxController {
  static const int totalTemplates = 7;

  // Current selected template index (0-6)
  var selectedTemplate = 0.obs;

  // Template names for UI
  final List<String> templateNames = [
    'Template 1',
    'Template 2',
    'Template 3',
    'Template 4',
    'Template 5',
    'Template 6',
    'Template 7',
  ];

  // Front background images for each template
  final List<String> frontBackgroundImages = [
    'assets/bbb.jpg',      // Template 1 - Current default
    'assets/front1.png',
    'assets/front2.png',
    'assets/front3.png',
    'assets/front4.png',
    'assets/front5.png',
    'assets/front5.jpg',
  ];

  // Back background images for each template
  final List<String> backBackgroundImages = [
    'assets/bbbbb.jpg',    // Template 1 - Current default
    'assets/back1.png',
    'assets/back2.png',
    'assets/back3.png',
    'assets/back4.png',
    'assets/back5.png',
    'assets/back5.jpg',
  ];

  // Opacity control for background
  var backgroundOpacity = 0.9.obs;
  var showBackground = true.obs;

  void setTemplate(int index) {
    if (index >= 0 && index < totalTemplates) {
      selectedTemplate.value = index;
    }
  }

  String getCurrentFrontBackground() {
    return showBackground.value ? frontBackgroundImages[selectedTemplate.value] : '';
  }

  String getCurrentBackBackground() {
    return showBackground.value ? backBackgroundImages[selectedTemplate.value] : '';
  }

  void toggleBackground() {
    showBackground.value = !showBackground.value;
  }

  void setBackgroundOpacity(double opacity) {
    backgroundOpacity.value = opacity.clamp(0.0, 1.0);
  }

  void resetToDefault() {
    selectedTemplate.value = 0;
    backgroundOpacity.value = 0.9;
    showBackground.value = true;
  }
}