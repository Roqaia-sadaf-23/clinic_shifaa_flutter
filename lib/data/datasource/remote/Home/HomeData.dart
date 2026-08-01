import 'dart:convert';

import '../../../../core/Error/Failure.dart';
import '../../../../core/class/ApiService.dart';
import '../../../../core/class/AuthService.dart';
import '../../../../core/constant/ApiLinks.dart';
import '../../../model/AppointmentModel.dart';
import '../../../model/AvailableSlotModel.dart';
import '../../../model/DoctorModel.dart';
import '../../../model/PatientHomeProfileModel.dart';

enum PatientResourceType { medicalRecords, prescriptions, payments }

class HomeData {
  HomeData(this._apiService);

  final ApiService _apiService;

  Future<int?> getAuthenticatedUserId() async {
    final token = await AuthService.getAccessToken();
    final segments = token?.split('.') ?? const <String>[];
    if (segments.length < 2) return null;
    try {
      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(segments[1])),
      );
      final decoded = jsonDecode(payload);
      if (decoded is! Map) return null;
      return _firstInt(decoded, const [
        'userId',
        'userid',
        'nameid',
        'sub',
        'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier',
      ]);
    } catch (_) {
      return null;
    }
  }

  Future<String?> getAuthenticatedEmail() => AuthService.getEmail();
  Future<String?> getAuthenticatedRole() => AuthService.getRoleName();

  Future<Either<Failure, PatientHomeProfileModel>> getPatientProfile({
    required int userId,
    String? email,
  }) async {
    Failure? userFailure;
    PatientHomeProfileModel? userProfile;
    final userResult = await _apiService.get(
      ApiLinks.userById(userId),
      auth: true,
    );
    userResult.fold((failure) => userFailure = failure, (response) {
      final map = _responseMap(response);
      if (map != null) {
        userProfile = PatientHomeProfileModel.fromJson(
          map,
          fallbackUserId: userId,
        );
      }
    });

    Failure? patientFailure;
    PatientHomeProfileModel? patientProfile;
    final patientResult = await _apiService.get(ApiLinks.patients, auth: true);
    patientResult.fold((failure) => patientFailure = failure, (response) {
      final candidates = _responseMaps(response);
      for (final candidate in candidates) {
        final candidateUserId = _firstInt(candidate, const ['userId']);
        final candidatePersonId = _firstInt(candidate, const ['personId']);
        final candidateEmail = _firstText(candidate, const ['email']);
        final matches =
            candidateUserId == userId ||
            (userProfile != null &&
                userProfile!.personId > 0 &&
                candidatePersonId == userProfile!.personId) ||
            (email?.trim().isNotEmpty == true &&
                candidateEmail?.toLowerCase() == email!.trim().toLowerCase());
        if (!matches) continue;
        final patientJson = Map<String, dynamic>.from(candidate);
        patientJson.putIfAbsent(
          'patientId',
          () => _value(candidate, const ['id']),
        );
        patientProfile = PatientHomeProfileModel.fromJson(
          patientJson,
          fallbackUserId: userId,
        );
        break;
      }
    });

    if (userProfile != null && patientProfile != null) {
      return Right(userProfile!.merge(patientProfile!));
    }
    if (patientProfile != null) return Right(patientProfile!);
    if (userProfile != null) return Right(userProfile!);
    return Left(
      patientFailure ??
          userFailure ??
          const ServerFailure(
            'The authenticated patient profile was not found.',
            statusCode: 404,
          ),
    );
  }

  Future<Either<Failure, List<DoctorDetailsModel>>> getDoctors() async {
    final result = await _apiService.get(ApiLinks.doctors, auth: true);
    return result.fold(Left.new, (response) {
      try {
        return Right(DoctorDetailsModel.listFromResponse(response));
      } catch (_) {
        return const Left(ServerFailure('Invalid doctors response.'));
      }
    });
  }

  Future<Either<Failure, List<AppointmentModel>>>
  getPatientAppointments() async {
    final result = await _apiService.get(
      ApiLinks.patientAppointments,
      auth: true,
    );
    return result.fold(Left.new, (response) {
      try {
        return Right(AppointmentModel.listFromResponse(response));
      } catch (_) {
        return const Left(ServerFailure('Invalid appointments response.'));
      }
    });
  }

  Future<Either<Failure, List<AvailableSlotModel>>> getAvailableSlots({
    required int doctorId,
    required DateTime date,
  }) async {
    final dateValue =
        '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
    final result = await _apiService.get(
      ApiLinks.availableSlots(doctorId: doctorId, date: dateValue),
      auth: true,
    );
    return result.fold(Left.new, (response) {
      try {
        return Right(AvailableSlotModel.listFromResponse(response));
      } catch (_) {
        return const Left(ServerFailure('Invalid available slots response.'));
      }
    });
  }

  Future<Either<Failure, int>> createAppointment({
    required int doctorId,
    required DateTime appointmentDate,
  }) async {
    final result = await _apiService.post(ApiLinks.createAppointment, {
      'doctorId': doctorId,
      'appointmentDate': appointmentDate.toIso8601String(),
    }, auth: true);
    return result.fold(Left.new, (response) {
      if (response is int && response > 0) return Right(response);
      if (response is Map) {
        final map = Map<String, dynamic>.from(response);
        final isSuccess = _value(map, const ['isSuccess']);
        if (isSuccess == false) {
          return Left(ServerFailure(_resultError(map)));
        }
        final value = _value(map, const ['value', 'result', 'data']);
        final appointmentId = value is Map
            ? _firstInt(value, const ['id', 'appointmentId'])
            : int.tryParse(value?.toString().trim() ?? '');
        if (appointmentId != null && appointmentId > 0) {
          return Right(appointmentId);
        }
      }
      return const Left(ServerFailure('Invalid create appointment response.'));
    });
  }

  Future<Either<Failure, List<Map<String, dynamic>>>> getPatientResource(
    PatientResourceType type, {
    int? patientId,
  }) async {
    if (type == PatientResourceType.payments) {
      return const Left(
        ServerFailure(
          'Patient payment information is not available from the API.',
          statusCode: 501,
        ),
      );
    }
    final url = switch (type) {
      PatientResourceType.medicalRecords => ApiLinks.medicalRecords,
      PatientResourceType.prescriptions => ApiLinks.prescriptions,
      PatientResourceType.payments => throw StateError('Unreachable'),
    };
    final result = await _apiService.get(url, auth: true);
    return result.fold(Left.new, (response) {
      try {
        final items = _responseMaps(response);
        if (patientId == null || patientId <= 0) return Right(items);
        return Right(
          items
              .where((item) {
                final itemPatientId = _firstInt(item, const ['patientId']);
                return itemPatientId == null || itemPatientId == patientId;
              })
              .toList(growable: false),
        );
      } catch (_) {
        return const Left(ServerFailure('Invalid resource response.'));
      }
    });
  }

  static Map<String, dynamic>? _responseMap(Object? response) {
    var current = response;
    for (var depth = 0; depth < 5; depth++) {
      if (current is Map) {
        final map = Map<String, dynamic>.from(current);
        final nested = _value(map, const ['data', 'result', 'user', 'patient']);
        if (nested is Map) {
          current = nested;
          continue;
        }
        return map;
      }
      break;
    }
    return null;
  }

  static List<Map<String, dynamic>> _responseMaps(Object? response) {
    var current = response;
    for (var depth = 0; depth < 5; depth++) {
      if (current is List) {
        return current
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList(growable: false);
      }
      if (current is! Map) break;
      final map = Map<String, dynamic>.from(current);
      final nested = _value(map, const [
        'data',
        'result',
        'items',
        'value',
        r'$values',
        'patients',
        'records',
        'prescriptions',
        'payments',
      ]);
      if (nested == null) {
        return [map];
      }
      current = nested;
    }
    if (response == null) return const [];
    throw const FormatException('Response must contain a list.');
  }

  static Object? _value(Map<dynamic, dynamic> map, List<String> names) {
    for (final entry in map.entries) {
      final key = entry.key;
      if (key is String &&
          names.any((name) => key.toLowerCase() == name.toLowerCase())) {
        return entry.value;
      }
    }
    return null;
  }

  static int? _firstInt(Map<dynamic, dynamic> map, List<String> names) {
    final value = _value(map, names);
    if (value is int) return value;
    if (value is num && value.isFinite) return value.toInt();
    return int.tryParse(value?.toString().trim() ?? '');
  }

  static String? _firstText(Map<dynamic, dynamic> map, List<String> names) {
    final value = _value(map, names)?.toString().trim();
    return value == null || value.isEmpty ? null : value;
  }

  static String _resultError(Map<String, dynamic> map) {
    final errors = _value(map, const ['errors']);
    if (errors is Iterable) {
      for (final error in errors) {
        if (error is Map) {
          final description = _firstText(error, const [
            'description',
            'message',
          ]);
          if (description != null) return description;
        }
        final text = error?.toString().trim() ?? '';
        if (text.isNotEmpty) return text;
      }
    }
    return _firstText(map, const ['message', 'error']) ??
        'Unable to create the appointment.';
  }
}
