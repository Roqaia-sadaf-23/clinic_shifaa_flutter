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
          final arguments = Get.arguments;
          final accountType = arguments is Map
              ? arguments['accountType']?.toString()
              : null;
          Get.toNamed(
            Approutes.Signup,
            arguments: accountType == null
                ? null
                : {'accountType': accountType},
          );
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
