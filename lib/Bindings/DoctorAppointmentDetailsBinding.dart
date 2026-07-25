import 'package:get/get.dart';

import '../Controller/Doctor/DoctorAppointmentDetailsController.dart';
import '../core/class/ApiService.dart';
import '../data/datasource/remote/Appointments/DoctorAppointmentData.dart';

class DoctorAppointmentDetailsBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<DoctorAppointmentData>()) {
      Get.lazyPut(
        () => DoctorAppointmentData(Get.find<ApiService>()),
        fenix: true,
      );
    }
    Get.lazyPut(
      () =>
          DoctorAppointmentDetailsController(Get.find<DoctorAppointmentData>()),
    );
  }
}
