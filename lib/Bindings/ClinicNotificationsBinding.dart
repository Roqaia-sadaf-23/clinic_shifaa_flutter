import 'package:get/get.dart';

import '../Controller/Notifications/ClinicNotificationsController.dart';
import '../core/services/ClinicNotificationService.dart';

class ClinicNotificationsBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ClinicNotificationService>()) {
      Get.put(ClinicNotificationService(), permanent: true);
    }
    if (!Get.isRegistered<ClinicNotificationsController>()) {
      Get.lazyPut<ClinicNotificationsController>(
        () => ClinicNotificationsController(
          Get.find<ClinicNotificationService>(),
        ),
      );
    }
  }
}
