import 'package:clinic_shifaa/Bindings/DoctorHomeBinding.dart';
import 'package:clinic_shifaa/Controller/Doctor/DoctorAppointmentsController.dart';
import 'package:clinic_shifaa/Controller/Doctor/DoctorHome_Controller.dart';
import 'package:clinic_shifaa/Controller/Doctor/DoctorPatientsController.dart';
import 'package:clinic_shifaa/Controller/Doctor/DoctorProfileController.dart';
import 'package:clinic_shifaa/View/Screen/Doctor/DoctorHomePage.dart';
import 'package:clinic_shifaa/core/Error/Failure.dart';
import 'package:clinic_shifaa/core/class/ApiService.dart';
import 'package:clinic_shifaa/core/constant/ApiLinks.dart';
import 'package:clinic_shifaa/core/constant/Approutes.dart';
import 'package:clinic_shifaa/core/localization/translation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  testWidgets('doctor tab controllers survive repeated tab switches', (
    tester,
  ) async {
    addTearDown(Get.reset);
    final api = _DoctorTabsApiService();
    Get.put<ApiService>(api, permanent: true);

    await tester.pumpWidget(
      GetMaterialApp(
        translations: MyTranslation(),
        locale: const Locale('en'),
        initialRoute: Approutes.doctorHome,
        getPages: [
          GetPage(
            name: Approutes.doctorHome,
            page: () => const DoctorHomePage(),
            binding: DoctorHomeBinding(),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(Get.isRegistered<DoctorHomeController>(), isTrue);
    expect(Get.isRegistered<DoctorAppointmentsController>(), isTrue);
    expect(Get.isRegistered<DoctorPatientsController>(), isTrue);
    expect(Get.isRegistered<DoctorProfileController>(), isTrue);

    final home = Get.find<DoctorHomeController>();

    home.selectTab(1);
    await tester.pumpAndSettle();
    final appointments = Get.find<DoctorAppointmentsController>();
    expect(api.callsTo(ApiLinks.doctorAppointments), 1);

    home.selectTab(0);
    await tester.pump();
    home.selectTab(1);
    await tester.pumpAndSettle();
    expect(Get.find<DoctorAppointmentsController>(), same(appointments));
    expect(api.callsTo(ApiLinks.doctorAppointments), 1);

    home.selectTab(2);
    await tester.pumpAndSettle();
    final patients = Get.find<DoctorPatientsController>();
    expect(api.callsTo(ApiLinks.doctorPatients), 1);

    home.selectTab(0);
    await tester.pump();
    home.selectTab(2);
    await tester.pumpAndSettle();
    expect(Get.find<DoctorPatientsController>(), same(patients));
    expect(api.callsTo(ApiLinks.doctorPatients), 1);

    home.selectTab(3);
    await tester.pumpAndSettle();
    final profile = Get.find<DoctorProfileController>();
    final profileCalls = api.callsTo(ApiLinks.currentDoctor);
    expect(find.text('4'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);

    home.selectTab(0);
    await tester.pump();
    home.selectTab(3);
    await tester.pumpAndSettle();
    expect(Get.find<DoctorProfileController>(), same(profile));
    expect(api.callsTo(ApiLinks.currentDoctor), profileCalls);
    expect(tester.takeException(), isNull);
  });
}

class _DoctorTabsApiService extends ApiService {
  final Map<String, int> _calls = {};

  int callsTo(String endpoint) => _calls[endpoint] ?? 0;

  @override
  Future<Either<Failure, dynamic>> get(String url, {bool auth = false}) async {
    final uri = Uri.parse(url);
    final endpoint = '${uri.scheme}://${uri.authority}${uri.path}';
    _calls.update(endpoint, (value) => value + 1, ifAbsent: () => 1);

    if (endpoint == ApiLinks.currentDoctor) {
      return const Right({
        'id': 14,
        'personId': 41,
        'firstName': 'Ahmed',
        'lastName': 'Ali',
        'age': 35,
        'note': null,
        'experienceYears': 8,
        'specialization': 'Dentist',
        'imagePath': null,
        'userId': 33,
      });
    }
    if (endpoint == ApiLinks.doctorAppointmentSummary) {
      return const Right({
        'todayAppointments': 0,
        'pendingAppointments': 0,
        'completedAppointments': 0,
        'cancelledAppointments': 1,
      });
    }
    if (endpoint == ApiLinks.doctorAppointments) {
      return const Right({'items': <dynamic>[], 'totalCount': 4});
    }
    if (endpoint == ApiLinks.doctorPatients) {
      return const Right([
        {
          'patientId': 23,
          'patientName': 'test test',
          'patientImage': 'test',
          'bloodType': 'A-',
          'appointmentsCount': 1,
          'lastAppointmentDate': null,
        },
      ]);
    }
    return const Right([]);
  }
}
