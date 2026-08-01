import 'package:clinic_shifaa/Controller/Patient/PatientBookingController.dart';
import 'package:clinic_shifaa/core/Error/Failure.dart';
import 'package:clinic_shifaa/core/class/ApiService.dart';
import 'package:clinic_shifaa/core/constant/ApiLinks.dart';
import 'package:clinic_shifaa/data/datasource/remote/Home/HomeData.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'available appointments use doctor and date query with authentication',
    () async {
      final api = _RecordingApiService(
        getResponse: [
          {
            'startTime': '2026-08-04T12:00:00',
            'endTime': '2026-08-04T12:40:00',
          },
        ],
      );

      final result = await HomeData(
        api,
      ).getAvailableSlots(doctorId: 14, date: DateTime(2026, 8, 4));

      expect(
        api.lastGetUrl,
        ApiLinks.availableSlots(doctorId: 14, date: '2026-08-04'),
      );
      expect(api.lastGetAuth, isTrue);
      result.fold((failure) => fail(failure.message), (slots) {
        expect(slots, hasLength(1));
        expect(slots.single.startTime, DateTime(2026, 8, 4, 12));
        expect(slots.single.endTime, DateTime(2026, 8, 4, 12, 40));
      });
    },
  );

  test('booking posts only backend DTO fields with authentication', () async {
    final api = _RecordingApiService(
      postResponse: {
        'isSuccess': true,
        'value': {'id': 31},
      },
    );
    final appointmentDate = DateTime(2026, 8, 4, 13, 20);

    final result = await HomeData(
      api,
    ).createAppointment(doctorId: 14, appointmentDate: appointmentDate);

    expect(result.isRight, isTrue);
    expect(api.lastPostUrl, ApiLinks.createAppointment);
    expect(api.lastPostAuth, isTrue);
    expect(api.lastPostBody, {
      'doctorId': 14,
      'appointmentDate': appointmentDate.toIso8601String(),
    });
    expect(api.lastPostBody, isNot(contains('patientId')));
  });

  test('booking treats an unsuccessful backend Result as a failure', () async {
    final api = _RecordingApiService(
      postResponse: {
        'isSuccess': false,
        'errors': [
          {'description': 'This appointment time is already booked.'},
        ],
      },
    );

    final result = await HomeData(api).createAppointment(
      doctorId: 14,
      appointmentDate: DateTime(2026, 8, 4, 13, 20),
    );

    expect(result.isLeft, isTrue);
    result.fold(
      (failure) => expect(failure.message, contains('already booked')),
      (_) => fail('Expected a failed backend Result to remain a failure.'),
    );
  });
}

class _RecordingApiService extends ApiService {
  _RecordingApiService({this.getResponse, this.postResponse});

  final Object? getResponse;
  final Object? postResponse;
  String? lastGetUrl;
  bool? lastGetAuth;
  String? lastPostUrl;
  Map<String, dynamic>? lastPostBody;
  bool? lastPostAuth;

  @override
  Future<Either<Failure, dynamic>> get(String url, {bool auth = false}) async {
    lastGetUrl = url;
    lastGetAuth = auth;
    return Right(getResponse);
  }

  @override
  Future<Either<Failure, dynamic>> post(
    String url,
    Map<String, dynamic> data, {
    bool auth = false,
  }) async {
    lastPostUrl = url;
    lastPostBody = data;
    lastPostAuth = auth;
    return Right(postResponse);
  }
}
