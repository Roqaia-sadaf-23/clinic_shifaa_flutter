import 'dart:ui';

import 'package:clinic_shifaa/View/Widget/Custome/buildCard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constant/Appcolor.dart';

Widget buildField({
  required TextEditingController controller,
  required String label,
  required IconData icon,
  TextInputType keyboardType = TextInputType.text,
  List<TextInputFormatter>? inputFormatters,
  String? Function(String?)? validator,
  int maxLines = 1,
}) {
  return buildCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Appcolor.Red, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Appcolor.textLight,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          maxLines: maxLines,
          style: const TextStyle(color: Appcolor.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Enter $label',
            hintStyle: TextStyle(color: Appcolor.textLight.withOpacity(0.4)),
            border: InputBorder.none,
            isDense: true,
            errorStyle: const TextStyle(color: Appcolor.gold, fontSize: 11),
          ),
        ),
      ],
    ),
  );
}
