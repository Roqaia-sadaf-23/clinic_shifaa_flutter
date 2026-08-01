import 'package:clinic_shifaa/Controller/Patient/HomeController.dart';
import 'package:clinic_shifaa/View/Screen/Patient/PatientHomePage.dart';
import 'package:clinic_shifaa/core/Error/Failure.dart';
import 'package:clinic_shifaa/core/class/ApiService.dart';
import 'package:clinic_shifaa/core/localization/translation.dart';
import 'package:clinic_shifaa/data/datasource/remote/Home/HomeData.dart';
import 'package:clinic_shifaa/data/model/AppointmentModel.dart';
import 'package:clinic_shifaa/data/model/DoctorModel.dart';
import 'package:clinic_shifaa/data/model/PatientHomeProfileModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeDateFormatting('en');
    await initializeDateFormatting('ar');
  });

  setUp(() {
    Get.testMode = true;
  });

  tearDown(() {
    Get.reset();
  });

  test(
    'controller loads real dashboard sections and selects nearest upcoming',
    () async {
      final now = DateTime.now();
      final data = _FakeHomeData(
        appointments: [
          _appointment(
            id: 3,
            date: now.add(const Duration(days: 2)),
            status: 'Confirmed',
          ),
          _appointment(
            id: 2,
            date: now.add(const Duration(hours: 3)),
            status: 'Pending',
          ),
          _appointment(
            id: 1,
            date: now.add(const Duration(hours: 1)),
            status: 'Completed',
          ),
        ],
      );
      final controller = PatientHomeControllerImp(data);

      await controller.loadDashboard();

      expect(controller.patient?.firstName, 'Roqaia');
      expect(controller.doctors, hasLength(1));
      expect(controller.appointments, hasLength(3));
      expect(controller.upcomingAppointment?.id, 2);
      expect(controller.profileFailure, isNull);
      expect(controller.doctorsFailure, isNull);
      expect(controller.appointmentsFailure, isNull);
      controller.onClose();
    },
  );

  test('doctor search matches name and specialty without fake results', () {
    final controller = PatientHomeControllerImp(_FakeHomeData())
      ..doctors = [
        _doctor(id: 1, firstName: 'Sarah', specialization: 'Cardiology'),
        _doctor(id: 2, firstName: 'Omar', specialization: 'Dermatology'),
      ];

    controller.updateSearch('cardio');

    expect(controller.filteredDoctors.map((doctor) => doctor.id), [1]);
    controller.onClose();
  });

  testWidgets('patient home renders live sections and changes patient tabs', (
    tester,
  ) async {
    await _setPhoneSize(tester);
    final controller =
        PatientHomeControllerImp(_FakeHomeData(), autoLoad: false)
          ..patient = _profile
          ..doctors = [_doctor()]
          ..appointments = [
            _appointment(
              date: DateTime.now().add(const Duration(days: 1)),
              status: 'Confirmed',
            ),
          ];
    Get.put<PatientHomeControllerImp>(controller);

    await tester.pumpWidget(_app(locale: const Locale('en')));
    await tester.pumpAndSettle();

    expect(find.text('Hello, Roqaia'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Your upcoming appointment'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Your upcoming appointment'), findsOneWidget);
    expect(find.text('Doctors'), findsWidgets);
    expect(find.text('Cardiology'), findsWidgets);

    await tester.tap(find.text('Appointments').last);
    await tester.pumpAndSettle();

    expect(controller.selectedTab, 2);
    expect(find.text('My appointments'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty appointments response is a safe friendly state', (
    tester,
  ) async {
    await _setPhoneSize(tester);
    final controller =
        PatientHomeControllerImp(_FakeHomeData(), autoLoad: false)
          ..patient = _profile
          ..doctors = [_doctor()]
          ..appointments = const [];
    Get.put<PatientHomeControllerImp>(controller);

    await tester.pumpWidget(_app(locale: const Locale('en')));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('You do not have an upcoming appointment'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(
      find.text('You do not have an upcoming appointment'),
      findsOneWidget,
    );
    expect(find.text('Book an appointment'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Arabic patient home keeps localized RTL content', (
    tester,
  ) async {
    await _setPhoneSize(tester);
    final controller =
        PatientHomeControllerImp(_FakeHomeData(), autoLoad: false)
          ..patient = const PatientHomeProfileModel(
            userId: 7,
            patientId: 13,
            personId: 9,
            firstName: 'رقية',
            lastName: 'أحمد',
          )
          ..doctors = const []
          ..appointments = const [];
    Get.put<PatientHomeControllerImp>(controller);

    await tester.pumpWidget(_app(locale: const Locale('ar')));
    await tester.pumpAndSettle();

    final greeting = find.text('مرحبًا، رقية');
    expect(greeting, findsOneWidget);
    expect(Directionality.of(tester.element(greeting)), TextDirection.rtl);
    expect(find.text('نتمنى لك يومًا صحيًا'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Widget _app({required Locale locale}) => GetMaterialApp(
  locale: locale,
  translations: MyTranslation(),
  home: const PatientHomePage(),
);

Future<void> _setPhoneSize(WidgetTester tester) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(360, 800);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

const _profile = PatientHomeProfileModel(
  userId: 7,
  patientId: 13,
  personId: 9,
  firstName: 'Roqaia',
  lastName: 'Ahmed',
  email: 'patient@example.com',
  bloodType: 'A+',
  age: 29,
  gender: 1,
);

DoctorDetailsModel _doctor({
  int id = 4,
  String firstName = 'Sarah',
  String specialization = 'Cardiology',
}) => DoctorDetailsModel(
  id: id,
  personId: 10,
  firstName: firstName,
  lastName: 'Ali',
  age: 38,
  experienceYears: 8,
  note: 'Heart specialist',
  specialization: specialization,
  userId: 20,
);

AppointmentModel _appointment({
  int id = 5,
  required DateTime date,
  required String status,
}) => AppointmentModel(
  id: id,
  doctorName: 'Sarah Ali',
  doctorId: 4,
  patientId: 13,
  doctorSpecialization: 'Cardiology',
  patientName: 'Roqaia Ahmed',
  appointmentDate: date,
  status: status,
);

class _FakeHomeData extends HomeData {
  _FakeHomeData({this.appointments = const []}) : super(ApiService());

  final List<AppointmentModel> appointments;

  @override
  Future<String?> getAuthenticatedRole() async => 'patient';

  @override
  Future<int?> getAuthenticatedUserId() async => 7;

  @override
  Future<String?> getAuthenticatedEmail() async => 'patient@example.com';

  @override
  Future<Either<Failure, PatientHomeProfileModel>> getPatientProfile({
    required int userId,
    String? email,
  }) async => const Right(_profile);

  @override
  Future<Either<Failure, List<DoctorDetailsModel>>> getDoctors() async =>
      Right([_doctor()]);

  @override
  Future<Either<Failure, List<AppointmentModel>>> getPatientAppointments(
    int userId,
  ) async => Right(appointments);

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getPatientResource(
    PatientResourceType type, {
    int? patientId,
  }) async => const Right([]);
}
