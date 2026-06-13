import 'package:clinic_shifaa/core/services/serveses.dart';
import 'package:clinic_shifaa/data/model/DoctorModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DoctorDetailsController extends GetxController {
  final GlobalKey<FormState> formstate = GlobalKey<FormState>();
  Myservices myservices = Get.find();

  int selectedDayIndex = 0;
  int selectedTimeIndex = 0;
  List<DoctorDetailsModel> doctors = [];

  List<DateTime> availableDates = [];
  List<TimeOfDay> availableTimes = [];

  @override
  void onInit() {
    super.onInit();
    generateAvailableDates();
    //   generateAvailableTimes();
  }

  void generateAvailableDates() {
    final today = DateTime.now();

    availableDates.clear();

    for (int i = 0; i < 7; i++) {
      final date = today.add(Duration(days: i));

      // DateTime.friday = 5
      if (date.weekday != DateTime.friday) {
        availableDates.add(date);
      }
    }
  }

  /*  void generateAvailableTimes() {
    availableTimes.clear();

    TimeOfDay startTime = const TimeOfDay(hour: 12, minute: 30);
    TimeOfDay endTime = const TimeOfDay(hour: 22, minute: 0);

    int startMinutes = startTime.hour * 60 + startTime.minute;
    int endMinutes = endTime.hour * 60 + endTime.minute;

    // كل موعد مدته 30 دقيقة
    for (int minutes = startMinutes; minutes <= endMinutes; minutes += 30) {
      availableTimes.add(TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60));
    }
  }
 */
  void selectDay(int index) {
    selectedDayIndex = index;
    update();
  }

  void selectTime(int index) {
    selectedTimeIndex = index;
    update();
  }

  DateTime getSelectedAppointmentDateTime() {
    final date = availableDates[selectedDayIndex];
    final time = availableTimes[selectedTimeIndex];

    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  void bookAppointment() {
    final appointmentDateTime = getSelectedAppointmentDateTime();

    final data = {
      "doctorId": 1,
      "patientId": 1,
      "appointmentDate": appointmentDateTime.toIso8601String(),
      "durationInMinutes": 30,
      "notes": "string",
    };

    print(data);
  }
}
