import 'package:clinic_shifaa/core/constant/Appcolor.dart';
import 'package:flutter/material.dart';

Widget buildButton({
  required String label,
  required IconData icon,
  required VoidCallback onPressed,
  bool outline = false,
}) {
  return GestureDetector(
    onTap: onPressed,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: outline
            ? null
            : const LinearGradient(
                colors: [Appcolor.gold, Appcolor.accent],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
        border: outline
            ? Border.all(color: Appcolor.textLight.withOpacity(0.3))
            : null,
        boxShadow: outline
            ? []
            : [
                BoxShadow(
                  color: Appcolor.gold.withOpacity(0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Appcolor.white,
              fontWeight: FontWeight.w600,
              fontSize: 15,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(width: 8),
          Icon(icon, color: Appcolor.white, size: 18),
        ],
      ),
    ),
  );
}
