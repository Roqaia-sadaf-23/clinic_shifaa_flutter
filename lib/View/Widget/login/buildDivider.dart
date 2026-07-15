import 'package:flutter/material.dart';

import '../../../core/constant/Appcolor.dart';
// -------------------- فاصل "أو" --------------------

Widget buildDivider() {
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
