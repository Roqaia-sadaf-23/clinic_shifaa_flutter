import 'package:clinic_shifaa/core/Error/Failure.dart';
import 'package:clinic_shifaa/core/class/ApiService.dart';
import 'package:clinic_shifaa/core/constant/ApiLinks.dart';
import 'package:clinic_shifaa/data/datasource/remote/CompleteProfile/CompleteProfileData.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('patient endpoint constants match the backend controller routes', () {
    expect(ApiLinks.patients, '${ApiLinks.server}/Patient');
    expect(ApiLinks.createPatient, '${ApiLinks.server}/Patient/create');
    expect(
      ApiLinks.patientAppointments,
      '${ApiLinks.server}/Appointments/patient/me',
    );
    expect(
      ApiLinks.createAppointment,
      '${ApiLinks.server}/Appointments/create',
    );
    expect(ApiLinks.doctors, '${ApiLinks.server}/Doctors');
    expect(ApiLinks.doctorById(9), '${ApiLinks.server}/Doctors/9');
    expect(
      ApiLinks.availableSlots(doctorId: 9, date: '2026-08-04'),
      '${ApiLinks.server}/Appointments/available-slots'
      '?doctorId=9&date=2026-08-04',
    );
  });

  test('authenticated doctor appointment routes remain exact', () {
    expect(
      ApiLinks.doctorAppointments,
      '${ApiLinks.server}/Appointments/doctor/me',
    );
    expect(
      ApiLinks.todayDoctorAppointments,
      '${ApiLinks.server}/Appointments/doctor/me/today',
    );
    expect(
      ApiLinks.doctorAppointmentSummary,
      '${ApiLinks.server}/Appointments/doctor/me/summary',
    );
    expect(
      ApiLinks.doctorPatientAppointments(12),
      '${ApiLinks.server}/Appointments/doctor/me/patients/12/appointments',
    );
    expect(ApiLinks.appointmentById(23), '${ApiLinks.server}/Appointments/23');
  });

  test('patient resource constants preserve backend controller names', () {
    expect(
      ApiLinks.medicalRecords,
      '${ApiLinks.server}/MedicalRecordContreoler/All',
    );
    expect(ApiLinks.prescriptions, '${ApiLinks.server}/PrescriptionControler');
    expect(ApiLinks.payments, '${ApiLinks.server}/Payment/All');
    expect(
      ApiLinks.createMedicalRecord,
      '${ApiLinks.server}/MedicalRecordContreoler',
    );
    expect(
      ApiLinks.createPrescription,
      '${ApiLinks.server}/PrescriptionControler/create',
    );
  });

  test('patient profile creation posts the backend DTO with auth', () async {
    final apiService = _RecordingApiService();

    final result = await CompleteProfileData(
      apiService,
    ).createPatient(bloodType: 'O+', personId: 31);

    expect(result.isRight, isTrue);
    expect(apiService.lastPostUrl, ApiLinks.createPatient);
    expect(apiService.lastPostAuth, isTrue);
    expect(apiService.lastPostBody, {'bloodType': 'O+', 'personId': 31});
  });
}

class _RecordingApiService extends ApiService {
  String? lastPostUrl;
  Map<String, dynamic>? lastPostBody;
  bool? lastPostAuth;

  @override
  Future<Either<Failure, dynamic>> post(
    String url,
    Map<String, dynamic> data, {
    bool auth = false,
  }) async {
    lastPostUrl = url;
    lastPostBody = data;
    lastPostAuth = auth;
    return const Right(null);
  }
}
