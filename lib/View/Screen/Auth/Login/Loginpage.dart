import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/route_manager.dart';

import '../../../../Controller/Auth/LoginPage/LoginController.dart';
import '../../../../core/constant/Appcolor.dart';
import '../../../Widget/login/InputWrapper.dart';
import '../../../Widget/login/SocialButton.dart';
import '../../../Widget/login/buildEmailField.dart';
import '../../../Widget/login/buildIconAvatar.dart';
import '../../../Widget/login/buildLoginButton.dart';
import '../../../Widget/login/buildPasswordField.dart';
import '../../../Widget/login/buildRegisterRow.dart';
import '../../../Widget/login/buildRememberAndForgot.DART';
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
  final LoginController controller = Get.put(LoginController());

  LoginPage({super.key});
  //, LoginController? controller  : controller = controller ?? LoginController();

  @override
  Widget build(BuildContext context) {
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
                _buildRememberAndForgot(),
                const SizedBox(height: 32),
                buildLoginButton(),
                const SizedBox(height: 24),
                _buildDivider(),
                const SizedBox(height: 24),
                _buildSocialButtons(),
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

  Widget _buildRememberAndForgot() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: ValueListenableBuilder<bool>(
                valueListenable: controller.rememberMe,
                builder: (context, value, _) {
                  return Checkbox(
                    value: value,
                    onChanged: controller.toggleRememberMe,
                    activeColor: Appcolor.gradientColors[0],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'تذكرني',
              style: TextStyle(color: Appcolor.subTextColor, fontSize: 13),
            ),
          ],
        ),
        TextButton(
          onPressed: () {},
          child: ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: Appcolor.gradientColors,
            ).createShader(bounds),
            child: const Text(
              'نسيت كلمة المرور؟',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // -------------------- فاصل "أو" --------------------
  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.white.withOpacity(0.1))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'أو تابع عبر',
            style: TextStyle(color: Appcolor.subTextColor, fontSize: 12),
          ),
        ),
        Expanded(child: Divider(color: Colors.white.withOpacity(0.1))),
      ],
    );
  }

  // -------------------- أزرار التواصل الاجتماعي --------------------
  Widget _buildSocialButtons() {
    return Row(
      children: const [
        Expanded(
          child: SocialButton(
            icon: Icons.g_mobiledata_rounded,
            label: 'Google',
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: SocialButton(icon: Icons.apple_rounded, label: 'Apple'),
        ),
      ],
    );
  }
}
