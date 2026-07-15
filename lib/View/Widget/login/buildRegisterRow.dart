// -------------------- رابط إنشاء حساب --------------------
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constant/Appcolor.dart';
import '../../../core/constant/Approutes.dart';

Widget buildRegisterRow() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        'ليس لديك حساب؟',
        style: TextStyle(color: Appcolor.subTextColor, fontSize: 14),
      ),
      TextButton(
        onPressed: () {
          Get.toNamed(Approutes.Signup);
        },
        child: ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: Appcolor.gradientColors,
          ).createShader(bounds),
          child: const Text(
            'إنشاء حساب',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    ],
  );
}
