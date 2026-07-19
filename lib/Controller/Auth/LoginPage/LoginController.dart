import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/class/ApiService.dart';
import '../../../core/class/AuthService.dart';
import '../../../core/constant/Approutes.dart';
import '../../../data/datasource/remote/Auth/logindata.dart';
import '../../../data/datasource/remote/Doctors/DactorData.dart';

class LoginController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final loginController = TextEditingController();
  final passwordController = TextEditingController();

  final RxBool obscurePassword = true.obs;
  final RxBool rememberMe = false.obs;
  final RxBool isLoading = false.obs;

  late final LoginData _loginData;
  late final DoctorData _doctorData;
  bool _isDisposed = false;

  @override
  void onInit() {
    super.onInit();
    _loginData = LoginData(Get.find<ApiService>());
    _doctorData = DoctorData(Get.find<ApiService>());
  }

  void toggleObscurePassword() => obscurePassword.toggle();

  void toggleRememberMe(bool? value) {
    rememberMe.value = value ?? false;
  }

  String? validateLogin(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email or username is required';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  bool submit() {
    final isValid = formKey.currentState?.validate() ?? false;
    if (isValid) {
      login();
    }
    return isValid;
  }

  Future<void> _navigateByRole(String roleName) async {
    switch (roleName.toLowerCase()) {
      case 'doctor':
        await _openDoctorHome();
        break;

      case 'patient':
        Get.offAllNamed(Approutes.HomeScreen);
        break;

      case 'admin':
        await AuthService.clearTokens();

        if (_isDisposed) return;

        Get.snackbar(
          'Admin account',
          'Please use the web administration dashboard.',
          snackPosition: SnackPosition.BOTTOM,
        );
        break;

      default:
        await AuthService.clearTokens();

        if (_isDisposed) return;

        Get.snackbar(
          'Login failed',
          'Unsupported account role.',
          snackPosition: SnackPosition.BOTTOM,
        );
    }
  }

  Future<void> login() async {
    if (isLoading.value) return;

    final isValid = formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    try {
      isLoading.value = true;

      final result = await _loginData.login(
        login: loginController.text.trim(),
        password: passwordController.text,
      );

      if (_isDisposed) return;

      await result.fold<Future<void>>(
        (failure) async {
          Get.snackbar(
            'Login failed',
            failure.message,
            snackPosition: SnackPosition.BOTTOM,
          );
        },
        (token) async {
          final roleName = token.roleName.trim();

          final hasValidTokens =
              token.isSuccess &&
              token.accessToken.isNotEmpty &&
              token.refreshToken.isNotEmpty;

          if (!hasValidTokens) {
            Get.snackbar(
              'Login failed',
              token.message ?? 'Unable to login',
              snackPosition: SnackPosition.BOTTOM,
            );
            return;
          }

          if (roleName.isEmpty) {
            Get.snackbar(
              'Login failed',
              'The account role was not returned.',
              snackPosition: SnackPosition.BOTTOM,
            );
            return;
          }

          await AuthService.clearTokens();

          await AuthService.saveSession(
            accessToken: token.accessToken,
            refreshToken: token.refreshToken,
            email: loginController.text.trim(),
            roleName: roleName,
          );

          if (_isDisposed) return;

          await _navigateByRole(roleName);
        },
      );
    } catch (error, stackTrace) {
      debugPrint('Unexpected login error: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!_isDisposed) {
        Get.snackbar(
          'Error',
          'An unexpected error occurred.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } finally {
      if (!_isDisposed) {
        isLoading.value = false;
      }
    }
  }

  Future<void> _openDoctorHome() async {
    final doctorResult = await _doctorData.getCurrentDoctor();

    if (_isDisposed) return;

    await doctorResult.fold<Future<void>>(
      (failure) async {
        if (failure.statusCode == 404) {
          Get.snackbar(
            'Profile unavailable',
            'Your Doctor profile has not been completed.',
            snackPosition: SnackPosition.BOTTOM,
          );

          // لا تنتقلي إلى CompleteProfile هنا إلا إذا كان personId متاحًا.
          return;
        }

        Get.snackbar(
          'Profile unavailable',
          failure.message,
          snackPosition: SnackPosition.BOTTOM,
        );
      },
      (_) async {
        Get.offAllNamed(Approutes.doctorHome);
      },
    );
  }

  @override
  void onClose() {
    _isDisposed = true;
    loginController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
