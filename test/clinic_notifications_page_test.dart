import 'package:clinic_shifaa/Controller/Notifications/ClinicNotificationsController.dart';
import 'package:clinic_shifaa/View/Screen/Notvications/Notvications.dart';
import 'package:clinic_shifaa/core/localization/translation.dart';
import 'package:clinic_shifaa/core/services/ClinicNotificationService.dart';
import 'package:clinic_shifaa/data/model/ClinicNotification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('notification page keeps Arabic localization and RTL', (
    tester,
  ) async {
    addTearDown(Get.reset);
    SharedPreferences.setMockInitialValues({
      'email': 'patient@example.com',
      'roleName': 'Patient',
    });
    final service = ClinicNotificationService();
    await service.recordAppointmentCreated(
      ClinicAppointmentNotificationSnapshot(
        id: 42,
        personName: 'أحمد',
        appointmentDate: DateTime.now().add(const Duration(days: 2)),
        status: 'Pending',
      ),
    );
    Get.put(service);
    Get.put(ClinicNotificationsController(service));

    await tester.pumpWidget(
      GetMaterialApp(
        translations: MyTranslation(),
        locale: const Locale('ar'),
        home: const Notvications(),
      ),
    );
    await tester.pumpAndSettle();

    final title = find.text('تم إنشاء الموعد');
    expect(title, findsOneWidget);
    expect(Directionality.of(tester.element(title)), TextDirection.rtl);
    expect(find.textContaining('أحمد'), findsOneWidget);
  });
}
