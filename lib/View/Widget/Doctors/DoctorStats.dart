// ignore: file_names
import 'package:flutter/material.dart';

import '../Custome/StatCard.dart';

class DoctorStats extends StatelessWidget {
  const DoctorStats({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: StatCard(
            title: "اليوم",
            value: "8",
            subtitle: "مواعيد اليوم",
            color: Color(0xffDDF8F2),
            icon: Icons.calendar_month_rounded,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: StatCard(
            title: "المرضى",
            value: "124",
            subtitle: "إجمالي المرضى",
            color: Color(0xffFFF1D8),
            icon: Icons.groups_rounded,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: StatCard(
            title: "المواعيد",
            value: "48",
            subtitle: "المواعيد المؤكده",
            color: Color(0xffF2E7FF),
            icon: Icons.star_rounded,
          ),
        ),
      ],
    );
  }
}
