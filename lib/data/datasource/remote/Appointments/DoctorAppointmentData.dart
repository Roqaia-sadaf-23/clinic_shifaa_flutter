import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../../../../core/Error/Failure.dart';
import '../../../../core/class/ApiService.dart';
import '../../../../core/constant/ApiLinks.dart';
import '../../../model/DoctorAppointmentModel.dart';

class DoctorAppointmentData {
  DoctorAppointmentData(this._apiService);
  final ApiService _apiService;

  Future<Either<Failure, dynamic>> getDoctorSummary() async {
    return _apiService.get(ApiLinks.doctorAppointmentSummary, auth: true);
  }

  Future<Either<Failure, dynamic>> getTodayDoctorAppointments() async {
    return _apiService.get(ApiLinks.todayDoctorAppointments, auth: true);
  }

  Future<Either<Failure, DoctorAppointmentsResponse>> getDoctorAppointments({
    String? status,
    DateTime? date,
    int page = 1,
    int pageSize = 10,
  }) async {
    final normalizedStatus = status?.trim();
    final query = <String, String>{
      if (normalizedStatus != null &&
          normalizedStatus.isNotEmpty &&
          normalizedStatus.toLowerCase() != 'all')
        'status': normalizedStatus,
      if (date != null) 'date': DateFormat('yyyy-MM-dd').format(date),
      'page': '$page',
      'pageSize': '$pageSize',
    };
    final uri = Uri.parse(
      ApiLinks.doctorAppointments,
    ).replace(queryParameters: query);
    if (kDebugMode) {
      debugPrint('DOCTOR APPOINTMENTS URL: $uri');
      debugPrint('DOCTOR APPOINTMENTS QUERY: $query');
    }
    final isProfileTotalRequest =
        status == null && date == null && page == 1 && pageSize == 10;
    if (kDebugMode && isProfileTotalRequest) {
      debugPrint('PROFILE APPOINTMENTS URL: $uri');
    }
    final rawResult = await _apiService.get(uri.toString(), auth: true);
    final result = rawResult.fold<Either<Failure, DoctorAppointmentsResponse>>(
      Left.new,
      (responseData) {
        try {
          if (responseData == null) {
            return Right(
              DoctorAppointmentsResponse.empty(page: page, pageSize: pageSize),
            );
          }
          if (responseData is Map) {
            return Right(
              DoctorAppointmentsResponse.fromJson(
                Map<String, dynamic>.from(responseData),
              ),
            );
          }
          if (responseData is List) {
            return Right(
              DoctorAppointmentsResponse.fromList(
                responseData,
                page: page,
                pageSize: pageSize,
              ),
            );
          }
          return const Left(
            ServerFailure('Invalid doctor appointments response.'),
          );
        } on FormatException catch (error) {
          return Left(ServerFailure(error.message));
        } catch (error) {
          return Left(
            ServerFailure('Invalid doctor appointments response: $error'),
          );
        }
      },
    );
    if (kDebugMode) {
      result.fold(
        (failure) =>
            debugPrint('DOCTOR APPOINTMENTS FAILURE: ${failure.message}'),
        (response) {
          debugPrint(
            'DOCTOR APPOINTMENTS PARSED ITEMS: ${response.items.length}',
          );
          debugPrint(
            'DOCTOR APPOINTMENTS PAGE: ${response.page}/${response.totalPages}',
          );
        },
      );
    }
    if (kDebugMode && isProfileTotalRequest) {
      result.fold(
        (failure) =>
            debugPrint('PROFILE APPOINTMENTS FAILURE: ${failure.message}'),
        (response) {
          debugPrint(
            'PROFILE APPOINTMENTS TOTAL COUNT: ${response.totalCount}',
          );
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
