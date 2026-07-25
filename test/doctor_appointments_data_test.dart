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
      'pending': 0,
      'completed': 0,
      'cancelled': 0,
    });
    expect(value.pending, 0);
    expect(value.completed, 0);
    expect(value.cancelled, 0);
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

  test('summary rejects genuinely malformed response', () {
    expect(
      () => DoctorAppointmentSummary.fromResponse({'data': []}),
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

  test('cancel and complete propagate success and failure', () async {
    final api = _FakeApiService();
    final data = DoctorAppointmentData(api);

    expect((await data.cancelAppointment(4)).isRight, isTrue);
    expect(api.lastUrl, endsWith('/Appointments/4/cancel'));

    api.putResult = const Left(ServerFailure('Forbidden', statusCode: 403));
    expect((await data.completeAppointment(4)).isLeft, isTrue);
    expect(api.lastUrl, endsWith('/Appointments/4/complete'));
  });
}

class _FakeApiService extends ApiService {
  String? lastUrl;
  bool usedAuth = false;
  Either<Failure, dynamic> putResult = const Right(null);

  @override
  Future<Either<Failure, dynamic>> get(String url, {bool auth = false}) async {
    lastUrl = url;
    usedAuth = auth;
    return const Right([]);
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
