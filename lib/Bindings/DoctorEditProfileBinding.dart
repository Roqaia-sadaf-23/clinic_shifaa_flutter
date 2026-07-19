import 'package:get/get.dart';

import '../Controller/Doctor/DoctorEditProfileController.dart';
import '../Controller/Doctor/DoctorProfileController.dart';
import '../data/datasource/remote/Doctors/DactorData.dart';

class DoctorEditProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DoctorEditProfileController>(
      () => DoctorEditProfileController(
        Get.find<DoctorData>(),
        Get.find<DoctorProfileController>(),
      ),
    );
  }
}
