import 'package:clinic_shifaa/Controller/Doctor/DoctorAppointmentsController.dart';
import 'package:clinic_shifaa/Controller/Doctor/DoctorPatientsController.dart';
import 'package:clinic_shifaa/core/Error/Failure.dart';
import 'package:clinic_shifaa/core/class/ApiService.dart';
import 'package:clinic_shifaa/data/datasource/remote/Appointments/DoctorAppointmentData.dart';
import 'package:clinic_shifaa/data/model/AppointmentModel.dart';
import 'package:clinic_shifaa/data/model/DoctorAppointmentSummary.dart';
import 'package:clinic_shifaa/data/model/DoctorPatientModel.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('summary parses only backend summary fields', () {
    final value = DoctorAppointmentSummary.fromJson({
      'pending': 2,
      'completed': 3,
      'cancelled': 1,
    });
    expect(value.pending, 2);
    expect(value.completed, 3);
    expect(value.cancelled, 1);
  });

  test('summary accepts direct zero values', () {
    final value = DoctorAppointmentSummary.fromResponse({
      'todayAppointments': 0,
      'pendingAppointments': 0,
      'completedAppointments': 0,
      'cancelledAppointments': 1,
    });
    expect(value.todayAppointments, 0);
    expect(value.pending, 0);
    expect(value.completed, 0);
    expect(value.cancelled, 1);
  });

  test('summary treats a successful no-content response as zero counts', () {
    final value = DoctorAppointmentSummary.fromResponse(null);
    expect([value.pending, value.completed, value.cancelled], [0, 0, 0]);
  });

  test('summary accepts data and result wrappers', () {
    final dataValue = DoctorAppointmentSummary.fromResponse({
      'data': {'pending': '1', 'completed': 2, 'cancelled': null},
    });
    final resultValue = DoctorAppointmentSummary.fromResponse({
      'result': {'pending': 3, 'completed': '4', 'cancelled': 5},
    });
    expect(
      [dataValue.pending, dataValue.completed, dataValue.cancelled],
      [1, 2, 0],
    );
    expect(
      [resultValue.pending, resultValue.completed, resultValue.cancelled],
      [3, 4, 5],
    );
  });

  test('summary accepts ASP.NET casing and count field names', () {
    final value = DoctorAppointmentSummary.fromResponse({
      'Data': {'PendingCount': 1, 'CompletedCount': '2', 'CancelledCount': 3},
    });
    expect([value.pending, value.completed, value.cancelled], [1, 2, 3]);
  });

  test('summary accepts status/count collection wrappers', () {
    final value = DoctorAppointmentSummary.fromResponse({
      r'$values': [
        {'status': 'Pending', 'count': 1},
        {'status': 'Completed', 'count': 2},
        {'status': 'Cancelled', 'count': 3},
      ],
    });
    expect([value.pending, value.completed, value.cancelled], [1, 2, 3]);
  });

  test('summary treats missing grouped statuses as zero', () {
    final value = DoctorAppointmentSummary.fromResponse([
      {'status': 'Pending', 'count': 2},
    ]);
    expect([value.pending, value.completed, value.cancelled], [2, 0, 0]);
  });

  test('summary rejects genuinely malformed response', () {
    expect(
      () => DoctorAppointmentSummary.fromResponse({
        'data': ['invalid'],
      }),
      throwsFormatException,
    );
    expect(
      () => DoctorAppointmentSummary.fromResponse({'pending': 0}),
      throwsFormatException,
    );
  });

  test('appointment parses nullable values safely', () {
    final value = AppointmentModel.fromJson({
      'id': 1,
      'doctorId': 2,
      'patientId': 3,
      'appointmentDate': '2026-07-25T10:00:00',
      'status': 'Pending',
      'lastStatusDate': null,
      'medicalRecordId': null,
      'notes': null,
    });
    expect(value.status, 'Pending');
    expect(value.lastStatusDate, isNull);
  });

  test('appointments parse wrapped lists and ASP.NET casing', () {
    final values = AppointmentModel.listFromResponse({
      'Data': {
        r'$values': [
          {
            'Id': 1,
            'DoctorId': 2,
            'PatientId': 3,
            'AppointmentDate': '2026-07-25T10:00:00',
            'Status': 'Pending',
            'LastStatusDate': null,
            'MedicalRecordId': null,
            'Notes': null,
          },
        ],
      },
    });
    expect(values, hasLength(1));
    expect(values.single.id, 1);
    expect(values.single.status, 'Pending');
  });

  test('appointments treat a successful no-content response as empty', () {
    expect(AppointmentModel.listFromResponse(null), isEmpty);
  });

  test('patient parses fields supplied by doctor patient DTO', () {
    final value = DoctorPatientModel.fromJson({
      'patientId': 7,
      'patientName': 'Patient One',
      'patientImage': '',
      'bloodType': 'O+',
      'appointmentsCount': '4',
      'lastAppointmentDate': '2026-07-23T20:40:00.79',
    });
    expect(value.patientId, 7);
    expect(value.patientName, 'Patient One');
    expect(value.patientImage, isNull);
    expect(value.appointmentsCount, 4);
    expect(value.lastAppointmentDate, DateTime(2026, 7, 23, 20, 40, 0, 790));
  });

  test('patient safely handles nullable optional fields', () {
    final value = DoctorPatientModel.fromJson({
      'patientId': '23',
      'patientName': 'test test',
      'patientImage': null,
      'bloodType': null,
      'appointmentsCount': 1,
      'lastAppointmentDate': null,
    });
    expect(value.patientId, 23);
    expect(value.bloodType, isNull);
    expect(value.lastAppointmentDate, isNull);
  });

  test('appointment query omits empty filters and formats date', () async {
    final api = _FakeApiService();
    final data = DoctorAppointmentData(api);

    await data.getDoctorAppointments(
      status: '',
      date: DateTime(2026, 7, 25),
      page: 2,
      pageSize: 10,
    );

    final uri = Uri.parse(api.lastUrl!);
    expect(uri.queryParameters.containsKey('status'), isFalse);
    expect(uri.queryParameters['date'], '2026-07-25');
    expect(uri.queryParameters['page'], '2');
    expect(uri.queryParameters['pageSize'], '10');
    expect(api.usedAuth, isTrue);
  });

  test('Pending filter omits an empty date and builds the exact URL', () async {
    final api = _FakeApiService();
    final data = DoctorAppointmentData(api);

    await data.getDoctorAppointments(status: 'Pending', page: 1, pageSize: 10);

    expect(
      api.lastUrl,
      'http://192.168.8.4:5210/api/Appointments/doctor/me'
      '?status=Pending&page=1&pageSize=10',
    );
    expect(
      Uri.parse(api.lastUrl!).queryParameters.containsKey('date'),
      isFalse,
    );
    expect(api.usedAuth, isTrue);
  });

  test(
    'doctor appointment reads use authenticated existing endpoints',
    () async {
      final api = _FakeApiService();
      final data = DoctorAppointmentData(api);

      await data.getDoctorSummary();
      expect(api.lastUrl, endsWith('/Appointments/doctor/me/summary'));
      expect(api.usedAuth, isTrue);

      await data.getTodayDoctorAppointments();
      expect(api.lastUrl, endsWith('/Appointments/doctor/me/today'));
      expect(api.usedAuth, isTrue);

      await data.getDoctorAppointments();
      expect(Uri.parse(api.lastUrl!).path, endsWith('/Appointments/doctor/me'));
      expect(api.usedAuth, isTrue);

      await data.getDoctorPatients();
      expect(api.lastUrl, endsWith('/Appointments/doctor/me/patients'));
      expect(api.usedAuth, isTrue);
    },
  );

  test('cancel and complete propagate success and failure', () async {
    final api = _FakeApiService();
    final data = DoctorAppointmentData(api);

    expect((await data.cancelAppointment(4)).isRight, isTrue);
    expect(api.lastUrl, endsWith('/Appointments/4/cancel'));

    api.putResult = const Left(ServerFailure('Forbidden', statusCode: 403));
    expect((await data.completeAppointment(4)).isLeft, isTrue);
    expect(api.lastUrl, endsWith('/Appointments/4/complete'));
  });

  test('appointments total uses only a backend pagination total', () async {
    final api = _FakeApiService()
      ..getResult = {'items': <dynamic>[], 'totalCount': 17};
    final controller = DoctorAppointmentsController(DoctorAppointmentData(api));

    await controller.loadInitial();

    expect(controller.hasLoaded, isTrue);
    expect(controller.totalAppointments, 17);

    api.getResult = [
      {
        'id': 1,
        'doctorId': 2,
        'patientId': 3,
        'appointmentDate': '2026-07-25T10:00:00',
        'status': 'Confirmed',
      },
    ];
    await controller.refreshList();

    expect(controller.appointments, hasLength(1));
    expect(controller.totalAppointments, isNull);
  });

  test('appointments total failure and retry are isolated', () async {
    final api = _FakeApiService()
      ..getResult = const Left<Failure, dynamic>(
        ServerFailure('Appointments failed.'),
      );
    final controller = DoctorAppointmentsController(DoctorAppointmentData(api));

    await controller.loadInitial();

    expect(controller.appointmentsTotalFailure, isNotNull);
    expect(controller.totalAppointments, isNull);
    expect(controller.isAppointmentsTotalLoading, isFalse);

    api.getResult = const Right<Failure, dynamic>({
      'items': <dynamic>[],
      'totalItems': 0,
    });
    await controller.retryAppointmentsTotal();

    expect(
      api.lastUrl,
      'http://192.168.8.4:5210/api/Appointments/doctor/me?page=1&pageSize=10',
    );
    expect(controller.appointmentsTotalFailure, isNull);
    expect(controller.totalAppointments, 0);
  });

  test('patients count is unique and successful empty list is zero', () async {
    final api = _FakeApiService()
      ..getResult = [
        {
          'patientId': 23,
          'patientName': 'test test',
          'patientImage': 'test',
          'bloodType': 'A-',
          'appointmentsCount': 1,
          'lastAppointmentDate': '2026-07-23T20:40:00.79',
        },
        {
          'patientId': 23,
          'patientName': 'test test',
          'patientImage': 'test',
          'bloodType': 'A-',
          'appointmentsCount': 1,
          'lastAppointmentDate': '2026-07-23T20:40:00.79',
        },
      ];
    final controller = DoctorPatientsController(DoctorAppointmentData(api));

    await controller.load();

    expect(controller.hasLoaded, isTrue);
    expect(controller.uniquePatientsCount, 1);

    api.getResult = <dynamic>[];
    await controller.refreshPatients();

    expect(controller.hasLoaded, isTrue);
    expect(controller.uniquePatientsCount, 0);
  });
}

class _FakeApiService extends ApiService {
  String? lastUrl;
  bool usedAuth = false;
  dynamic getResult = const Right<Failure, dynamic>(<dynamic>[]);
  Either<Failure, dynamic> putResult = const Right(null);

  @override
  Future<Either<Failure, dynamic>> get(String url, {bool auth = false}) async {
    lastUrl = url;
    usedAuth = auth;
    final result = getResult;
    return result is Either<Failure, dynamic> ? result : Right(result);
  }

  @override
  Future<Either<Failure, dynamic>> put(
    String url,
    Map<String, dynamic> data, {
    bool auth = false,
  }) async {
    lastUrl = url;
    usedAuth = auth;
    return putResult;
  }
}
