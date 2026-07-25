import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../core/Error/Failure.dart';
import '../../core/class/ApiService.dart';
import '../../data/datasource/remote/Doctors/DactorData.dart';
import '../../data/datasource/remote/Appointments/DoctorAppointmentData.dart';
import '../../data/model/AppointmentModel.dart';
import '../../data/model/CurrentDoctorModel.dart';
import '../../data/model/DoctorAppointmentSummary.dart';

class DoctorHomeController extends GetxController {
  DoctorHomeController(this._doctorData, this._appointmentData);
  final DoctorData _doctorData;
  final DoctorAppointmentData _appointmentData;
  CurrentDoctorModel? doctor;
  DoctorAppointmentSummary? summary;
  List<AppointmentModel> todayAppointments = const [];
  Failure? failure;
  bool isLoading = false;
  bool isRefreshing = false;
  bool _requestInProgress = false;
  bool _disposed = false;
  int selectedTab = 0;

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
  }

  Future<void> loadCurrentDoctor() => loadDashboard();
  Future<void> loadDashboard() => _load(refreshing: false);
  Future<void> refreshCurrentDoctor() => refreshDashboard();
  Future<void> refreshDashboard() => _load(refreshing: true);
  void retry() {
    if (!_requestInProgress) loadCurrentDoctor();
  }

  void selectTab(int index) {
    if (index >= 0 && index <= 3) {
      selectedTab = index;
      update();
      return;
    }
    showComingSoon();
  }

  void handleAction(int index) {
    if (index == 0 || index == 1) {
      selectTab(1);
    } else {
      selectTab(2);
    }
  }

  void replaceDoctor(CurrentDoctorModel value) {
    doctor = value;
    failure = null;
    if (!_disposed) update();
  }

  void showComingSoon() {
    Get.snackbar(
      'comingSoon'.tr,
      'featureNotAvailable'.tr,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> _load({required bool refreshing}) async {
    if (_requestInProgress || _disposed) return;
    _requestInProgress = true;
    failure = null;
    if (refreshing) {
      isRefreshing = true;
    } else {
      isLoading = true;
    }
    update();
    try {
      final results = await Future.wait([
        _doctorData.getCurrentDoctor(),
        _appointmentData.getDoctorSummary(),
        _appointmentData.getTodayDoctorAppointments(),
      ]);
      if (_disposed) return;
      (results[0] as Either<Failure, CurrentDoctorModel>).fold(
        (value) {
          doctor = null;
          failure = value.statusCode == 404
              ? const ServerFailure(
                  'Doctor profile was not found.',
                  statusCode: 404,
                )
              : value;
        },
        (value) {
          doctor = value;
          failure = null;
        },
      );
      results[1].fold((value) => failure ??= value, (value) {
        try {
          if (kDebugMode) {
            debugPrint('Doctor summary raw response: $value');
            debugPrint('Doctor summary response type: ${value.runtimeType}');
          }
          summary = DoctorAppointmentSummary.fromResponse(value);
        } catch (_) {
          failure ??= const ServerFailure('Invalid appointment summary.');
        }
      });
      results[2].fold((value) => failure ??= value, (value) {
        try {
          if (value is! List) throw const FormatException();
          todayAppointments = value
              .map(
                (item) => AppointmentModel.fromJson(
                  Map<String, dynamic>.from(item as Map),
                ),
              )
              .toList(growable: false);
        } catch (_) {
          failure ??= const ServerFailure(
            'Invalid today appointments response.',
          );
        }
      });
    } finally {
      _requestInProgress = false;
      isLoading = false;
      isRefreshing = false;
      if (!_disposed) update();
    }
  }

  @override
  void onClose() {
    _disposed = true;
    super.onClose();
  }
}
