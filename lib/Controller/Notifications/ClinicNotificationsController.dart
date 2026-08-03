import 'package:get/get.dart';

import '../../core/constant/Approutes.dart';
import '../../core/services/ClinicNotificationService.dart';
import '../../data/model/ClinicNotification.dart';
import '../Doctor/DoctorHome_Controller.dart';
import '../Patient/HomeController.dart';

class ClinicNotificationsController extends GetxController {
  ClinicNotificationsController(this._service);

  final ClinicNotificationService _service;
  bool isLoading = true;
  bool isRequestingPermission = false;
  bool? devicePermissionGranted;

  List<ClinicNotification> get notifications => _service.notifications;
  int get unreadCount => _service.unreadCount;
  bool get supportsDeviceNotifications =>
      _service.supportsDeviceNotifications;

  @override
  void onInit() {
    super.onInit();
    _service.addListener(_serviceChanged);
    _load();
  }

  @override
  void onReady() {
    super.onReady();
    requestPermission();
  }

  Future<void> _load() async {
    await _service.loadForCurrentUser();
    if (isClosed) return;
    isLoading = false;
    update();
    await _service.markAllRead();
  }

  Future<void> requestPermission() async {
    if (!supportsDeviceNotifications || isRequestingPermission) return;
    isRequestingPermission = true;
    update();
    devicePermissionGranted = await _service.requestPermissions();
    isRequestingPermission = false;
    if (!isClosed) update();
  }

  Future<void> markAllRead() => _service.markAllRead();
  Future<void> clearRead() => _service.clearRead();

  Future<void> openNotification(ClinicNotification notification) async {
    await _service.markRead(notification.id);
    if (notification.appointmentId == null) return;

    if (notification.audience == 'doctor') {
      if (Get.isRegistered<DoctorHomeController>()) {
        Get.back<void>();
        Get.find<DoctorHomeController>().selectTab(1);
      } else {
        Get.offAllNamed<void>(Approutes.doctorHome);
      }
      return;
    }

    if (Get.isRegistered<PatientHomeControllerImp>()) {
      Get.back<void>();
      Get.find<PatientHomeControllerImp>().showAppointments();
    } else {
      Get.offAllNamed<void>(
        Approutes.HomeScreen,
        arguments: const {'patientTab': 2},
      );
    }
  }

  void _serviceChanged() {
    if (!isClosed) update();
  }

  @override
  void onClose() {
    _service.removeListener(_serviceChanged);
    super.onClose();
  }
}
