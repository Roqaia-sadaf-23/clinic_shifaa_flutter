import 'package:clinic_shifaa/Controller/Patient/HomeController.dart';
import 'package:clinic_shifaa/View/Screen/Patient/PatientHomePage.dart';
import 'package:clinic_shifaa/core/Error/Failure.dart';
import 'package:clinic_shifaa/core/class/ApiService.dart';
import 'package:clinic_shifaa/core/constant/ApiLinks.dart';
import 'package:clinic_shifaa/core/helpers/image_path_helper.dart';
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

  test(
    'patient profile uses the actual user and Patient controller routes',
    () async {
      final api = _ProfileRecordingApiService({
        ApiLinks.userById(7): {
          'id': 7,
          'personId': 9,
          'firstName': 'Roqaia',
          'lastName': 'Ahmed',
          'email': 'patient@example.com',
          'phoneNumber': '+966500000000',
          'address': 'Riyadh',
        },
        ApiLinks.patients: [
          {
            'patientId': 13,
            'userId': 7,
            'personId': 9,
            'patientName': 'Roqaia Ahmed',
            'bloodType': 'A+',
          },
        ],
      });

      final result = await HomeData(
        api,
      ).getPatientProfile(userId: 7, email: 'patient@example.com');

      expect(api.getUrls, [ApiLinks.userById(7), ApiLinks.patients]);
      expect(api.authValues, everyElement(isTrue));
      result.fold((failure) => fail(failure.message), (profile) {
        expect(profile.userId, 7);
        expect(profile.patientId, 13);
        expect(profile.fullName, 'Roqaia Ahmed');
        expect(profile.phoneNumber, '+966500000000');
        expect(profile.address, 'Riyadh');
        expect(profile.bloodType, 'A+');
      });
    },
  );

  test(
    'patient doctor browsing uses the root Doctors list with auth',
    () async {
      final api = _RecordingApiService([
        {
          'id': 4,
          'personId': 10,
          'firstName': 'Sarah',
          'lastName': 'Ali',
          'specialization': 'Cardiology',
          'userId': 20,
        },
      ]);

      final result = await HomeData(api).getDoctors();

      expect(api.lastGetUrl, ApiLinks.doctors);
      expect(api.lastGetAuth, isTrue);
      result.fold((failure) => fail(failure.message), (doctors) {
        expect(doctors.single.id, 4);
        expect(doctors.single.fullName, 'Sarah Ali');
      });
    },
  );

  test('patient profile maps contact fields returned by the backend DTOs', () {
    final userProfile = PatientHomeProfileModel.fromJson({
      'id': 7,
      'personId': 9,
      'firstName': 'Roqaia',
      'lastName': 'Ahmed',
      'email': 'patient@example.com',
      'phoneNumber': '+966500000000',
      'address': 'Riyadh',
      'note': 'Prefers morning appointments',
    });
    final patientProfile = PatientHomeProfileModel.fromJson({
      'patientId': 13,
      'userId': 7,
      'personId': 9,
      'patientName': 'Roqaia Ahmed',
      'bloodType': 'A+',
    });

    final profile = userProfile.merge(patientProfile);

    expect(profile.patientId, 13);
    expect(profile.phoneNumber, '+966500000000');
    expect(profile.address, 'Riyadh');
    expect(profile.note, 'Prefers morning appointments');
    expect(profile.bloodType, 'A+');
  });

  test('image paths reject placeholders and malformed server filenames', () {
    expect(imageUrlForPath(null), isNull);
    expect(imageUrlForPath(''), isNull);
    expect(imageUrlForPath('test'), isNull);
    expect(imageUrlForPath('string'), isNull);
    expect(imageUrlForPath('avatar-without-extension'), isNull);
    expect(
      imageUrlForPath('patient photo.jpg'),
      '${ApiLinks.server}/Images/GetImage/patient%20photo.jpg',
    );
    expect(
      imageUrlForPath('https://cdn.example.com/avatar.png'),
      'https://cdn.example.com/avatar.png',
    );
  });

  test('appointments use backend statuses for patient filters', () {
    final now = DateTime.now();
    final controller =
        PatientHomeControllerImp(_FakeHomeData(), autoLoad: false)
          ..appointments = [
            _appointment(
              id: 1,
              date: now.subtract(const Duration(days: 1)),
              status: 'Pending',
            ),
            _appointment(
              id: 2,
              date: now.subtract(const Duration(days: 2)),
              status: 'Completed',
            ),
            _appointment(
              id: 3,
              date: now.add(const Duration(days: 1)),
              status: 'Cancelled',
            ),
          ];

    controller.selectAppointmentFilter(PatientAppointmentFilter.upcoming);
    expect(controller.filteredAppointments.map((item) => item.id), [1]);
    controller.selectAppointmentFilter(PatientAppointmentFilter.completed);
    expect(controller.filteredAppointments.map((item) => item.id), [2]);
    controller.selectAppointmentFilter(PatientAppointmentFilter.cancelled);
    expect(controller.filteredAppointments.map((item) => item.id), [3]);
    controller.onClose();
  });

  test(
    'appointments reuse loaded doctor data instead of extra requests',
    () async {
      final data = _FakeHomeData(
        doctors: [_doctor(imagePath: 'doctor.jpg')],
        appointments: [
          AppointmentModel(
            id: 17,
            doctorName: 'Sarah Ali',
            patientName: '',
            appointmentDate: DateTime(2026, 8, 4, 12),
            status: 'Pending',
          ),
        ],
      );
      final controller = PatientHomeControllerImp(data, autoLoad: false);

      await controller.loadDashboard();

      expect(controller.appointments.single.doctorId, 4);
      expect(controller.appointments.single.doctorSpecialization, 'Cardiology');
      expect(controller.appointments.single.doctorImage, 'doctor.jpg');
      controller.onClose();
    },
  );

  test(
    'patient appointments use the authenticated backend route and DTO',
    () async {
      final apiService = _RecordingApiService([
        {
          'id': 17,
          'doctorName': 'Sarah Ali',
          'specialty': 'Cardiology',
          'appointmentDate': '2026-08-04T12:00:00',
          'status': 'Pending',
          'notes': 'Follow-up',
        },
      ]);

      final result = await HomeData(apiService).getPatientAppointments();

      expect(apiService.lastGetUrl, ApiLinks.patientAppointments);
      expect(apiService.lastGetAuth, isTrue);
      result.fold((failure) => fail(failure.message), (appointments) {
        expect(appointments, hasLength(1));
        expect(appointments.single.id, 17);
        expect(appointments.single.doctorSpecialization, 'Cardiology');
        expect(appointments.single.patientName, isEmpty);
      });
    },
  );

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

  testWidgets('patient profile displays available contact information', (
    tester,
  ) async {
    await _setPhoneSize(tester);
    final controller = PatientHomeControllerImp(
      _FakeHomeData(),
      autoLoad: false,
    )..patient = _profile;
    Get.put<PatientHomeControllerImp>(controller);

    await tester.pumpWidget(_app(locale: const Locale('en')));
    await tester.pumpAndSettle();
    controller.showProfile();
    await tester.pumpAndSettle();

    expect(find.text('Personal information'), findsOneWidget);
    expect(find.text('+966500000000'), findsOneWidget);
    expect(find.text('Riyadh'), findsOneWidget);
    expect(find.text('Prefers morning appointments'), findsOneWidget);
    expect(find.textContaining('13'), findsNothing);
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

  testWidgets('Arabic appointment filters remain localized and RTL', (
    tester,
  ) async {
    await _setPhoneSize(tester);
    final controller =
        PatientHomeControllerImp(_FakeHomeData(), autoLoad: false)
          ..patient = _profile
          ..appointments = [
            _appointment(
              date: DateTime.now().add(const Duration(days: 1)),
              status: 'Pending',
            ),
          ];
    Get.put<PatientHomeControllerImp>(controller);

    await tester.pumpWidget(_app(locale: const Locale('ar')));
    controller.showAppointments();
    await tester.pumpAndSettle();

    final upcoming = find.text('upcoming'.tr);
    expect(upcoming, findsOneWidget);
    expect(find.text('completed'.tr), findsOneWidget);
    expect(find.text('cancelled'.tr), findsWidgets);
    expect(Directionality.of(tester.element(upcoming)), TextDirection.rtl);
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
  phoneNumber: '+966500000000',
  address: 'Riyadh',
  note: 'Prefers morning appointments',
  bloodType: 'A+',
  age: 29,
  gender: 1,
);

DoctorDetailsModel _doctor({
  int id = 4,
  String firstName = 'Sarah',
  String specialization = 'Cardiology',
  String? imagePath,
}) => DoctorDetailsModel(
  id: id,
  personId: 10,
  firstName: firstName,
  lastName: 'Ali',
  age: 38,
  experienceYears: 8,
  note: 'Heart specialist',
  specialization: specialization,
  imagePath: imagePath,
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
  _FakeHomeData({this.appointments = const [], this.doctors})
    : super(ApiService());

  final List<AppointmentModel> appointments;
  final List<DoctorDetailsModel>? doctors;

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
      Right(doctors ?? [_doctor()]);

  @override
  Future<Either<Failure, List<AppointmentModel>>>
  getPatientAppointments() async => Right(appointments);

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getPatientResource(
    PatientResourceType type, {
    int? patientId,
  }) async => const Right([]);
}

class _RecordingApiService extends ApiService {
  _RecordingApiService(this.response);

  final Object? response;
  String? lastGetUrl;
  bool? lastGetAuth;

  @override
  Future<Either<Failure, dynamic>> get(String url, {bool auth = false}) async {
    lastGetUrl = url;
    lastGetAuth = auth;
    return Right(response);
  }
}

class _ProfileRecordingApiService extends ApiService {
  _ProfileRecordingApiService(this.responses);

  final Map<String, Object?> responses;
  final List<String> getUrls = [];
  final List<bool> authValues = [];

  @override
  Future<Either<Failure, dynamic>> get(String url, {bool auth = false}) async {
    getUrls.add(url);
    authValues.add(auth);
    return Right(responses[url]);
  }
}
