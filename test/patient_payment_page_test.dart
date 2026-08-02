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

  testWidgets(
    'payment success returns to the existing home controller without disposing it',
    (tester) async {
      await initializeDateFormatting('en');
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final controller = PatientHomeControllerImp(
        HomeData(ApiService()),
        autoLoad: false,
      );
      Get.put<PatientHomeControllerImp>(controller);
      final appointment = AppointmentModel(
        id: 25,
        doctorName: 'Sarah Ali',
        doctorId: 14,
        doctorSpecialization: 'Cardiology',
        patientName: '',
        appointmentDate: DateTime(2026, 8, 4, 13, 20),
        status: 'Pending',
      );

      await tester.pumpWidget(
        GetMaterialApp(
          translations: MyTranslation(),
          locale: const Locale('en'),
          initialRoute: Approutes.HomeScreen,
          getPages: [
            GetPage(
              name: Approutes.HomeScreen,
              page: () =>
                  _PatientHomeLifecycleHarness(appointment: appointment),
            ),
            GetPage(
              name: Approutes.paymentMethod,
              page: () => _PaymentReplacementHarness(appointment: appointment),
            ),
            GetPage(
              name: Approutes.paymentSuccess,
              page: () => const PatientPaymentSuccessPage(),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('open payment success'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('complete payment'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('View my appointments'));
      await tester.pumpAndSettle();

      expect(Get.currentRoute, Approutes.HomeScreen);
      expect(Get.find<PatientHomeControllerImp>(), same(controller));
      expect(controller.isClosed, isFalse);
      expect(controller.selectedTab, 2);
      await tester.enterText(find.byKey(const Key('patient-search')), 'heart');
      expect(controller.searchController.text, 'heart');
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('open payment success'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('complete payment'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Return to patient home'));
      await tester.pumpAndSettle();

      expect(Get.currentRoute, Approutes.HomeScreen);
      expect(Get.find<PatientHomeControllerImp>(), same(controller));
      expect(controller.isClosed, isFalse);
      expect(controller.selectedTab, 0);
      await tester.enterText(find.byKey(const Key('patient-search')), 'clinic');
      expect(controller.searchController.text, 'clinic');
      expect(tester.takeException(), isNull);
    },
  );
}

class _PatientHomeLifecycleHarness extends StatelessWidget {
  const _PatientHomeLifecycleHarness({required this.appointment});

  final AppointmentModel appointment;

  @override
  Widget build(BuildContext context) => GetBuilder<PatientHomeControllerImp>(
    builder: (controller) => Scaffold(
      body: Column(
        children: [
          TextField(
            key: const Key('patient-search'),
            controller: controller.searchController,
          ),
          FilledButton(
            onPressed: () => Get.toNamed<void>(Approutes.paymentMethod),
            child: const Text('open payment success'),
          ),
        ],
      ),
    ),
  );
}

class _PaymentReplacementHarness extends StatelessWidget {
  const _PaymentReplacementHarness({required this.appointment});

  final AppointmentModel appointment;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: FilledButton(
      onPressed: () => Get.offNamed<void>(
        Approutes.paymentSuccess,
        arguments: {
          'appointment': appointment,
          'paymentId': 81,
          'amount': 250.0,
          'paymentMethod': 'Card',
        },
      ),
      child: const Text('complete payment'),
    ),
  );
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
