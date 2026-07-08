import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../Controller/Auth/RegisterPage/RegisterPage_controler.dart';
import '../../../core/constant/Appcolor.dart';

Widget genderOption(
  RegisterController controller,
  int value,
  String label,
  IconData icon,
) {
  final selected = controller.gender == value;

  return Expanded(
    child: GestureDetector(
      onTap: () => controller.changeGender(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: selected
              ? const LinearGradient(colors: [Appcolor.accent, Appcolor.gold])
              : null,
          color: selected ? null : Appcolor.cardBg,
          border: Border.all(
            color: selected
                ? Colors.transparent
                : Appcolor.textLight.withOpacity(0.2),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Appcolor.white, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Appcolor.white,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
