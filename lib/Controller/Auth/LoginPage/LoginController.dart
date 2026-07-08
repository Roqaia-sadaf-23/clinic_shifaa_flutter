import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final ValueNotifier<bool> obscurePassword = ValueNotifier<bool>(true);
  final ValueNotifier<bool> rememberMe = ValueNotifier<bool>(false);

  void toggleObscurePassword() {
    obscurePassword.value = !obscurePassword.value;
  }

  void toggleRememberMe(bool? value) {
    rememberMe.value = value ?? false;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال البريد الإلكتروني';
    }
    if (!value.contains('@')) {
      return 'صيغة البريد الإلكتروني غير صحيحة';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال كلمة المرور';
    }
    if (value.length < 6) {
      return 'كلمة المرور يجب ألا تقل عن 6 أحرف';
    }
    return null;
  }

  // ينفّذ منطق تسجيل الدخول، ويرجع true لو نجح الفاليديشن
  bool submit() {
    return formKey.currentState?.validate() ?? false;
    // TODO: أضيفي هنا استدعاء الـ API / Auth الحقيقي
  }

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    obscurePassword.dispose();
    rememberMe.dispose();
  }
}
