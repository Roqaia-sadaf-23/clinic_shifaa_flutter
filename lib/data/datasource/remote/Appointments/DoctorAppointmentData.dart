import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../../../../core/Error/Failure.dart';
import '../../../../core/class/ApiService.dart';
import '../../../../core/constant/ApiLinks.dart';

class DoctorAppointmentData {
  DoctorAppointmentData(this._apiService);
  final ApiService _apiService;

  Future<Either<Failure, dynamic>> getDoctorSummary() async {
    if (kDebugMode) {
      debugPrint('SUMMARY URL: ${ApiLinks.doctorAppointmentSummary}');
    }
    final result = await _apiService.get(
      ApiLinks.doctorAppointmentSummary,
      auth: true,
    );
    if (kDebugMode) {
      result.fold(
        (failure) => debugPrint(
          'SUMMARY FAILURE: ${failure.statusCode} ${failure.message}',
        ),
        (data) {
          debugPrint('SUMMARY RESPONSE: $data');
          debugPrint('SUMMARY TYPE: ${data.runtimeType}');
        },
      );
    }
    return result;
  }

  Future<Either<Failure, dynamic>> getTodayDoctorAppointments() async {
    if (kDebugMode) {
      debugPrint('TODAY URL: ${ApiLinks.todayDoctorAppointments}');
    }
    final result = await _apiService.get(
      ApiLinks.todayDoctorAppointments,
      auth: true,
    );
    if (kDebugMode) {
      result.fold(
        (failure) => debugPrint(
          'TODAY FAILURE: ${failure.statusCode} ${failure.message}',
        ),
        (data) {
          debugPrint('TODAY RESPONSE: $data');
          debugPrint('TODAY TYPE: ${data.runtimeType}');
        },
      );
    }
    return result;
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
    if (kDebugMode) debugPrint('APPOINTMENTS URL: $uri');
    final result = await _apiService.get(uri.toString(), auth: true);
    if (kDebugMode) {
      result.fold(
        (failure) => debugPrint(
          'APPOINTMENTS FAILURE: ${failure.statusCode} ${failure.message}',
        ),
        (data) {
          debugPrint('APPOINTMENTS RESPONSE: $data');
          debugPrint('APPOINTMENTS TYPE: ${data.runtimeType}');
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
