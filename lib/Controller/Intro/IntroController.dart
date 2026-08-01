// ignore_for_file: file_names

import 'package:get/get.dart';

import '../../core/class/AuthService.dart';
import '../../core/constant/Approutes.dart';

class IntroController extends GetxController {
  static const String patientRole = 'Patient';
  static const String doctorRole = 'Doctor';
  static const List<String> accountTypes = [patientRole, doctorRole];

  String? selectedAccountType;
  bool showSelectionValidation = false;
  bool isSaving = false;

  void selectAccountType(String accountType) {
    if (!accountTypes.contains(accountType) || isSaving) return;
    selectedAccountType = accountType;
    showSelectionValidation = false;
    update();
  }

  Future<void> continueToAuthentication() async {
    final accountType = selectedAccountType;
    if (accountType == null) {
      showSelectionValidation = true;
      update();
      return;
    }
    if (isSaving) return;

    isSaving = true;
    update();
    final saved = await AuthService.setIntroCompleted();
    if (isClosed) return;
    isSaving = false;
    update();

    if (!saved) {
      Get.snackbar('error'.tr, 'introSaveFailed'.tr);
      return;
    }

    Get.offAllNamed<void>(
      Approutes.login,
      arguments: {'accountType': accountType},
    );
  }
}
