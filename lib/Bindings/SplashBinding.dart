// ignore_for_file: file_names

import 'package:get/get.dart';

import '../Controller/Splash/SplashController.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<SplashController>()) {
      Get.put<SplashController>(SplashController());
    }
  }
}
