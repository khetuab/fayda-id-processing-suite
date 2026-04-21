import 'package:get/get.dart';

class WhiteBackgroundController extends GetxController {
  static WhiteBackgroundController get instance => Get.find<WhiteBackgroundController>();

  // Controls for the white background element
  var showWhiteBackground = true.obs;
  var whiteBgLeft = (-5.0).obs;
  var whiteBgBottom = 25.0.obs;
  var photoOpacity = 0.5.obs;
  var whiteBgWidth = 150.0.obs;
  var whiteBgHeight = 150.0.obs;

  // Add this new observable
  var isGrayscale = true.obs;

  // Add a callback function that will be set by HomePage
  Function(bool)? onGrayscaleChanged;

  void toggleGrayscale() {
    isGrayscale.value = !isGrayscale.value;
    // Call the callback if it exists
    if (onGrayscaleChanged != null) {
      onGrayscaleChanged!(isGrayscale.value);
    }
  }

  // Update resetToDefaults to include grayscale
  void resetToDefaults() {
    showWhiteBackground.value = true;
    photoOpacity.value = 0.5;
    whiteBgLeft.value = -5.0;
    whiteBgBottom.value = 25.0;
    whiteBgWidth.value = 150.0;
    whiteBgHeight.value = 150.0;
    isGrayscale.value = true;
    if (onGrayscaleChanged != null) {
      onGrayscaleChanged!(true);
    }
  }
}