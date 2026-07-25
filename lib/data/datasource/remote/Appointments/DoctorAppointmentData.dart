import 'package:intl/intl.dart';

import '../../../../core/Error/Failure.dart';
import '../../../../core/class/ApiService.dart';
import '../../../../core/constant/ApiLinks.dart';

class DoctorAppointmentData {
  DoctorAppointmentData(this._apiService);
  final ApiService _apiService;

  Future<Either<Failure, dynamic>> getDoctorSummary() =>
      _apiService.get(ApiLinks.doctorAppointmentSummary, auth: true);

  Future<Either<Failure, dynamic>> getTodayDoctorAppointments() =>
      _apiService.get(ApiLinks.todayDoctorAppointments, auth: true);

  Future<Either<Failure, dynamic>> getDoctorAppointments({
    String? status,
    DateTime? date,
    int page = 1,
    int pageSize = 10,
  }) {
    final query = <String, String>{
      if (status != null && status.isNotEmpty) 'status': status,
      if (date != null) 'date': DateFormat('yyyy-MM-dd').format(date),
      'page': '$page',
      'pageSize': '$pageSize',
    };
    final uri = Uri.parse(
      ApiLinks.doctorAppointments,
    ).replace(queryParameters: query);
    return _apiService.get(uri.toString(), auth: true);
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
