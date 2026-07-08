// -------------------- الدائرة العلوية بالأيقونة --------------------
import 'package:flutter/material.dart';

import '../../../core/constant/Appcolor.dart';

Widget buildIconAvatar() {
  return Center(
    child: Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: Appcolor.gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Appcolor.gradientColors[0].withOpacity(0.4),
            blurRadius: 30,
            spreadRadius: 4,
          ),
        ],
      ),
      child: const Icon(
        Icons.lock_outline_rounded,
        color: Colors.white,
        size: 46,
      ),
    ),
  );
}
