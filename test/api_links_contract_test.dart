import 'package:clinic_shifaa/core/Error/Failure.dart';
import 'package:clinic_shifaa/core/class/ApiService.dart';
import 'package:clinic_shifaa/core/constant/ApiLinks.dart';
import 'package:clinic_shifaa/data/datasource/remote/CompleteProfile/CompleteProfileData.dart';
import 'package:clinic_shifaa/data/datasource/remote/Home/HomeData.dart';
import 'package:clinic_shifaa/data/datasource/remote/images/imagesdta.dart';
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
    expect(ApiLinks.createPayment, '${ApiLinks.server}/Payment/create');
    expect(ApiLinks.doctors, '${ApiLinks.server}/Doctors');
    expect(ApiLinks.doctorById(9), '${ApiLinks.server}/Doctors/9');
    expect(
      ApiLinks.availableSlots(doctorId: 9, date: '2026-08-04'),
      '${ApiLinks.server}/Appointments/available-slots'
      '?doctorId=9&date=2026-08-04',
    );
    expect(ApiLinks.images, '${ApiLinks.server}/Images/GetImage/');
    expect(ApiLinks.personById(9), '${ApiLinks.server}/Person/9');
    expect(ApiLinks.patientById(13), '${ApiLinks.server}/Patient/13');
    expect(ApiLinks.uploadImage, '${ApiLinks.server}/Images/UploadImage');
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

  test(
    'patient profile updates use the exact person and patient DTOs',
    () async {
      final apiService = _RecordingApiService();
      final data = HomeData(apiService);

      final personResult = await data.updatePersonProfile(
        personId: 9,
        firstName: 'Mona',
        lastName: 'Ahmed',
        nationalityNo: '1234567890',
        phoneNumber: '+966511111111',
        age: 30,
        address: 'Jeddah',
        gender: 1,
        nationalityCountryId: 1,
        imagePath: 'mona.jpg',
        note: 'Updated biography',
      );
      final patientResult = await data.updatePatientProfile(
        patientId: 13,
        personId: 9,
        bloodType: 'O+',
      );

      expect(personResult.isRight, isTrue);
      expect(patientResult.isRight, isTrue);
      expect(apiService.putUrls, [
        '${ApiLinks.server}/Person/9',
        '${ApiLinks.server}/Patient/13',
      ]);
      expect(apiService.putAuthValues, everyElement(isTrue));
      expect(apiService.putBodies.first, {
        'id': 9,
        'firstName': 'Mona',
        'lastName': 'Ahmed',
        'nationalityNo': '1234567890',
        'phoneNumber': '+966511111111',
        'age': 30,
        'address': 'Jeddah',
        'gender': 1,
        'nationalityCountryId': 1,
        'imagePath': 'mona.jpg',
        'note': 'Updated biography',
      });
      expect(apiService.putBodies.last, {'bloodType': 'O+', 'personId': 9});
    },
  );

  test(
    'patient image uses the existing authenticated multipart upload',
    () async {
      final apiService = _RecordingApiService();

      final result = await ImagesData(
        apiService,
      ).uploadAuthenticatedImageName(r'C:\temp\patient.jpg');

      expect(result.isRight, isTrue);
      expect(apiService.lastUploadUrl, ApiLinks.uploadImage);
      expect(apiService.lastUploadPath, r'C:\temp\patient.jpg');
      expect(apiService.lastUploadAuth, isTrue);
      result.fold(
        (failure) => fail(failure.message),
        (imageName) => expect(imageName, 'uploaded-patient.jpg'),
      );
    },
  );
}

class _RecordingApiService extends ApiService {
  String? lastPostUrl;
  Map<String, dynamic>? lastPostBody;
  bool? lastPostAuth;
  final List<String> putUrls = [];
  final List<Map<String, dynamic>> putBodies = [];
  final List<bool> putAuthValues = [];
  String? lastUploadUrl;
  String? lastUploadPath;
  bool? lastUploadAuth;

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

  @override
  Future<Either<Failure, dynamic>> put(
    String url,
    Map<String, dynamic> data, {
    bool auth = false,
  }) async {
    putUrls.add(url);
    putBodies.add(data);
    putAuthValues.add(auth);
    return Right(data);
  }

  @override
  Future<Either<Failure, dynamic>> uploadImage(
    String url,
    String imagePath, {
    bool auth = false,
  }) async {
    lastUploadUrl = url;
    lastUploadPath = imagePath;
    lastUploadAuth = auth;
    return const Right({'imageName': 'uploaded-patient.jpg'});
  }
}
