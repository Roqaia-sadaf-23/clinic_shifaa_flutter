import 'package:flutter/material.dart';

import '../../../core/constant/Appcolor.dart';
import 'buildCard.dart';

Widget buildDropdownField({
  required String label,
  required IconData icon,
  required String? value,
  required List<String> items,
  required void Function(String?) onChanged,
}) {
  return buildCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Appcolor.accent, size: 18),
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
        DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: Appcolor.secondary,
          underline: const SizedBox(),
          iconEnabledColor: Appcolor.textLight,
          style: const TextStyle(color: Appcolor.white, fontSize: 14),
          items: items
              .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    ),
  );
}
