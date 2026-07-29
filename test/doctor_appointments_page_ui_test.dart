import 'package:clinic_shifaa/Controller/Doctor/DoctorAppointmentsController.dart';
import 'package:clinic_shifaa/View/Screen/Doctor/DoctorAppointmentsPage.dart';
import 'package:clinic_shifaa/core/Error/Failure.dart';
import 'package:clinic_shifaa/core/class/ApiService.dart';
import 'package:clinic_shifaa/core/localization/translation.dart';
import 'package:clinic_shifaa/data/datasource/remote/Appointments/DoctorAppointmentData.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() => initializeDateFormatting('en'));
  setUp(() => Get.testMode = true);
  tearDown(Get.reset);

  testWidgets('appointments page supports patient name and ID search', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final api = _AppointmentsUiApi();
    Get.put(
      DoctorAppointmentsController(DoctorAppointmentData(api)),
      permanent: true,
    );

    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    expect(find.text('Appointments'), findsOneWidget);
    expect(find.text('Total appointments'), findsOneWidget);
    expect(find.text('Patient: test test'), findsOneWidget);
    expect(find.text('Patient: pp pp'), findsOneWidget);
    expect(find.text('#17'), findsOneWidget);
    expect(find.text('#18'), findsOneWidget);
    expect(find.text('test'), findsOneWidget);
    expect(find.text('teth patient'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is AppointmentMetricCard &&
            widget.label == 'Total appointments' &&
            widget.value == '2',
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is AppointmentMetricCard &&
            widget.label == 'todayAppointments'.tr &&
            widget.value == '0',
      ),
      findsOneWidget,
    );

    final search = find.byType(TextField);
    await tester.enterText(search, 'pp');
    await tester.pumpAndSettle();

    expect(find.text('Patient: test test'), findsNothing);
    expect(find.text('Patient: pp pp'), findsOneWidget);

    await tester.enterText(search, '17');
    await tester.pumpAndSettle();

    expect(find.text('Patient: test test'), findsOneWidget);
    expect(find.text('Patient: pp pp'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('appointments page does not overflow on a small phone', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 568));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    Get.put(
      DoctorAppointmentsController(DoctorAppointmentData(_AppointmentsUiApi())),
      permanent: true,
    );

    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -900));
    await tester.pumpAndSettle();

    expect(find.text('View details'), findsWidgets);
    expect(find.text('Call'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('successful zero items displays empty state, not error', (
    tester,
  ) async {
    Get.put(
      DoctorAppointmentsController(
        DoctorAppointmentData(_EmptyAppointmentsUiApi()),
      ),
      permanent: true,
    );

    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    expect(find.text('No appointments found'), findsOneWidget);
    expect(find.text("Couldn't load appointments"), findsNothing);
    expect(tester.takeException(), isNull);
  });

  test('appointment statuses use the requested semantic colors', () {
    expect(appointmentStatusColor('Pending'), const Color(0xFFF39C12));
    expect(appointmentStatusColor('Confirmed'), const Color(0xFF3498DB));
    expect(appointmentStatusColor('Completed'), const Color(0xFF2ECC71));
    expect(appointmentStatusColor('Cancelled'), const Color(0xFFE74C3C));
  });

  test('patient image paths are safe and use the existing image endpoint', () {
    expect(doctorPatientImageUrl(null), isNull);
    expect(doctorPatientImageUrl(''), isNull);
    expect(doctorPatientImageUrl('test'), isNull);
    expect(doctorPatientImageUrl('invalid'), isNull);
    expect(
      doctorPatientImageUrl('02ba3c96-1738-47d7-8d88-fb750869302b.png'),
      'http://192.168.8.4:5210/api/Images/GetImage/'
      '02ba3c96-1738-47d7-8d88-fb750869302b.png',
    );
    expect(
      doctorPatientImageUrl('https://example.com/patient.png'),
      'https://example.com/patient.png',
    );
  });
}

Widget _testApp() {
  return GetMaterialApp(
    translations: MyTranslation(),
    locale: const Locale('en'),
    home: const Scaffold(body: DoctorAppointmentsPage()),
  );
}

class _AppointmentsUiApi extends ApiService {
  @override
  Future<Either<Failure, dynamic>> get(String url, {bool auth = false}) async {
    return const Right({
      'items': [
        {
          'id': 17,
          'patientId': 23,
          'patientName': 'test test',
          'patientImage': 'test',
          'appointmentDate': '2026-07-23T20:40:00.79',
          'status': 'Cancelled',
          'lastStatusDate': '2026-07-25T03:43:53.217',
          'medicalRecordId': null,
          'notes': 'test',
        },
        {
          'id': 18,
          'patientId': 24,
          'patientName': 'pp pp',
          'patientImage': '02ba3c96-1738-47d7-8d88-fb750869302b.png',
          'appointmentDate': '2026-07-27T12:00:00',
          'status': 'Completed',
          'lastStatusDate': '2026-07-27T06:55:04.06',
          'medicalRecordId': null,
          'notes': 'teth patient',
        },
      ],
      'page': 1,
      'pageSize': 10,
      'totalCount': 2,
      'totalPages': 1,
    });
  }
}

class _EmptyAppointmentsUiApi extends ApiService {
  @override
  Future<Either<Failure, dynamic>> get(String url, {bool auth = false}) async {
    return const Right({
      'items': <dynamic>[],
      'page': 1,
      'pageSize': 10,
      'totalCount': 0,
      'totalPages': 0,
    });
  }
}
