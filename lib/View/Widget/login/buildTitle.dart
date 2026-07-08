// -------------------- العنوان والوصف --------------------
import 'package:flutter/material.dart';

import '../../../core/constant/Appcolor.dart';

Widget buildTitle() {
  return Column(
    children: [
      const Text(
        'تسجيل الدخول',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 8),
      Text(
        'أهلاً بعودتك، سجّل الدخول للمتابعة',
        textAlign: TextAlign.center,
        style: TextStyle(color: Appcolor.subTextColor, fontSize: 14),
      ),
    ],
  );
}
