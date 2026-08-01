import 'package:clinic_shifaa/Controller/Patient/HomeController.dart';
import 'package:clinic_shifaa/Controller/Patient/PatientBookingController.dart';
import 'package:clinic_shifaa/core/Error/Failure.dart';
import 'package:clinic_shifaa/core/class/ApiService.dart';
import 'package:clinic_shifaa/core/constant/ApiLinks.dart';
import 'package:clinic_shifaa/data/datasource/remote/Home/HomeData.dart';
import 'package:clinic_shifaa/data/model/AvailableSlotModel.dart';
import 'package:clinic_shifaa/data/model/AppointmentModel.dart';
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

  test(
    'patient payment flow does not call the unsafe global payment list',
    () async {
      final api = _RecordingApiService(getResponse: const []);

      final result = await HomeData(
        api,
      ).getPatientResource(PatientResourceType.payments, patientId: 9);

      expect(result.isLeft, isTrue);
      expect(api.lastGetUrl, isNull);
    },
  );

  test('payment creation uses the confirmed Swagger contract', () async {
    final api = _RecordingApiService(postResponse: 44);

    final result = await HomeData(api).createPayment(
      appointmentId: 31,
      paymentMethod: 'Card',
      amount: 125.5,
      note: 'Consultation',
    );

    expect(result.isRight, isTrue);
    expect(api.lastPostUrl, ApiLinks.createPayment);
    expect(api.lastPostAuth, isTrue);
    expect(api.lastPostBody, {
      'appointmentId': 31,
      'paymentMethod': 'Card',
      'amount': 125.5,
      'note': 'Consultation',
    });
  });

  test(
    'selected-doctor booking has independent slot and create state',
    () async {
      final slot = AvailableSlotModel(
        startTime: DateTime.now().add(const Duration(days: 1)),
        endTime: DateTime.now().add(const Duration(days: 1, minutes: 40)),
      );
      final data = _BookingHomeData(slot);
      final controller = PatientBookingController(data, doctorId: 14);

      await controller.loadAvailableSlots();
      controller.selectSlot(slot);
      final succeeded = await controller.bookSelectedSlot();

      expect(succeeded, isTrue);
      expect(controller.createdAppointmentId, 31);
      expect(data.requestedDoctorId, 14);
      expect(data.createdDoctorId, 14);
      expect(data.createdDate, slot.startTime);
      controller.onClose();
    },
  );

  test(
    'successful payment cannot be submitted twice in the patient flow',
    () async {
      final data = _PaymentHomeData();
      final controller = PatientHomeControllerImp(data, autoLoad: false);
      final appointment = AppointmentModel(
        id: 31,
        doctorName: 'Sarah Ali',
        doctorId: 14,
        patientId: 9,
        patientName: 'Patient',
        appointmentDate: DateTime.now().add(const Duration(days: 1)),
        status: 'Pending',
      );
      controller.registerCreatedAppointment(appointment.id);
      expect(controller.preparePayment(appointment), isTrue);
      controller.selectPaymentMethod('Card');

      final firstPayment = await controller.submitPayment(amount: 125.5);
      final repeatedPayment = await controller.submitPayment(amount: 125.5);

      expect(firstPayment, 44);
      expect(repeatedPayment, isNull);
      expect(data.createCalls, 1);
      controller.onClose();
    },
  );

  test(
    'failed payment retries the same appointment without rebooking',
    () async {
      final data = _RetryPaymentHomeData();
      final controller = PatientHomeControllerImp(data, autoLoad: false);
      final appointment = AppointmentModel(
        id: 31,
        doctorName: 'Sarah Ali',
        doctorId: 14,
        patientId: 9,
        patientName: 'Patient',
        appointmentDate: DateTime.now().add(const Duration(days: 1)),
        status: 'Pending',
      );
      controller.registerCreatedAppointment(appointment.id);
      expect(controller.preparePayment(appointment), isTrue);
      controller.selectPaymentMethod('Cash');

      final failedPayment = await controller.submitPayment(amount: 125.5);
      final retriedPayment = await controller.submitPayment(amount: 125.5);

      expect(failedPayment, isNull);
      expect(retriedPayment, 45);
      expect(data.paymentAppointmentIds, [31, 31]);
      expect(data.appointmentCreateCalls, 0);
      controller.onClose();
    },
  );
}

class _PaymentHomeData extends HomeData {
  _PaymentHomeData() : super(ApiService());

  int createCalls = 0;

  @override
  Future<Either<Failure, int>> createPayment({
    required int appointmentId,
    required String paymentMethod,
    required double amount,
    required String note,
  }) async {
    createCalls++;
    return const Right(44);
  }

  @override
  Future<Either<Failure, List<AppointmentModel>>>
  getPatientAppointments() async => const Right([]);
}

class _RetryPaymentHomeData extends HomeData {
  _RetryPaymentHomeData() : super(ApiService());

  final List<int> paymentAppointmentIds = [];
  int appointmentCreateCalls = 0;

  @override
  Future<Either<Failure, int>> createAppointment({
    required int doctorId,
    required DateTime appointmentDate,
  }) async {
    appointmentCreateCalls++;
    return const Right(99);
  }

  @override
  Future<Either<Failure, int>> createPayment({
    required int appointmentId,
    required String paymentMethod,
    required double amount,
    required String note,
  }) async {
    paymentAppointmentIds.add(appointmentId);
    if (paymentAppointmentIds.length == 1) {
      return const Left(NetworkFailure('Offline'));
    }
    return const Right(45);
  }

  @override
  Future<Either<Failure, List<AppointmentModel>>>
  getPatientAppointments() async => const Right([]);
}

class _BookingHomeData extends HomeData {
  _BookingHomeData(this.slot) : super(ApiService());

  final AvailableSlotModel slot;
  int? requestedDoctorId;
  int? createdDoctorId;
  DateTime? createdDate;

  @override
  Future<Either<Failure, List<AvailableSlotModel>>> getAvailableSlots({
    required int doctorId,
    required DateTime date,
  }) async {
    requestedDoctorId = doctorId;
    return Right([slot]);
  }

  @override
  Future<Either<Failure, int>> createAppointment({
    required int doctorId,
    required DateTime appointmentDate,
  }) async {
    createdDoctorId = doctorId;
    createdDate = appointmentDate;
    return const Right(31);
  }
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
