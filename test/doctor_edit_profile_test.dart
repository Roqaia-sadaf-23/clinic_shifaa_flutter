import 'package:clinic_shifaa/Controller/Doctor/DoctorEditProfileController.dart';
import 'package:clinic_shifaa/Controller/Doctor/DoctorProfileController.dart';
import 'package:clinic_shifaa/View/Screen/Doctor/DoctorEditProfilePage.dart';
import 'package:clinic_shifaa/core/class/ApiService.dart';
import 'package:clinic_shifaa/core/localization/translation.dart';
import 'package:clinic_shifaa/data/datasource/remote/Doctors/DactorData.dart';
import 'package:clinic_shifaa/data/datasource/remote/images/imagesdta.dart';
import 'package:clinic_shifaa/data/model/CurrentDoctorModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  testWidgets('edit form is responsive and initializes confirmed fields', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 568);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(Get.reset);

    final apiService = ApiService();
    final doctorData = DoctorData(apiService);
    final profile = DoctorProfileController(doctorData, ImagesData(apiService))
      ..doctor = const CurrentDoctorModel(
        id: 14,
        personId: 41,
        firstName: 'Ahmed',
        lastName: 'Ali',
        age: 35,
        note: 'Doctor bio',
        experienceYears: 8,
        specialization: 'Dentist',
        imagePath: 'image.jpg',
        userId: 33,
      );
    final controller = DoctorEditProfileController(doctorData, profile);
    Get.put(controller);

    await tester.pumpWidget(
      GetMaterialApp(
        translations: MyTranslation(),
        locale: const Locale('ar'),
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(320, 568),
            textScaler: TextScaler.linear(1.5),
          ),
          child: const DoctorEditProfilePage(),
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(controller.firstNameController.text, 'Ahmed');
    expect(controller.lastNameController.text, 'Ali');
    expect(controller.ageController.text, '35');
    expect(controller.experienceYearsController.text, '8');
    expect(controller.specializationController.text, 'Dentist');
    expect(controller.validateAge('0'), isNotNull);
    expect(controller.validateAge('35'), isNull);
    expect(controller.validateExperience('-1'), isNotNull);
    expect(controller.validateExperience('8'), isNull);
  });
}
