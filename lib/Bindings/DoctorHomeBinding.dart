import 'package:get/get.dart';
import '../Controller/Doctor/DoctorHome_Controller.dart';
import '../Controller/Doctor/DoctorProfileController.dart';
import '../Controller/Doctor/DoctorAppointmentsController.dart';
import '../Controller/Doctor/DoctorPatientsController.dart';
import '../core/class/ApiService.dart';
import '../data/datasource/remote/Doctors/DactorData.dart';
import '../data/datasource/remote/images/imagesdta.dart';
import '../data/datasource/remote/Appointments/DoctorAppointmentData.dart';

class DoctorHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DoctorData>(() => DoctorData(Get.find<ApiService>()));
    Get.lazyPut<ImagesData>(() => ImagesData(Get.find<ApiService>()));
    Get.lazyPut<DoctorAppointmentData>(
      () => DoctorAppointmentData(Get.find<ApiService>()),
    );
    Get.lazyPut<DoctorHomeController>(
      () => DoctorHomeController(
        Get.find<DoctorData>(),
        Get.find<DoctorAppointmentData>(),
      ),
      fenix: true,
    );
    Get.lazyPut<DoctorAppointmentsController>(
      () => DoctorAppointmentsController(Get.find<DoctorAppointmentData>()),
      fenix: true,
    );
    Get.lazyPut<DoctorPatientsController>(
      () => DoctorPatientsController(Get.find<DoctorAppointmentData>()),
      fenix: true,
    );
    Get.lazyPut<DoctorProfileController>(
      () => DoctorProfileController(
        Get.find<DoctorData>(),
        Get.find<ImagesData>(),
        homeController: Get.find<DoctorHomeController>(),
        appointmentsController: Get.find<DoctorAppointmentsController>(),
        patientsController: Get.find<DoctorPatientsController>(),
      ),
      fenix: true,
    );
  }
}
