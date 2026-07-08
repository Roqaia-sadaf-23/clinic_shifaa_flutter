import 'package:flutter/material.dart';
// ============================================================
// ويدجت مساعدة: غلاف موحّد لحقول الإدخال
// ============================================================

class InputWrapper extends StatelessWidget {
  final Widget child;
  const InputWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF14243A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: child,
    );
  }
}
