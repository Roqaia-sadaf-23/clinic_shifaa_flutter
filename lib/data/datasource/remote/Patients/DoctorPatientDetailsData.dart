import '../../../../core/Error/Failure.dart';
import '../../../../core/class/ApiService.dart';
import '../../../../core/constant/ApiLinks.dart';
import '../../../model/DoctorPatientDetailsModels.dart';

class DoctorPatientDetailsData {
  DoctorPatientDetailsData(this._apiService);

  final ApiService _apiService;

  Future<Either<Failure, List<DoctorPatientAppointmentDetailsModel>>>
  getAppointments(int patientId) {
    return _getList(
      ApiLinks.doctorPatientAppointments(patientId),
      DoctorPatientAppointmentDetailsModel.fromJson,
      'appointments',
    );
  }

  Future<Either<Failure, List<DoctorPatientMedicalRecordModel>>>
  getMedicalRecords(int patientId) {
    return _getList(
      ApiLinks.doctorPatientMedicalRecords(patientId),
      DoctorPatientMedicalRecordModel.fromJson,
      'medical records',
    );
  }

  Future<Either<Failure, List<DoctorPatientPrescriptionModel>>>
  getPrescriptions(int patientId) {
    return _getList(
      ApiLinks.doctorPatientPrescriptions(patientId),
      DoctorPatientPrescriptionModel.fromJson,
      'prescriptions',
    );
  }

  Future<Either<Failure, List<DoctorPatientPaymentModel>>> getPayments(
    int patientId,
  ) {
    return _getList(
      ApiLinks.doctorPatientPayments(patientId),
      DoctorPatientPaymentModel.fromJson,
      'payments',
    );
  }

  Future<Either<Failure, List<T>>> _getList<T>(
    String url,
    T Function(Map<String, dynamic> json) fromJson,
    String sectionName,
  ) async {
    final result = await _apiService.get(url, auth: true);
    return result.fold<Either<Failure, List<T>>>(Left.new, (body) {
      try {
        final items = _responseItems(body);
        return Right(
          items
              .map((item) {
                if (item is! Map) {
                  throw FormatException('Invalid $sectionName response item.');
                }
                return fromJson(Map<String, dynamic>.from(item));
              })
              .toList(growable: false),
        );
      } on FormatException catch (error) {
        return Left(ServerFailure(error.message));
      } catch (_) {
        return Left(ServerFailure('Invalid $sectionName response.'));
      }
    });
  }

  List<Object?> _responseItems(Object? response) {
    if (response == null) return const [];

    Object? current = response;
    for (var depth = 0; depth < 6; depth++) {
      if (current is List) return List<Object?>.from(current);
      if (current is! Map) break;
      if (current.isEmpty) return const [];

      final nested = _firstMapValue(current, const [
        'items',
        'data',
        'result',
        'appointments',
        'medicalRecords',
        'prescriptions',
        'payments',
        r'$values',
      ]);
      if (nested == null) break;
      current = nested;
    }

    throw const FormatException('Response must contain a list.');
  }

  Object? _firstMapValue(Map<dynamic, dynamic> map, List<String> names) {
    for (final name in names) {
      for (final entry in map.entries) {
        final key = entry.key;
        if (key is String && key.toLowerCase() == name.toLowerCase()) {
          return entry.value;
        }
      }
    }
    return null;
  }
}
