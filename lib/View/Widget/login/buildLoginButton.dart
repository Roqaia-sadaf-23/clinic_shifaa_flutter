import 'package:clinic_shifaa/View/Widget/login/handleLogin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../View/Screen/Auth/Login/Loginpage.dart';
import '../../../Controller/Auth/LoginPage/LoginController.dart';
import '../../../core/constant/Appcolor.dart';

class buildLoginButton extends GetView<LoginController> {
  @override
  Widget build(BuildContext context) {
    // -------------------- زر تسجيل الدخول --------------------
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: Appcolor.gradientColors,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Appcolor.gradientColors[0].withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => handleLogin(context),
          child: const Center(
            child: Text(
              'تسجيل الدخول',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
