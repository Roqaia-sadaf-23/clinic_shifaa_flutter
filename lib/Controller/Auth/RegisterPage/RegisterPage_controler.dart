import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/datasource/remote/Auth/logindata.dart';
import '../../../core/class/AuthService.dart';
import '../../../core/Error/Failure.dart';
import '../../../core/class/ApiService.dart';
import '../../../core/constant/Approutes.dart';
import '../../../core/helpers/failure_display.dart';
import '../../../data/datasource/remote/Auth/sginupdata.dart';
import '../../../data/datasource/remote/Countries/CountryData.dart';
import '../../../data/datasource/remote/Role/roleData.dart';
import '../../../data/datasource/remote/images/imagesdta.dart';
import '../../../data/model/CountryModel.dart';
import '../../../data/model/RoleModel.dart';
import '../../../data/model/registermodel.dart';

class RegisterController extends GetxController
    with GetTickerProviderStateMixin {
  final formKey = GlobalKey<FormState>();

  final imagesdta imageData = Get.put(imagesdta());
  final RoleData roleData = Get.put(RoleData());
  final CountryData countryData = Get.put(CountryData());

  late final SignupData signupData;
  late final LoginData loginData;

  final firstNameCtrl = TextEditingController();
  final lastNameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final userNameCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final nationalityNoCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final ageCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final noteCtrl = TextEditingController();

  late AnimationController fadeController;
  late AnimationController slideController;
  late Animation<double> fadeAnimation;
  late Animation<Offset> slideAnimation;

  List<RegisterModel> registerList = [];

  List<RoleModel> roles = [];
  RoleModel? selectedRole;

  List<CountryModel> countries = [];
  CountryModel? selectedCountry;

  File? profileImage;
  String? uploadedImageName;

  bool isActive = true;
  bool obscurePassword = true;
  bool isLoading = false;

  int gender = 0;
  int roleId = 0;
  int nationalityCountryId = 0;
  int currentStep = 0;

  @override
  void onInit() {
    super.onInit();

    signupData = SignupData(Get.find<ApiService>());
    loginData = LoginData(Get.find<ApiService>());

    _initAnimations();

    fadeController.forward();
    slideController.forward();

    getRoles();
    getCountries();
  }

  void changeGender(int value) {
    gender = value;
    update();
  }

  Future<void> getRoles() async {
    final data = await roleData.getRoles();

    roles = (data as List).map((e) => RoleModel.fromJson(e)).toList();

    if (roles.isNotEmpty && selectedRole == null) {
      selectedRole = roles.first;
      roleId = selectedRole!.Id;
    }

    print("Roles count: ${roles.length}");
    update();
  }

  Future<void> getCountries() async {
    final data = await countryData.getCountries();

    countries = (data["result"] as List)
        .map((e) => CountryModel.fromJson(e))
        .toList();

    if (countries.isNotEmpty && selectedCountry == null) {
      selectedCountry = countries.first;
      nationalityCountryId = selectedCountry!.Id;
    }

    print("Countries count: ${countries.length}");
    update();
  }

  void _initAnimations() {
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
  }

  void changeRole(RoleModel role) {
    selectedRole = role;
    roleId = role.Id;
    update();
  }

  void changeCountry(CountryModel country) {
    selectedCountry = country;
    nationalityCountryId = country.Id;
    update();
  }

  void changeActive(bool value) {
    isActive = value;
    update();
  }

  void togglePassword() {
    obscurePassword = !obscurePassword;
    update();
  }

  void nextStep() {
    if (currentStep < 2) {
      slideController.reset();
      currentStep++;
      update();
      slideController.forward();
    }
  }

  void prevStep() {
    if (currentStep > 0) {
      slideController.reset();
      currentStep--;
      update();
      slideController.forward();
    }
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();

    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) {
      print('No image selected');
      return;
    }

    profileImage = File(image.path);
    update();

    final result = await imageData.uploadImage(image.path);

    uploadedImageName = result["imageName"];

    print("Encrypted image name: $uploadedImageName");

    update();
  }

  Future<void> submit() async {
    if (isLoading) return;
    if (!formKey.currentState!.validate()) return;

    final registerModel = RegisterModel(
      firstName: firstNameCtrl.text,
      lastName: lastNameCtrl.text,
      email: emailCtrl.text,
      userName: userNameCtrl.text,
      password: passwordCtrl.text,
      isActive: isActive,
      nationalityNo: nationalityNoCtrl.text,
      roleId: roleId,
      phoneNumber: phoneCtrl.text,
      age: int.tryParse(ageCtrl.text) ?? 0,
      address: addressCtrl.text,
      gender: gender, // int: 0 أو 1 أو 2 حسب الـ API
      nationalityCountryId: nationalityCountryId,
      imagePath: uploadedImageName ?? "",
      note: noteCtrl.text,
    );
    isLoading = true;
    update();
    try {
      final response = await signupData.postDataUser(registerModel);

      await response.fold<Future<void>>(
        (failure) async {
          showFailure(
            failure,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        },
        (response) async {
          final personId = response.personId;
          if (personId == null || personId <= 0) {
            showFailure(
              const ServerFailure(
                'Registration succeeded but no valid personId was returned.',
              ),
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
            return;
          }

          final loginResult = await loginData.login(
            login: userNameCtrl.text.trim(),
            password: passwordCtrl.text,
          );

          var sessionSaved = false;
          await loginResult.fold<Future<void>>(
            (failure) async {
              showFailure(
                failure,
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
            },
            (token) async {
              if (!token.isSuccess ||
                  token.accessToken.isEmpty ||
                  token.refreshToken.isEmpty) {
                showFailure(
                  ServerFailure(token.message ?? 'Unable to login.'),
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                return;
              }

              await AuthService.saveTokens(
                accessToken: token.accessToken,
                refreshToken: token.refreshToken,
                email: emailCtrl.text.trim(),
              );
              await AuthService.setLoggedIn(true);
              sessionSaved = true;
            },
          );

          if (!sessionSaved) return;
          Get.snackbar(
            "Success",
            "تم إنشاء الحساب بنجاح",
            backgroundColor: Colors.green,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
          Get.offNamed(
            Approutes.completeProfile,
            arguments: {'personId': personId},
          );
        },
      );
    } catch (error, stackTrace) {
      debugPrint('Unexpected registration error: $error');
      debugPrintStack(stackTrace: stackTrace);
      showFailure(
        const ServerFailure('An unexpected error occurred.'),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading = false;
      update();
    }
  }

  @override
  void onClose() {
    firstNameCtrl.dispose();
    lastNameCtrl.dispose();
    emailCtrl.dispose();
    userNameCtrl.dispose();
    passwordCtrl.dispose();
    nationalityNoCtrl.dispose();
    phoneCtrl.dispose();
    ageCtrl.dispose();
    addressCtrl.dispose();
    noteCtrl.dispose();

    fadeController.dispose();
    slideController.dispose();

    super.onClose();
  }
}
