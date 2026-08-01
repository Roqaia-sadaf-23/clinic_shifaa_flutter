// ignore_for_file: file_names

import 'package:get/get.dart';

import '../Controller/Patient/HomeController.dart';
import '../core/class/ApiService.dart';
import '../data/datasource/remote/Home/HomeData.dart';

class PatientHomeBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<HomeData>()) {
      Get.lazyPut<HomeData>(() => HomeData(Get.find<ApiService>()));
    }
    if (!Get.isRegistered<PatientHomeControllerImp>()) {
      Get.lazyPut<PatientHomeControllerImp>(
        () => PatientHomeControllerImp(Get.find<HomeData>()),
        fenix: true,
      );
    }
  }
}
