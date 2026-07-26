import 'package:get/get.dart';

import '../../core/Error/Failure.dart';
import '../../data/datasource/remote/Appointments/DoctorAppointmentData.dart';
import '../../data/model/DoctorPatientModel.dart';

class DoctorPatientsController extends GetxController {
  DoctorPatientsController(this._data);
  final DoctorAppointmentData _data;
  List<DoctorPatientModel> patients = const [];
  Failure? failure;
  bool isLoading = false;
  bool isRefreshing = false;
  bool hasLoaded = false;
  bool _requesting = false;
  bool _disposed = false;

  bool get _inactive => _disposed || isClosed;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load({bool refreshing = false}) async {
    if (_requesting || _inactive) return;
    _requesting = true;
    failure = null;
    if (refreshing) {
      isRefreshing = true;
    } else {
      isLoading = true;
    }
    update();
    try {
      final result = await _data.getDoctorPatients();
      if (_inactive) return;
      result.fold((value) => failure = value, (body) {
        try {
          final unique = <int, DoctorPatientModel>{};
          for (final item in _responseList(body)) {
            final patient = DoctorPatientModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            );
            unique[patient.patientId] = patient;
          }
          patients = unique.values.toList(growable: false);
          hasLoaded = true;
          failure = null;
        } catch (_) {
          failure = const ServerFailure('Invalid patients response.');
        }
      });
    } catch (_) {
      failure = const ServerFailure('Unable to load patients.');
    } finally {
      _requesting = false;
      isLoading = false;
      isRefreshing = false;
      if (!_inactive) update();
    }
  }

  Future<void> refreshPatients() => load(refreshing: true);

  int get uniquePatientsCount =>
      patients.map((patient) => patient.patientId).toSet().length;

  List<dynamic> _responseList(Object? response) {
    if (response is List) return response;
    if (response is Map) {
      final nested = response['data'] ?? response['result'];
      if (nested is List) return nested;
      if (nested is Map && nested['items'] is List) {
        return nested['items'] as List;
      }
      if (response['items'] is List) return response['items'] as List;
    }
    throw const FormatException();
  }

  @override
  void onClose() {
    _disposed = true;
    super.onClose();
  }
}
