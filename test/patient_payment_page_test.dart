import 'package:clinic_shifaa/Controller/Patient/HomeController.dart';
import 'package:clinic_shifaa/View/Screen/Patient/PatientPaymentPage.dart';
import 'package:clinic_shifaa/core/class/ApiService.dart';
import 'package:clinic_shifaa/core/constant/Approutes.dart';
import 'package:clinic_shifaa/core/localization/translation.dart';
import 'package:clinic_shifaa/data/datasource/remote/Home/HomeData.dart';
import 'package:clinic_shifaa/data/model/AppointmentModel.dart';
import 'package:clinic_shifaa/data/model/DoctorModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.testMode = true;
    Get.reset();
  });

  tearDown(Get.reset);

  testWidgets('payment page shows the created appointment summary in English', (
    tester,
  ) async {
    final fixture = _PaymentPageFixture();
    await fixture.pump(tester, const Locale('en'));

    expect(find.text('Appointment created'), findsOneWidget);
    expect(find.text('Sarah Ali'), findsOneWidget);
    expect(find.text('Cardiology'), findsOneWidget);
    expect(find.text('Appointment price'), findsOneWidget);
    expect(find.text('Cash'), findsOneWidget);
    expect(find.text('Card'), findsOneWidget);
    expect(find.text('Pay now'), findsOneWidget);
  });

  testWidgets('Arabic payment page is localized and uses RTL direction', (
    tester,
  ) async {
    final fixture = _PaymentPageFixture();
    await fixture.pump(tester, const Locale('ar'));

    final title = find.text('تم إنشاء الموعد');
    expect(title, findsOneWidget);
    expect(find.text('نقدًا'), findsOneWidget);
    expect(find.text('بطاقة'), findsOneWidget);
    expect(find.text('الدفع الآن'), findsOneWidget);
    expect(Directionality.of(tester.element(title)), TextDirection.rtl);
  });
}

class _PaymentPageFixture {
  final appointmentDate = DateTime(2026, 8, 4, 13, 20);
  final doctor = DoctorDetailsModel(
    id: 14,
    personId: 7,
    firstName: 'Sarah',
    lastName: 'Ali',
    age: 40,
    specialization: 'Cardiology',
    userId: 21,
  );

  Future<void> pump(WidgetTester tester, Locale locale) async {
    await initializeDateFormatting(locale.languageCode);
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller = PatientHomeControllerImp(
      HomeData(ApiService()),
      autoLoad: false,
    );
    controller.registerCreatedAppointment(31);
    final appointment = AppointmentModel(
      id: 31,
      doctorName: doctor.fullName,
      doctorId: doctor.id,
      doctorSpecialization: doctor.specialization,
      patientName: '',
      appointmentDate: appointmentDate,
      status: 'Pending',
    );
    Get.put<PatientHomeControllerImp>(controller);

    await tester.pumpWidget(
      GetMaterialApp(
        translations: MyTranslation(),
        locale: locale,
        getPages: [
          GetPage(
            name: Approutes.paymentMethod,
            page: () => const PatientPaymentPage(),
          ),
        ],
        home: GetBuilder<PatientHomeControllerImp>(
          builder: (current) => Scaffold(
            body: FilledButton(
              onPressed: () {
                expect(current.preparePayment(appointment), isTrue);
                Get.toNamed<void>(Approutes.paymentMethod);
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  }
}
