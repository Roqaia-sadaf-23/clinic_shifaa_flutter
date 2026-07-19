import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constant/Appcolor.dart';
import '../../core/constant/Approutes.dart';
import '../../core/Error/Failure.dart';
import '../../data/datasource/remote/CompleteProfile/CompleteProfileData.dart';
import '../../data/model/SpecialtyModel.dart';

enum CompleteProfileStep { accountType, doctorForm, patientForm }

class CompleteProfileController extends GetxController
    with GetTickerProviderStateMixin {
  CompleteProfileController(this._completeProfileData);

  final CompleteProfileData _completeProfileData;
  final formKey = GlobalKey<FormState>();
  final experienceYearsController = TextEditingController();

  late final AnimationController fadeController;
  late final AnimationController slideController;
  late final Animation<double> fadeAnimation;
  late final Animation<Offset> slideAnimation;

  CompleteProfileStep currentStep = CompleteProfileStep.accountType;
  SpecialtyModel? selectedSpecialty;
  DateTime? hireDate;
  String? selectedBloodType;
  int? _personId;
  bool isSaving = false;

  int? get personId => _personId;

  /// Temporary data mirrors the future API model so replacing it with
  /// `getSpecialties()` will not require a UI change.
  List<SpecialtyModel> specialties = const [
    SpecialtyModel(id: 1, name: 'Cardiology'),
    SpecialtyModel(id: 2, name: 'Dermatology'),
    SpecialtyModel(id: 3, name: 'Family Medicine'),
    SpecialtyModel(id: 4, name: 'Pediatrics'),
  ];

  static const bloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  @override
  void onInit() {
    super.onInit();
    _personId = _readPersonId(Get.arguments);
    fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    fadeAnimation = CurvedAnimation(
      parent: fadeController,
      curve: Curves.easeIn,
    );
    slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: slideController, curve: Curves.easeOut));
    fadeController.forward();
    slideController.forward();

    if (_personId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar(
          'Complete profile',
          'A valid personId is required to complete your profile.',
        );
      });
    }
  }

  void selectDoctor() {
    if (_requirePersonId()) _changeStep(CompleteProfileStep.doctorForm);
  }

  void selectPatient() {
    if (_requirePersonId()) _changeStep(CompleteProfileStep.patientForm);
  }

  void backToAccountType() => _changeStep(CompleteProfileStep.accountType);

  void selectSpecialty(String? name) {
    if (name == null) return;
    selectedSpecialty = specialties.firstWhere(
      (specialty) => specialty.name == name,
    );
    update();
  }

  void selectBloodType(String? bloodType) {
    selectedBloodType = bloodType;
    update();
  }

  Future<void> selectHireDate(BuildContext context) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: hireDate ?? DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Appcolor.gold,
            onPrimary: Appcolor.white,
            surface: Appcolor.secondary,
            onSurface: Appcolor.white,
          ),
        ),
        child: child!,
      ),
    );
    if (selectedDate == null) return;
    hireDate = selectedDate;
    update();
  }

  bool canContinueDoctor() {
    final formIsValid = formKey.currentState?.validate() ?? false;
    if (!formIsValid || selectedSpecialty == null || hireDate == null) {
      Get.snackbar('Complete profile', 'Please complete all doctor details.');
      return false;
    }

    return true;
  }

  bool canContinuePatient() {
    if (selectedBloodType == null) {
      Get.snackbar('Complete profile', 'Please select your blood type.');
      return false;
    }
    return true;
  }

  Future<List<SpecialtyModel>> getSpecialtiesWhenEnabled() {
    return _completeProfileData.getSpecialties();
  }

  Future<void> submitDoctor() async {
    if (isSaving || !_requirePersonId() || !canContinueDoctor()) return;

    final experienceYear = int.tryParse(experienceYearsController.text);
    if (experienceYear == null || experienceYear < 0) {
      Get.snackbar('Complete profile', 'Enter valid experience years.');
      return;
    }

    isSaving = true;
    update();
    try {
      final result = await _completeProfileData.createDoctor(
        specialty: selectedSpecialty!.name,
        hireDate: hireDate!,
        personId: _personId!,
        experienceYear: experienceYear,
      );
      result.fold(_showFailure, (_) {
        Get.snackbar('Profile complete', 'Doctor profile saved.');
        Get.offAllNamed(Approutes.doctorHome);
      });
    } finally {
      isSaving = false;
      update();
    }
  }

  Future<void> submitPatient() async {
    if (isSaving || !_requirePersonId() || !canContinuePatient()) return;

    isSaving = true;
    update();
    try {
      final result = await _completeProfileData.createPatient(
        bloodType: selectedBloodType!,
        personId: _personId!,
      );
      result.fold(
        _showFailure,
        (_) => Get.snackbar('Profile complete', 'Patient profile saved.'),
      );
    } finally {
      isSaving = false;
      update();
    }
  }

  int? _readPersonId(Object? arguments) {
    if (arguments is! Map) return null;
    final value = arguments['personId'];
    final personId = value is int
        ? value
        : int.tryParse(value?.toString() ?? '');
    return personId != null && personId > 0 ? personId : null;
  }

  bool _requirePersonId() {
    if (_personId != null && _personId! > 0) return true;
    Get.snackbar(
      'Complete profile',
      'A valid personId is required to complete your profile.',
    );
    return false;
  }

  void _showFailure(Failure failure) {
    Get.snackbar('Complete profile', failure.message);
  }

  void _changeStep(CompleteProfileStep step) {
    slideController
      ..reset()
      ..forward();
    currentStep = step;
    update();
  }

  @override
  void onClose() {
    experienceYearsController.dispose();
    fadeController.dispose();
    slideController.dispose();
    super.onClose();
  }
}
