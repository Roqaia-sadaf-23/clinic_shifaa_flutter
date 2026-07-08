import 'package:flutter/material.dart';

import '../../../core/constant/Appcolor.dart';

Widget buildCard({required Widget child}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 14),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Appcolor.inputBg,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Appcolor.white.withOpacity(0.05)),
    ),
    child: child,
  );
}
