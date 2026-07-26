import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../../../../core/Error/Failure.dart';
import '../../../../core/class/ApiService.dart';
import '../../../../core/constant/ApiLinks.dart';

class DoctorAppointmentData {
  DoctorAppointmentData(this._apiService);
  final ApiService _apiService;

  Future<Either<Failure, dynamic>> getDoctorSummary() async {
    return _apiService.get(ApiLinks.doctorAppointmentSummary, auth: true);
  }

  Future<Either<Failure, dynamic>> getTodayDoctorAppointments() async {
    return _apiService.get(ApiLinks.todayDoctorAppointments, auth: true);
  }

  Future<Either<Failure, dynamic>> getDoctorAppointments({
    String? status,
    DateTime? date,
    int page = 1,
    int pageSize = 10,
  }) async {
    final query = <String, String>{
      if (status != null && status.isNotEmpty) 'status': status,
      if (date != null) 'date': DateFormat('yyyy-MM-dd').format(date),
      'page': '$page',
      'pageSize': '$pageSize',
    };
    final uri = Uri.parse(
      ApiLinks.doctorAppointments,
    ).replace(queryParameters: query);
    if (kDebugMode) {
      debugPrint('DOCTOR APPOINTMENTS URL: $uri');
    }
    final isProfileTotalRequest =
        status == null && date == null && page == 1 && pageSize == 10;
    if (kDebugMode && isProfileTotalRequest) {
      debugPrint('PROFILE APPOINTMENTS URL: $uri');
    }
    final result = await _apiService.get(uri.toString(), auth: true);
    if (kDebugMode) {
      result.fold(
        (failure) =>
            debugPrint('DOCTOR APPOINTMENTS FAILURE: ${failure.message}'),
        (data) {
          debugPrint('DOCTOR APPOINTMENTS RESPONSE: $data');
          debugPrint('DOCTOR APPOINTMENTS TYPE: ${data.runtimeType}');
        },
      );
    }
    if (kDebugMode && isProfileTotalRequest) {
      result.fold(
        (failure) =>
            debugPrint('PROFILE APPOINTMENTS FAILURE: ${failure.message}'),
        (data) {
          debugPrint('PROFILE APPOINTMENTS RAW RESPONSE: $data');
          debugPrint('PROFILE APPOINTMENTS RESPONSE TYPE: ${data.runtimeType}');
        },
      );
    }
    return result;
  }

  Future<Either<Failure, dynamic>> getDoctorPatients() =>
      _apiService.get(ApiLinks.doctorPatients, auth: true);

  Future<Either<Failure, dynamic>> getAppointmentById(int id) =>
      _apiService.get(ApiLinks.appointmentById(id), auth: true);

  Future<Either<Failure, dynamic>> cancelAppointment(int id) =>
      _apiService.put(ApiLinks.cancelAppointment(id), const {}, auth: true);

  Future<Either<Failure, dynamic>> completeAppointment(int id) =>
      _apiService.put(ApiLinks.completeAppointment(id), const {}, auth: true);
}
