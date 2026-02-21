import 'package:get/get.dart';

class WhiteBackgroundController extends GetxController {
  // Controls for the white background element
  var showWhiteBackground = true.obs;
  var whiteBgLeft = (-5.0).obs;
  var whiteBgBottom = 25.0.obs;
  var photoOpacity = 0.5.obs;
  var whiteBgWidth = 150.0.obs;
  var whiteBgHeight = 150.0.obs;

  // Reset to default values
  void resetToDefaults() {
    showWhiteBackground.value = true;
    whiteBgLeft.value = -5.0;
    photoOpacity.value = 0.5;
    whiteBgBottom.value = 25.0;
    whiteBgWidth.value = 150.0;
    whiteBgHeight.value = 150.0;
  }
}