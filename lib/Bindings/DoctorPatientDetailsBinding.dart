import 'package:get/get.dart';

import '../Controller/Doctor/DoctorPatientDetailsController.dart';
import '../core/class/ApiService.dart';
import '../data/datasource/remote/Patients/DoctorPatientDetailsData.dart';

class DoctorPatientDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DoctorPatientDetailsData(Get.find<ApiService>()));
    Get.lazyPut(
      () =>
          DoctorPatientDetailsController(Get.find<DoctorPatientDetailsData>()),
    );
  }
}
