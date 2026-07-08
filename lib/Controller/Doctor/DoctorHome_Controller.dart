import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../View/Screen/Doctor/DoctorHomePage.dart' show AppointmentModel;

class DoctorHomeController extends GetxController {
  bool isLoading = false;
  final List<AppointmentModel> appointments = const [
    AppointmentModel(
      name: "سارة أحمد",
      type: "استشارة عامة",
      time: "09:30",
      status: "قيد الانتظار",
      statusColor: Color(0xffFFF1D8),
      textColor: Color(0xff8A8A8A),
    ),
    AppointmentModel(
      name: "علي حسن",
      type: "متابعة",
      time: "10:15",
      status: "تم",
      statusColor: Color(0xffDDF8F2),
      textColor: Color(0xff0F9D58),
    ),
    AppointmentModel(
      name: "منى صالح",
      type: "فحص دوري",
      time: "11:00",
      status: "ملغي",
      statusColor: Color(0xffF8D7DA),
      textColor: Color(0xffD32F2F),
    ),
  ];
}
