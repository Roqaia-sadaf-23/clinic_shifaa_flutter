import 'package:get/get.dart';

import '../Controller/CompleteProfile/CompleteProfile_controller.dart';
import '../data/datasource/remote/CompleteProfile/CompleteProfileData.dart';

class CompleteProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CompleteProfileData>(() => CompleteProfileData());
    Get.lazyPut<CompleteProfileController>(
      () => CompleteProfileController(Get.find<CompleteProfileData>()),
    );
  }
}
