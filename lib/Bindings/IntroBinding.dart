// ignore_for_file: file_names

import 'package:get/get.dart';

import '../Controller/Intro/IntroController.dart';

class IntroBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<IntroController>()) {
      Get.lazyPut<IntroController>(IntroController.new);
    }
  }
}
