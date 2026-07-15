import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/class/ApiService.dart';
import '../../../core/constant/Approutes.dart';
import '../../../core/services/serveses.dart';
import '../../../data/datasource/remote/Auth/logindata.dart';

class LoginController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final RxBool obscurePassword = true.obs;
  final RxBool rememberMe = false.obs;
  final RxBool isLoading = false.obs;

  late final LoginData _loginData;
  bool _isDisposed = false;

  @override
  void onInit() {
    super.onInit();
    _loginData = LoginData(Get.find<ApiService>());
  }

  void toggleObscurePassword() => obscurePassword.toggle();

  void toggleRememberMe(bool? value) {
    rememberMe.value = value ?? false;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!GetUtils.isEmail(value.trim())) {
      return 'Enter a valid email address';
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

  Future<void> login() async {
    if (isLoading.value) return;

    final isValid = formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    try {
      isLoading.value = true;

      final result = await _loginData.login(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (isClosed) return;

      await result.fold(
        (failure) async {
          Get.snackbar(
            'Login failed',
            failure.message,
            snackPosition: SnackPosition.BOTTOM,
          );
        },
        (token) async {
          if (!token.isSuccess ||
              token.accessToken.isEmpty ||
              token.refreshToken.isEmpty) {
            Get.snackbar(
              'Login failed',
              token.message ?? 'Unable to login',
              snackPosition: SnackPosition.BOTTOM,
            );
            return;
          }

          final myServices = Get.find<Myservices>();

          await myServices.sharedPreferences?.setString(
            'accessToken',
            token.accessToken,
          );

          await myServices.sharedPreferences?.setString(
            'refreshToken',
            token.refreshToken,
          );

          await myServices.sharedPreferences?.setBool('isLoggedIn', true);

          Get.offAllNamed(Approutes.completeProfile);
        },
      );
    } catch (error, stackTrace) {
      debugPrint('Unexpected login error: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!isClosed) {
        Get.snackbar(
          'Error',
          'An unexpected error occurred',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } finally {
      if (!isClosed) {
        isLoading.value = false;
      }
    }
  }

  @override
  void onClose() {
    _isDisposed = true;
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
