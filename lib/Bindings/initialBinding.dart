// ignore: file_names
import 'package:get/get.dart';
import '../Controller/Auth/RegisterPage/RegisterPage_controler.dart';
import '../core/class/ApiService.dart';

import '../core/localization/changelocal.dart';
import '../core/services/serveses.dart';
//import '../controller/Favorite_controller.dart';

// ignore: camel_case_types
class initialBinding extends Bindings {
  @override
  /*  void dependencies() {
  
    // Get.put(FavoriteControllerim());
  } */
  void dependencies() {
    Get.putAsync<Myservices>(() async => await Myservices().init());
    Get.put(ApiService());
    Get.put(localController());
    Get.lazyPut<RegisterController>(() => RegisterController(), fenix: true);
  }
}
