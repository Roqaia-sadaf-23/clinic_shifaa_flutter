// ignore: file_names
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';

import '../../core/Error/Failure.dart';
import '../../core/class/AuthService.dart';
import '../../core/constant/Approutes.dart';
import '../../core/localization/changelocal.dart';
import '../../data/datasource/remote/Doctors/DactorData.dart';
import '../../data/model/CurrentDoctorModel.dart';
import '../../data/datasource/remote/images/imagesdta.dart';
import 'DoctorHome_Controller.dart';

class DoctorProfileController extends GetxController {
  DoctorProfileController(this._doctorData, this._imageData);

  final DoctorData _doctorData;
  final ImagesData _imageData;

  CurrentDoctorModel? doctor;
  Failure? failure;
  bool isLoading = false;
  bool isRefreshing = false;
  bool isEditing = false;
  bool isSaving = false;
  bool isUploadingImage = false;
  String? localImagePath;

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

  void openEditProfile() => Get.toNamed(Approutes.doctorEditProfile);

  void replaceDoctor(CurrentDoctorModel value) {
    doctor = value;
    failure = null;
    if (!_disposed) update();
  }

  Future<void> changeProfileImage() async {
    if (isUploadingImage || isSaving || _disposed) return;

    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null || _disposed) return;

    localImagePath = picked.path;
    failure = null;
    isUploadingImage = true;
    update();

    try {
      final uploadResult = await _imageData.uploadAuthenticatedImageName(
        picked.path,
      );
      if (_disposed) return;

      String? uploadedName;
      Failure? operationFailure;
      uploadResult.fold(
        (value) => operationFailure = value,
        (value) => uploadedName = value,
      );
      if (operationFailure != null) {
        _imageOperationFailed(operationFailure!);
        return;
      }

      isUploadingImage = false;
      isSaving = true;
      update();

      final updateResult = await _doctorData.updateCurrentPersonImage(
        uploadedName!,
      );
      if (_disposed) return;
      updateResult.fold((value) => operationFailure = value, (_) {});
      if (operationFailure != null) {
        _imageOperationFailed(operationFailure!);
        return;
      }

      final refreshed = await _doctorData.getCurrentDoctor();
      if (_disposed) return;
      refreshed.fold(
        (value) {
          failure = value;
          Get.snackbar(
            'doctorProfile'.tr,
            value.message,
            snackPosition: SnackPosition.BOTTOM,
          );
        },
        (value) {
          doctor = value;
          failure = null;
          localImagePath = null;
          if (Get.isRegistered<DoctorHomeController>()) {
            Get.find<DoctorHomeController>().replaceDoctor(value);
          }
          Get.snackbar(
            'doctorProfile'.tr,
            'profileImageUpdated'.tr,
            snackPosition: SnackPosition.BOTTOM,
          );
        },
      );
    } finally {
      isUploadingImage = false;
      isSaving = false;
      if (!_disposed) update();
    }
  }

  void _imageOperationFailed(Failure value) {
    failure = value;
    localImagePath = null;
    Get.snackbar(
      'changePhoto'.tr,
      value.message,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

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
