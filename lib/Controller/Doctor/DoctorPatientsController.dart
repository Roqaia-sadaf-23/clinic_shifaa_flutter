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
  bool _requesting = false;
  bool _disposed = false;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load({bool refreshing = false}) async {
    if (_requesting || _disposed) return;
    _requesting = true;
    failure = null;
    refreshing ? isRefreshing = true : isLoading = true;
    update();
    try {
      final result = await _data.getDoctorPatients();
      if (_disposed) return;
      result.fold((value) => failure = value, (body) {
        try {
          if (body is! List) throw const FormatException();
          final unique = <int, DoctorPatientModel>{};
          for (final item in body) {
            final patient = DoctorPatientModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            );
            unique[patient.patientId] = patient;
          }
          patients = unique.values.toList(growable: false);
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
      if (!_disposed && !isClosed) update();
    }
  }

  Future<void> refreshPatients() => load(refreshing: true);

  @override
  void onClose() {
    _disposed = true;
    super.onClose();
  }
}
