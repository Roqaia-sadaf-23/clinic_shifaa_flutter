import 'package:clinic_shifaa/Controller/Doctor/DoctorAppointmentDetailsController.dart';
import 'package:clinic_shifaa/View/Screen/Appointment/AppointmentDetailsPage.dart';
import 'package:clinic_shifaa/View/Screen/Doctor/DoctorAppointmentsPage.dart';
import 'package:clinic_shifaa/core/Error/Failure.dart';
import 'package:clinic_shifaa/core/class/ApiService.dart';
import 'package:clinic_shifaa/core/localization/translation.dart';
import 'package:clinic_shifaa/data/datasource/remote/Appointments/DoctorAppointmentData.dart';
import 'package:clinic_shifaa/data/model/AppointmentModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() => initializeDateFormatting('en'));
  setUp(() => Get.testMode = true);
  tearDown(Get.reset);

  testWidgets('doctor appointment card displays the patient name, not ID', (
    tester,
  ) async {
    await tester.pumpWidget(
      GetMaterialApp(
        translations: MyTranslation(),
        locale: const Locale('en'),
        home: Scaffold(
          body: DoctorAppointmentCard(
            appointment: AppointmentModel(
              id: 18,
              doctorName: 'Dr. Rami Balowar',
              patientName: 'Ahmed Mohammed',
              appointmentDate: DateTime(2026, 7, 27, 12),
              status: 'Pending',
            ),
          ),
        ),
      ),
    );

    expect(find.text('Patient: Ahmed Mohammed'), findsOneWidget);
    expect(find.textContaining('Patient ID'), findsNothing);
  });

  testWidgets('appointment details show useful fields and no raw IDs', (
    tester,
  ) async {
    final data = DoctorAppointmentData(_AppointmentDetailsApiService());

    await tester.pumpWidget(
      GetMaterialApp(
        translations: MyTranslation(),
        locale: const Locale('en'),
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => Get.toNamed('/details', arguments: 18),
            child: const Text('Open'),
          ),
        ),
        getPages: [
          GetPage(
            name: '/details',
            page: () => const AppointmentDetailsPage(),
            binding: BindingsBuilder(
              () => Get.put<DoctorAppointmentDetailsController>(
                DoctorAppointmentDetailsController(data),
              ),
            ),
          ),
        ],
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Ahmed Mohammed'), findsOneWidget);
    expect(find.text('Dr. Rami Balowar'), findsOneWidget);
    expect(find.text('Appointment date'), findsOneWidget);
    expect(find.text('Appointment time'), findsOneWidget);
    expect(find.text('Follow-up visit'), findsOneWidget);
    expect(find.text('Appointment ID'), findsNothing);
    expect(find.text('Doctor ID'), findsNothing);
    expect(find.text('Patient ID'), findsNothing);
  });
}

class _AppointmentDetailsApiService extends ApiService {
  @override
  Future<Either<Failure, dynamic>> get(String url, {bool auth = false}) async {
    return const Right({
      'id': 18,
      'doctorName': 'Dr. Rami Balowar',
      'patientName': 'Ahmed Mohammed',
      'appointmentDate': '2026-07-27T12:00:00',
      'status': 'Pending',
      'lastStatusDate': '2026-07-27T03:29:00',
      'notes': 'Follow-up visit',
    });
  }
}
