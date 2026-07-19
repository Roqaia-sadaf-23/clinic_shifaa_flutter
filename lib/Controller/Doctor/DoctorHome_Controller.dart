import 'package:get/get.dart';

import '../../core/Error/Failure.dart';
import '../../data/datasource/remote/Doctors/DactorData.dart';
import '../../data/model/CurrentDoctorModel.dart';

class DoctorHomeController extends GetxController {
  DoctorHomeController(this._doctorData);
  final DoctorData _doctorData;
  CurrentDoctorModel? doctor;
  Failure? failure;
  bool isLoading = false;
  bool isRefreshing = false;
  bool _requestInProgress = false;
  bool _disposed = false;
  int selectedTab = 0;

  @override
  void onInit() {
    super.onInit();
    loadCurrentDoctor();
  }

  Future<void> loadCurrentDoctor() => _load(refreshing: false);
  Future<void> refreshCurrentDoctor() => _load(refreshing: true);
  void retry() {
    if (!_requestInProgress) loadCurrentDoctor();
  }

  void selectTab(int index) {
    if (index == 0 || index == 3) {
      selectedTab = index;
      update();
      return;
    }
    showComingSoon();
  }

  void handleAction(int index) => showComingSoon();

  void replaceDoctor(CurrentDoctorModel value) {
    doctor = value;
    failure = null;
    if (!_disposed) update();
  }

  void showComingSoon() {
    Get.snackbar(
      'comingSoon'.tr,
      'featureNotAvailable'.tr,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> _load({required bool refreshing}) async {
    if (_requestInProgress || _disposed) return;
    _requestInProgress = true;
    failure = null;
    if (refreshing) {
      isRefreshing = true;
    } else {
      isLoading = true;
    }
    update();
    try {
      final result = await _doctorData.getCurrentDoctor();
      if (_disposed) return;
      result.fold(
        (value) {
          doctor = null;
          failure = value.statusCode == 404
              ? const ServerFailure(
                  'Doctor profile was not found.',
                  statusCode: 404,
                )
              : value;
        },
        (value) {
          doctor = value;
          failure = null;
        },
      );
    } finally {
      _requestInProgress = false;
      isLoading = false;
      isRefreshing = false;
      if (!_disposed) update();
    }
  }

  @override
  void onClose() {
    _disposed = true;
    super.onClose();
  }
}
