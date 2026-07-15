import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constant/Appcolor.dart';
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
    fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    fadeAnimation = CurvedAnimation(parent: fadeController, curve: Curves.easeIn);
    slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: slideController, curve: Curves.easeOut));
    fadeController.forward();
    slideController.forward();
  }

  void selectDoctor() => _changeStep(CompleteProfileStep.doctorForm);

  void selectPatient() => _changeStep(CompleteProfileStep.patientForm);

  void backToAccountType() => _changeStep(CompleteProfileStep.accountType);

  void selectSpecialty(String? name) {
    if (name == null) return;
    selectedSpecialty = specialties.firstWhere((specialty) => specialty.name == name);
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
