import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ClinicNotificationService.dart';

class Myservices extends GetxService {
  SharedPreferences? sharedPreferences;

  Future<Myservices> init() async {
    // await Firebase.initializeApp();
    sharedPreferences = await SharedPreferences.getInstance();
    return this;
  }
}

initialServices() async {
  await Get.putAsync(() => Myservices().init());
  await Get.putAsync<ClinicNotificationService>(
    () => ClinicNotificationService().init(),
    permanent: true,
  );
}
