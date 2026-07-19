import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/Error/Failure.dart';
import '../../data/datasource/remote/Doctors/DactorData.dart';
import '../../data/model/CurrentDoctorModel.dart';
import 'DoctorHome_Controller.dart';
import 'DoctorProfileController.dart';

class DoctorEditProfileController extends GetxController {
  DoctorEditProfileController(this._doctorData, this._profileController);

  final DoctorData _doctorData;
  final DoctorProfileController _profileController;

  final formKey = GlobalKey<FormState>();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final ageController = TextEditingController();
  final noteController = TextEditingController();
  final experienceYearsController = TextEditingController();
  final specializationController = TextEditingController();

  Failure? failure;
  bool isSaving = false;
  bool _disposed = false;

  CurrentDoctorModel get doctor => _profileController.doctor!;

  @override
  void onInit() {
    super.onInit();
    final current = _profileController.doctor;
    if (current == null) {
      Get.back();
      return;
    }
    firstNameController.text = current.firstName;
    lastNameController.text = current.lastName;
    ageController.text = current.age.toString();
    noteController.text = current.note ?? '';
    experienceYearsController.text = current.experienceYears.toString();
    specializationController.text = current.specialization;
  }

  String? validateName(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'fieldRequired'.tr;
    if (text.length < 2) return 'nameTooShort'.tr;
    if (text.length > 100) return 'valueTooLong'.tr;
    return null;
  }

  String? validateAge(String? value) {
    final age = int.tryParse(value?.trim() ?? '');
    if (age == null) return 'validNumberRequired'.tr;
    if (age < 1 || age > 120) return 'validAgeRequired'.tr;
    return null;
  }

  String? validateExperience(String? value) {
    final years = int.tryParse(value?.trim() ?? '');
    if (years == null) return 'validNumberRequired'.tr;
    if (years < 0 || years > 100) return 'validExperienceRequired'.tr;
    return null;
  }

  String? validateSpecialization(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'fieldRequired'.tr;
    if (text.length > 150) return 'valueTooLong'.tr;
    return null;
  }

  String? validateNote(String? value) {
    if ((value?.trim().length ?? 0) > 1000) return 'valueTooLong'.tr;
    return null;
  }

  Future<void> save() async {
    if (isSaving || _disposed) return;
    if (!(formKey.currentState?.validate() ?? false)) return;

    isSaving = true;
    failure = null;
    update();
    try {
      final result = await _doctorData.updateCurrentDoctorProfile(
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        age: int.parse(ageController.text.trim()),
        note: noteController.text.trim(),
        experienceYears: int.parse(experienceYearsController.text.trim()),
        specialization: specializationController.text.trim(),
      );
      if (_disposed) return;
      result.fold(
        (value) {
          failure = value;
          Get.snackbar(
            'editProfile'.tr,
            value.message,
            snackPosition: SnackPosition.BOTTOM,
          );
        },
        (updatedDoctor) {
          _profileController.replaceDoctor(updatedDoctor);
          if (Get.isRegistered<DoctorHomeController>()) {
            Get.find<DoctorHomeController>().replaceDoctor(updatedDoctor);
          }
          Get.back();
          Get.snackbar(
            'doctorProfile'.tr,
            'profileUpdated'.tr,
            snackPosition: SnackPosition.BOTTOM,
          );
        },
      );
    } finally {
      isSaving = false;
      if (!_disposed) update();
    }
  }

  @override
  void onClose() {
    _disposed = true;
    firstNameController.dispose();
    lastNameController.dispose();
    ageController.dispose();
    noteController.dispose();
    experienceYearsController.dispose();
    specializationController.dispose();
    super.onClose();
  }
}
