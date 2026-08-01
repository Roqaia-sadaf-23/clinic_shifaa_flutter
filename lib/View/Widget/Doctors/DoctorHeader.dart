import 'package:flutter/material.dart';

import '../Custome/AppProfileImage.dart';

class DoctorHeader extends StatelessWidget {
  const DoctorHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _iconBox(Icons.notifications_none_rounded),
        const Spacer(),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "مرحباً د. محمد",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              "أهلاً بك في لوحة التحكم",
              style: TextStyle(color: Color(0xff8A8A8A), fontSize: 13),
            ),
          ],
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Color(0xff0D6EFD), width: 2),
          ),
          child: const AppProfileImage(
            imagePath: 'https://i.pravatar.cc/150?img=12',
            size: 56,
            backgroundColor: Color(0xffEAF3FF),
            loadingIndicatorColor: Color(0xff0D6EFD),
            fallback: Icon(
              Icons.medical_services_outlined,
              color: Color(0xff0D6EFD),
              size: 28,
            ),
          ),
        ),
      ],
    );
  }

  Widget _iconBox(IconData icon) {
    return Container(
      height: 54,
      width: 54,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Icon(icon),
    );
  }
}
