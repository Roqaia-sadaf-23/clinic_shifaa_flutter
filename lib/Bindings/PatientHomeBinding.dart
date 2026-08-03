// ignore_for_file: file_names

import 'package:get/get.dart';

import '../Controller/Patient/HomeController.dart';
import '../core/class/ApiService.dart';
import '../data/datasource/remote/Home/HomeData.dart';
import '../data/datasource/remote/Appointments/DoctorAppointmentData.dart';
import '../data/datasource/remote/images/imagesdta.dart';
import '../core/services/ClinicNotificationService.dart';

class PatientHomeBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<HomeData>()) {
      Get.lazyPut<HomeData>(() => HomeData(Get.find<ApiService>()));
    }
    if (!Get.isRegistered<DoctorAppointmentData>()) {
      Get.lazyPut<DoctorAppointmentData>(
        () => DoctorAppointmentData(Get.find<ApiService>()),
      );
    }
    if (!Get.isRegistered<ImagesData>()) {
      Get.lazyPut<ImagesData>(() => ImagesData(Get.find<ApiService>()));
    }
    if (!Get.isRegistered<PatientHomeControllerImp>()) {
      Get.lazyPut<PatientHomeControllerImp>(
        () => PatientHomeControllerImp(
          Get.find<HomeData>(),
          appointmentData: Get.find<DoctorAppointmentData>(),
          imageData: Get.find<ImagesData>(),
          notificationService: Get.isRegistered<ClinicNotificationService>()
              ? Get.find<ClinicNotificationService>()
              : null,
        ),
        fenix: true,
      );
    }
  }
}
