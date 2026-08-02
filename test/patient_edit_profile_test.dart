import 'package:clinic_shifaa/Controller/Patient/HomeController.dart';
import 'package:clinic_shifaa/View/Screen/Patient/PatientEditProfilePage.dart';
import 'package:clinic_shifaa/View/Screen/Patient/PatientHomePage.dart';
import 'package:clinic_shifaa/core/Error/Failure.dart';
import 'package:clinic_shifaa/core/class/ApiService.dart';
import 'package:clinic_shifaa/core/constant/Approutes.dart';
import 'package:clinic_shifaa/core/localization/translation.dart';
import 'package:clinic_shifaa/data/datasource/remote/Home/HomeData.dart';
import 'package:clinic_shifaa/data/model/AppointmentModel.dart';
import 'package:clinic_shifaa/data/model/DoctorModel.dart';
import 'package:clinic_shifaa/data/model/PatientHomeProfileModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => Get.testMode = true);
  tearDown(Get.reset);

  testWidgets(
    'patient edits supported fields, submits once, and refreshes profile',
    (tester) async {
      await _setPhoneSize(tester);
      final data = _EditableHomeData();
      final controller = PatientHomeControllerImp(data, autoLoad: false)
        ..patient = data.profile
        ..selectedTab = 3;
      Get.put<PatientHomeControllerImp>(controller);

      await tester.pumpWidget(_app(const Locale('en')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('patient-edit-profile-button')));
      await tester.pumpAndSettle();

      expect(
        find.text('Update your personal and health information.'),
        findsOneWidget,
      );
      expect(controller.patientFirstNameController.text, 'Roqaia');
      expect(controller.patientPhoneController.text, '+966500000000');
      expect(controller.selectedPatientBloodType, 'A+');

      await tester.enterText(
        find.widgetWithText(TextFormField, 'First name'),
        'Mona',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Phone number'),
        '+966511111111',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Address'),
        'Jeddah',
      );

      final firstSave = controller.savePatientProfile();
      final repeatedSave = controller.savePatientProfile();
      await Future.wait([firstSave, repeatedSave]);
      await tester.pumpAndSettle();
      Get.closeAllSnackbars();
      await tester.pumpAndSettle();

      expect(data.personUpdateCalls, 1);
      expect(data.patientUpdateCalls, 1);
      expect(data.profileLoadCalls, 1);
      expect(data.lastPersonId, 9);
      expect(data.lastPatientId, 13);
      expect(data.lastNationalityNo, '1234567890');
      expect(data.lastNationalityCountryId, 1);
      expect(data.lastBloodType, 'A+');
      expect(controller.patient?.firstName, 'Mona');
      expect(controller.patient?.phoneNumber, '+966511111111');
      expect(controller.patient?.address, 'Jeddah');
      expect(find.byType(PatientHomePage), findsOneWidget);
      expect(find.text('Mona Ahmed'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('patient edit page is localized and RTL in Arabic', (
    tester,
  ) async {
    await _setPhoneSize(tester);
    final data = _EditableHomeData();
    final controller = PatientHomeControllerImp(data, autoLoad: false)
      ..patient = data.profile;
    expect(controller.preparePatientProfileEdit(), isTrue);
    Get.put<PatientHomeControllerImp>(controller);

    await tester.pumpWidget(
      GetMaterialApp(
        locale: const Locale('ar'),
        translations: MyTranslation(),
        home: const PatientEditProfilePage(),
      ),
    );
    await tester.pumpAndSettle();

    final title = find.text('تعديل الملف الشخصي');
    expect(title, findsOneWidget);
    expect(find.text('حدّث معلوماتك الشخصية والصحية.'), findsOneWidget);
    expect(Directionality.of(tester.element(title)), TextDirection.rtl);
    await tester.scrollUntilVisible(
      find.byKey(const Key('patient-profile-save-button')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('حفظ التغييرات'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Widget _app(Locale locale) => GetMaterialApp(
  locale: locale,
  translations: MyTranslation(),
  initialRoute: Approutes.HomeScreen,
  getPages: [
    GetPage(name: Approutes.HomeScreen, page: () => const PatientHomePage()),
    GetPage(
      name: Approutes.patientEditProfile,
      page: () => const PatientEditProfilePage(),
    ),
  ],
);

Future<void> _setPhoneSize(WidgetTester tester) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(390, 844);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

class _EditableHomeData extends HomeData {
  _EditableHomeData() : super(ApiService());

  var profile = const PatientHomeProfileModel(
    userId: 7,
    patientId: 13,
    personId: 9,
    firstName: 'Roqaia',
    lastName: 'Ahmed',
    email: 'patient@example.com',
    phoneNumber: '+966500000000',
    address: 'Riyadh',
    note: 'Prefers morning appointments',
    nationalityNo: '1234567890',
    nationalityCountryId: 1,
    bloodType: 'A+',
    age: 29,
    gender: 1,
  );
  int personUpdateCalls = 0;
  int patientUpdateCalls = 0;
  int profileLoadCalls = 0;
  int? lastPersonId;
  int? lastPatientId;
  String? lastNationalityNo;
  int? lastNationalityCountryId;
  String? lastBloodType;

  @override
  Future<int?> getAuthenticatedUserId() async => 7;

  @override
  Future<String?> getAuthenticatedEmail() async => 'patient@example.com';

  @override
  Future<Either<Failure, PatientHomeProfileModel>> getPatientProfile({
    required int userId,
    String? email,
  }) async {
    profileLoadCalls++;
    return Right(profile);
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> updatePersonProfile({
    required int personId,
    required String firstName,
    required String lastName,
    required String nationalityNo,
    required String? phoneNumber,
    required int? age,
    required String? address,
    required int gender,
    required int nationalityCountryId,
    required String? imagePath,
    required String? note,
  }) async {
    personUpdateCalls++;
    lastPersonId = personId;
    lastNationalityNo = nationalityNo;
    lastNationalityCountryId = nationalityCountryId;
    profile = PatientHomeProfileModel(
      userId: profile.userId,
      patientId: profile.patientId,
      personId: profile.personId,
      firstName: firstName,
      lastName: lastName,
      email: profile.email,
      phoneNumber: phoneNumber,
      address: address,
      note: note,
      nationalityNo: nationalityNo,
      nationalityCountryId: nationalityCountryId,
      imagePath: imagePath,
      bloodType: profile.bloodType,
      age: age,
      gender: gender,
    );
    return const Right({'id': 9});
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> updatePatientProfile({
    required int patientId,
    required int personId,
    required String bloodType,
  }) async {
    patientUpdateCalls++;
    lastPatientId = patientId;
    lastBloodType = bloodType;
    profile = PatientHomeProfileModel(
      userId: profile.userId,
      patientId: profile.patientId,
      personId: profile.personId,
      firstName: profile.firstName,
      lastName: profile.lastName,
      email: profile.email,
      phoneNumber: profile.phoneNumber,
      address: profile.address,
      note: profile.note,
      nationalityNo: profile.nationalityNo,
      nationalityCountryId: profile.nationalityCountryId,
      imagePath: profile.imagePath,
      bloodType: bloodType,
      age: profile.age,
      gender: profile.gender,
    );
    return const Right({'bloodType': 'A+', 'personId': 9});
  }

  @override
  Future<Either<Failure, List<DoctorDetailsModel>>> getDoctors() async =>
      const Right([]);

  @override
  Future<Either<Failure, List<AppointmentModel>>>
  getPatientAppointments() async => const Right([]);
}
