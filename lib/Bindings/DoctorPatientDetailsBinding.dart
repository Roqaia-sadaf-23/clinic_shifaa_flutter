import 'package:get/get.dart';

import '../Controller/Doctor/CreateMedicalRecordController.dart';
import '../Controller/Doctor/CreatePrescriptionController.dart';
import '../Controller/Doctor/DoctorPatientDetailsController.dart';
import '../core/class/ApiService.dart';
import '../data/datasource/remote/Patients/DoctorPatientDetailsData.dart';

class DoctorPatientDetailsBinding extends Bindings {
  @override
  void dependencies() {
    _ensurePatientDetailsData();
    Get.lazyPut(
      () =>
          DoctorPatientDetailsController(Get.find<DoctorPatientDetailsData>()),
    );
  }
}

class CreateMedicalRecordBinding extends Bindings {
  @override
  void dependencies() {
    _ensurePatientDetailsData();
    Get.lazyPut(
      () => CreateMedicalRecordController(
        Get.find<DoctorPatientDetailsData>(),
        Get.isRegistered<DoctorPatientDetailsController>()
            ? Get.find<DoctorPatientDetailsController>()
            : null,
      ),
    );
  }
}

class CreatePrescriptionBinding extends Bindings {
  @override
  void dependencies() {
    _ensurePatientDetailsData();
    Get.lazyPut(
      () => CreatePrescriptionController(
        Get.find<DoctorPatientDetailsData>(),
        Get.isRegistered<DoctorPatientDetailsController>()
            ? Get.find<DoctorPatientDetailsController>()
            : null,
      ),
    );
  }
}

void _ensurePatientDetailsData() {
  if (!Get.isRegistered<DoctorPatientDetailsData>()) {
    Get.lazyPut(() => DoctorPatientDetailsData(Get.find<ApiService>()));
  }
}
