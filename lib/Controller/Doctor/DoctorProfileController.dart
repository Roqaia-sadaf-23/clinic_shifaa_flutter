// ignore: file_names
import 'package:get/get.dart';

import '../../core/Error/Failure.dart';
import '../../core/class/AuthService.dart';
import '../../core/constant/Approutes.dart';
import '../../core/localization/changelocal.dart';
import '../../data/datasource/remote/Doctors/DactorData.dart';
import '../../data/model/CurrentDoctorModel.dart';

class DoctorProfileController extends GetxController {
  DoctorProfileController(this._doctorData);

  final DoctorData _doctorData;

  CurrentDoctorModel? doctor;
  Failure? failure;
  bool isLoading = false;
  bool isRefreshing = false;
  bool isEditing = false;
  bool isSaving = false;
  bool isUploadingImage = false;

  bool _requestInProgress = false;
  bool _disposed = false;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  Future<void> loadProfile() => _load(refreshing: false);

  Future<void> refreshProfile() => _load(refreshing: true);

  void retry() {
    if (!_requestInProgress) loadProfile();
  }

  Future<void> updateProfile() async => showUnavailable();

  Future<void> changeProfileImage() async => showUnavailable();

  void showUnavailable() {
    Get.snackbar(
      'comingSoon'.tr,
      'profileEditingUnavailable'.tr,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void changeLanguage(String languageCode) {
    if (Get.isRegistered<localController>()) {
      Get.find<localController>().changeLang(languageCode);
    }
  }

  Future<void> logout() async {
    if (isSaving) return;
    isSaving = true;
    if (!_disposed) update();
    try {
      await AuthService.clearTokens();
      if (_disposed) return;
      Get.offAllNamed(Approutes.login);
    } finally {
      isSaving = false;
      if (!_disposed) update();
    }
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
          failure = value.statusCode == 404
              ? const ServerFailure(
                  'Doctor profile was not found.',
                  statusCode: 404,
                )
              : value;
          if (!refreshing) doctor = null;
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
