import 'package:clinic_shifaa/Bindings/DoctorPatientDetailsBinding.dart';
import 'package:clinic_shifaa/Controller/Doctor/DoctorAppointmentsController.dart';
import 'package:clinic_shifaa/Controller/Doctor/DoctorHome_Controller.dart';
import 'package:clinic_shifaa/Controller/Doctor/DoctorPatientDetailsController.dart';
import 'package:clinic_shifaa/View/Screen/Doctor/CreateMedicalRecordPage.dart';
import 'package:clinic_shifaa/core/Error/Failure.dart';
import 'package:clinic_shifaa/core/class/ApiService.dart';
import 'package:clinic_shifaa/core/constant/Approutes.dart';
import 'package:clinic_shifaa/core/localization/translation.dart';
import 'package:clinic_shifaa/data/datasource/remote/Appointments/DoctorAppointmentData.dart';
import 'package:clinic_shifaa/data/datasource/remote/Doctors/DactorData.dart';
import 'package:clinic_shifaa/data/datasource/remote/Patients/DoctorPatientDetailsData.dart';
import 'package:clinic_shifaa/data/model/DoctorAppointmentModel.dart';
import 'package:clinic_shifaa/data/model/DoctorPatientDetailsModels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  setUp(() => Get.testMode = true);
  tearDown(Get.reset);

  testWidgets(
    'create controller submits and returns success without patient details',
    (tester) async {
      final api = _MedicalRecordApi(
        postResult: const Right<Failure, dynamic>(null),
      );
      Object? returnedResult;
      await _pumpCreateForm(
        tester,
        api: api,
        arguments: _arguments(patientId: 24, appointmentId: 18),
        onResult: (result) => returnedResult = result,
      );

      expect(find.byType(CreateMedicalRecordPage), findsOneWidget);
      expect(find.text('The selected appointment is invalid.'), findsNothing);

      await tester.enterText(find.byType(TextFormField).first, 'Diagnosis');
      await tester.tap(find.byIcon(Icons.add_rounded));
      await _pumpPastSnackbar(tester);

      expect(api.postCalls, 1);
      expect(api.lastPostBody, {
        'appointmentId': 18,
        'diagnosis': 'Diagnosis',
        'visitDescription': null,
        'notes': null,
      });
      expect(returnedResult, isA<CreatedMedicalRecordResult>());
      expect(
        (returnedResult as CreatedMedicalRecordResult).medicalRecordId,
        isNull,
      );
    },
  );

  testWidgets(
    'matching patient details controller is synchronized after creation',
    (tester) async {
      final api = _MedicalRecordApi(
        postResult: const Right<Failure, dynamic>({'medicalRecordId': 71}),
      );
      final parent = _TrackingPatientDetailsController(
        api,
        currentPatientId: 24,
      );
      Get.put<DoctorPatientDetailsController>(parent, permanent: true);

      await _pumpCreateForm(
        tester,
        api: api,
        arguments: _arguments(patientId: 24, appointmentId: 18),
      );
      await tester.enterText(find.byType(TextFormField).first, 'Diagnosis');
      await tester.tap(find.byIcon(Icons.add_rounded));
      await _pumpPastSnackbar(tester);

      expect(parent.markedAppointmentIds, [18]);
      expect(parent.mergedRecord?.medicalRecordId, 71);
      expect(parent.mergedRecord?.appointmentId, 18);
      expect(parent.medicalRecordRefreshes, 1);
    },
  );

  testWidgets('mismatched patient details controller is ignored', (
    tester,
  ) async {
    final api = _MedicalRecordApi(
      postResult: const Right<Failure, dynamic>({'id': 72}),
    );
    final parent = _TrackingPatientDetailsController(
      api,
      currentPatientId: 999,
    );
    Get.put<DoctorPatientDetailsController>(parent, permanent: true);

    await _pumpCreateForm(
      tester,
      api: api,
      arguments: _arguments(patientId: 24, appointmentId: 18),
    );
    expect(find.text('The selected appointment is invalid.'), findsNothing);

    await tester.enterText(find.byType(TextFormField).first, 'Diagnosis');
    await tester.tap(find.byIcon(Icons.add_rounded));
    await _pumpPastSnackbar(tester);

    expect(api.postCalls, 1);
    expect(parent.markedAppointmentIds, isEmpty);
    expect(parent.mergedRecord, isNull);
    expect(parent.medicalRecordRefreshes, 0);
  });

  testWidgets('invalid form arguments still show invalid state', (
    tester,
  ) async {
    final api = _MedicalRecordApi();
    await _pumpCreateForm(
      tester,
      api: api,
      arguments: _arguments(
        patientId: 24,
        appointmentId: 18,
        embeddedAppointmentId: 19,
      ),
    );

    expect(find.text('The selected appointment is invalid.'), findsOneWidget);
    expect(find.byType(TextFormField), findsNothing);
    expect(api.postCalls, 0);
  });

  testWidgets('HTTP 409 keeps the form open and shows duplicate message', (
    tester,
  ) async {
    final api = _MedicalRecordApi(
      postResult: const Left<Failure, dynamic>(
        ServerFailure('Conflict', statusCode: 409),
      ),
    );
    final appointmentsApi = _AppointmentsRefreshApi();
    Get.put<DoctorAppointmentsController>(
      DoctorAppointmentsController(DoctorAppointmentData(appointmentsApi)),
      permanent: true,
    );
    await _pumpCreateForm(
      tester,
      api: api,
      arguments: _arguments(patientId: 24, appointmentId: 18),
    );
    appointmentsApi.getCalls = 0;

    await tester.enterText(find.byType(TextFormField).first, 'Diagnosis');
    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pump();

    expect(find.byType(CreateMedicalRecordPage), findsOneWidget);
    expect(find.text('Already has a medical record.'), findsWidgets);
    expect(find.text('Diagnosis'), findsWidgets);
    expect(api.postCalls, 1);
    expect(appointmentsApi.getCalls, 1);
    await _pumpPastSnackbar(tester);
  });

  testWidgets(
    'appointments navigation maps arguments and refreshes list and home',
    (tester) async {
      final api = _AppointmentsRefreshApi();
      final controller = DoctorAppointmentsController(
        DoctorAppointmentData(api),
      );
      final home = _TrackingDoctorHomeController(api);
      Get.put<DoctorAppointmentsController>(controller, permanent: true);
      Get.put<DoctorHomeController>(home, permanent: true);

      Object? capturedArguments;
      await tester.pumpWidget(
        GetMaterialApp(
          translations: MyTranslation(),
          locale: const Locale('en'),
          home: const Scaffold(body: Text('Appointments')),
          getPages: [
            GetPage(
              name: Approutes.createMedicalRecord,
              page: () => Builder(
                builder: (context) {
                  capturedArguments = Get.arguments;
                  return Scaffold(
                    body: TextButton(
                      key: const ValueKey('return-create-success'),
                      onPressed: () => Get.back(
                        result: const CreatedMedicalRecordResult(
                          medicalRecordId: 90,
                        ),
                      ),
                      child: const Text('Return success'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();
      api.getCalls = 0;
      controller.selectedStatus = 'Completed';
      controller.selectedDate = DateTime(2026, 7, 27);
      final source = _appointment();

      final navigation = controller.openCreateMedicalRecord(source);
      await tester.pumpAndSettle();

      final arguments = capturedArguments as MedicalRecordFormArguments;
      expect(arguments.patientId, source.patientId);
      expect(arguments.appointmentId, source.id);
      expect(arguments.appointment.appointmentId, source.id);
      expect(arguments.appointment.patientId, source.patientId);
      expect(arguments.appointment.patientName, source.patientName);
      expect(arguments.appointment.patientImage, source.patientImage);
      expect(arguments.appointment.appointmentDate, source.appointmentDate);
      expect(arguments.appointment.status, source.status);
      expect(arguments.appointment.lastStatusDate, source.lastStatusDate);
      expect(arguments.appointment.note, source.notes);

      await tester.tap(find.byKey(const ValueKey('return-create-success')));
      await tester.pumpAndSettle();
      await navigation;

      expect(api.getCalls, 1);
      expect(controller.selectedStatus, 'Completed');
      expect(controller.selectedDate, DateTime(2026, 7, 27));
      expect(home.appointmentRefreshes, 1);
      expect(Get.find<DoctorHomeController>(), same(home));
      expect(controller.isOpeningCreateMedicalRecord, isFalse);
    },
  );
}

Future<void> _pumpPastSnackbar(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(seconds: 4));
  await tester.pumpAndSettle();
}

Future<void> _pumpCreateForm(
  WidgetTester tester, {
  required _MedicalRecordApi api,
  required MedicalRecordFormArguments arguments,
  ValueChanged<Object?>? onResult,
}) async {
  Get.put<ApiService>(api, permanent: true);
  await tester.pumpWidget(
    GetMaterialApp(
      translations: MyTranslation(),
      locale: const Locale('en'),
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              final result = await Get.toNamed(
                Approutes.createMedicalRecord,
                arguments: arguments,
              );
              onResult?.call(result);
            },
            child: const Text('Open create form'),
          ),
        ),
      ),
      getPages: [
        GetPage(
          name: Approutes.createMedicalRecord,
          page: () => const CreateMedicalRecordPage(),
          binding: CreateMedicalRecordBinding(),
        ),
      ],
    ),
  );
  await tester.tap(find.text('Open create form'));
  await tester.pumpAndSettle();
}

MedicalRecordFormArguments _arguments({
  required int patientId,
  required int appointmentId,
  int? embeddedAppointmentId,
}) {
  return MedicalRecordFormArguments(
    patientId: patientId,
    appointmentId: appointmentId,
    appointment: DoctorPatientAppointmentDetailsModel(
      appointmentId: embeddedAppointmentId ?? appointmentId,
      patientId: patientId,
      patientName: 'Patient',
      patientImage: 'patient.png',
      appointmentDate: DateTime(2026, 7, 27, 12),
      status: 'Completed',
      lastStatusDate: DateTime(2026, 7, 27, 13),
      note: 'Appointment note',
    ),
  );
}

DoctorAppointmentModel _appointment() {
  return DoctorAppointmentModel(
    id: 18,
    patientId: 24,
    patientName: 'Patient',
    patientImage: 'patient.png',
    appointmentDate: DateTime(2026, 7, 27, 12),
    status: ' Completed ',
    lastStatusDate: DateTime(2026, 7, 27, 13),
    medicalRecordId: null,
    notes: 'Appointment note',
  );
}

class _MedicalRecordApi extends ApiService {
  _MedicalRecordApi({
    this.postResult = const Right<Failure, dynamic>({'medicalRecordId': 70}),
  });

  Either<Failure, dynamic> postResult;
  int postCalls = 0;
  Map<String, dynamic>? lastPostBody;

  @override
  Future<Either<Failure, dynamic>> post(
    String url,
    Map<String, dynamic> data, {
    bool auth = false,
  }) async {
    postCalls++;
    lastPostBody = Map<String, dynamic>.from(data);
    return postResult;
  }
}

class _TrackingPatientDetailsController extends DoctorPatientDetailsController {
  _TrackingPatientDetailsController(
    ApiService api, {
    required this.currentPatientId,
  }) : super(DoctorPatientDetailsData(api));

  final int currentPatientId;
  final List<int> markedAppointmentIds = <int>[];
  DoctorPatientMedicalRecordModel? mergedRecord;
  int medicalRecordRefreshes = 0;
  bool existingRecord = false;

  @override
  Future<void> loadAll({bool refreshing = false}) async {}

  @override
  int get patientId => currentPatientId;

  @override
  bool get hasValidPatientId => currentPatientId > 0;

  @override
  bool hasMedicalRecord(int appointmentId) => existingRecord;

  @override
  void markAppointmentHasMedicalRecord(int appointmentId) {
    markedAppointmentIds.add(appointmentId);
  }

  @override
  void mergeCreatedMedicalRecord(DoctorPatientMedicalRecordModel record) {
    mergedRecord = record;
  }

  @override
  Future<void> refreshMedicalRecords() async {
    medicalRecordRefreshes++;
  }
}

class _AppointmentsRefreshApi extends ApiService {
  int getCalls = 0;

  @override
  Future<Either<Failure, dynamic>> get(String url, {bool auth = false}) async {
    getCalls++;
    return const Right<Failure, dynamic>({
      'items': <dynamic>[],
      'page': 1,
      'pageSize': 10,
      'totalCount': 0,
      'totalPages': 0,
    });
  }
}

class _TrackingDoctorHomeController extends DoctorHomeController {
  _TrackingDoctorHomeController(ApiService api)
    : super(DoctorData(api), DoctorAppointmentData(api));

  int appointmentRefreshes = 0;

  @override
  Future<void> loadDashboard() async {}

  @override
  Future<void> refreshAppointments() async {
    appointmentRefreshes++;
  }
}
