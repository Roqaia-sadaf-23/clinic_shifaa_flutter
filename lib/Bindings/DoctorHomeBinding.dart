import 'package:get/get.dart';
import '../Controller/Doctor/DoctorHome_Controller.dart';
import '../Controller/Doctor/DoctorProfileController.dart';
import '../core/class/ApiService.dart';
import '../data/datasource/remote/Doctors/DactorData.dart';
import '../data/datasource/remote/images/imagesdta.dart';

class DoctorHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DoctorData>(() => DoctorData(Get.find<ApiService>()));
    Get.lazyPut<ImagesData>(() => ImagesData(Get.find<ApiService>()));
    Get.lazyPut<DoctorHomeController>(
      () => DoctorHomeController(Get.find<DoctorData>()),
    );
    Get.lazyPut<DoctorProfileController>(
      () => DoctorProfileController(
        Get.find<DoctorData>(),
        Get.find<ImagesData>(),
      ),
    );
  }
}
