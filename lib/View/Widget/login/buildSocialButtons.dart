// -------------------- أزرار التواصل الاجتماعي --------------------
import 'package:clinic_shifaa/View/Widget/login/SocialButton.dart';
import 'package:flutter/material.dart';

Widget buildSocialButtons() {
  return Row(
    children: const [
      Expanded(
        child: SocialButton(icon: Icons.g_mobiledata_rounded, label: 'Google'),
      ),
      SizedBox(width: 12),
      Expanded(
        child: SocialButton(icon: Icons.apple_rounded, label: 'Apple'),
      ),
    ],
  );
}
