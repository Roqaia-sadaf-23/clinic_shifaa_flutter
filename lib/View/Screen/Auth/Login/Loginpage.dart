// ignore: file_names
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../Controller/Auth/LoginPage/LoginController.dart';
import '../../../../core/constant/Appcolor.dart';
import '../../../Widget/login/SocialButton.dart';
import '../../../Widget/login/buildDivider.dart';
import '../../../Widget/login/buildEmailField.dart';
import '../../../Widget/login/buildIconAvatar.dart';
import '../../../Widget/login/buildLoginButton.dart';
import '../../../Widget/login/buildPasswordField.dart';
import '../../../Widget/login/buildRegisterRow.dart';
import '../../../Widget/login/buildRememberAndForgot.dart';
import '../../../Widget/login/buildSocialButtons.dart';
import '../../../Widget/login/buildTitle.dart';

// ============================================================
// MVC Structure:
// - LoginController  → الـ Controller/Model (يحمل الحالة والمنطق)
// - LoginPage         → الـ View (StatelessWidget بالكامل)
// الحالة القابلة للتغيير (إظهار كلمة المرور / تذكرني) تُدار عبر
// ValueNotifier داخل الـ Controller، والواجهة تستمع لها بـ
// ValueListenableBuilder بدون الحاجة لـ StatefulWidget.
// ============================================================

// -------------------- View --------------------

class LoginPage extends StatelessWidget {
  // final LoginController controller = Get.put(LoginController());

  const LoginPage({Key? key}) : super(key: key);
  //, LoginController? controller
  //
  // : controller = controller ?? LoginController();

  @override
  Widget build(BuildContext context) {
    final LoginController controller = Get.put(LoginController());
    return Scaffold(
      backgroundColor: Appcolor.cardBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                buildIconAvatar(),
                const SizedBox(height: 28),
                buildTitle(),
                const SizedBox(height: 40),
                buildEmailField(controller),
                const SizedBox(height: 20),
                buildPasswordField(),
                const SizedBox(height: 12),
                buildRememberAndForgot(),
                const SizedBox(height: 32),
                buildLoginButton(),
                const SizedBox(height: 24),
                buildDivider(),
                const SizedBox(height: 24),
                buildSocialButtons(),
                const SizedBox(height: 32),
                buildRegisterRow(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
