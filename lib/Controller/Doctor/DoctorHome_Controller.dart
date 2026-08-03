import 'package:get/get.dart';

import '../../core/Error/Failure.dart';
import '../../core/constant/Approutes.dart';
import '../../core/services/ClinicNotificationService.dart';
import '../../data/datasource/remote/Doctors/DactorData.dart';
import '../../data/datasource/remote/Appointments/DoctorAppointmentData.dart';
import '../../data/model/AppointmentModel.dart';
import '../../data/model/CurrentDoctorModel.dart';
import '../../data/model/DoctorAppointmentSummary.dart';

class DoctorHomeController extends GetxController {
  DoctorHomeController(
    this._doctorData,
    this._appointmentData, {
    ClinicNotificationService? notificationService,
  }) : _notificationService = notificationService;
  final DoctorData _doctorData;
  final DoctorAppointmentData _appointmentData;
  final ClinicNotificationService? _notificationService;
  CurrentDoctorModel? doctor;
  DoctorAppointmentSummary? summary;
  List<AppointmentModel> todayAppointments = const [];
  Failure? failure;
  Failure? summaryFailure;
  Failure? todayAppointmentsFailure;
  bool isLoading = false;
  bool isRefreshing = false;
  bool _requestInProgress = false;
  bool _appointmentReloadRequested = false;
  bool _disposed = false;
  int selectedTab = 0;

  Failure? get appointmentsFailure =>
      summaryFailure ?? todayAppointmentsFailure;
  bool get _inactive => _disposed || isClosed;
  int get unreadNotificationsCount => _notificationService?.unreadCount ?? 0;

  @override
  void onInit() {
    super.onInit();
    _notificationService?.addListener(_notificationsChanged);
    _notificationService?.loadForCurrentUser(role: 'doctor');
    loadDashboard();
  }

  Future<void> loadCurrentDoctor() => loadDashboard();
  Future<void> loadDashboard() => _load(refreshing: false, includeDoctor: true);
  Future<void> refreshCurrentDoctor() => refreshDashboard();
  Future<void> refreshDashboard() =>
      _load(refreshing: true, includeDoctor: true);
  Future<void> refreshAppointments() =>
      _load(refreshing: true, includeDoctor: false);

  void retry() {
    if (!_requestInProgress && !_inactive) loadCurrentDoctor();
  }

  void selectTab(int index) {
    if (_inactive || index == selectedTab) return;
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
    if (_inactive) return;
    doctor = value;
    failure = null;
    update();
  }

  void showComingSoon() {
    if (_inactive) return;
    Get.snackbar(
      'comingSoon'.tr,
      'featureNotAvailable'.tr,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void showNotifications() {
    Get.toNamed<void>(Approutes.Notvications);
  }

  Future<void> _load({
    required bool refreshing,
    required bool includeDoctor,
  }) async {
    if (_inactive) return;
    if (_requestInProgress) {
      if (!includeDoctor) _appointmentReloadRequested = true;
      return;
    }
    _requestInProgress = true;
    if (includeDoctor) failure = null;
    summaryFailure = null;
    todayAppointmentsFailure = null;
    if (refreshing) {
      isRefreshing = true;
    } else {
      isLoading = true;
    }
    update();
    try {
      if (includeDoctor) {
        await _loadDoctor();
        if (_inactive) return;
      }
      await _loadSummary();
      if (_inactive) return;
      await _loadTodayAppointments();
    } finally {
      _requestInProgress = false;
      isLoading = false;
      isRefreshing = false;
      if (!_inactive) update();
      if (_appointmentReloadRequested && !_inactive) {
        _appointmentReloadRequested = false;
        await _load(refreshing: true, includeDoctor: false);
      }
    }
  }

  Future<void> _loadDoctor() async {
    try {
      final result = await _doctorData.getCurrentDoctor();
      if (_inactive) return;
      result.fold(
        (value) {
          if (doctor == null) {
            failure = value.statusCode == 404
                ? const ServerFailure(
                    'Doctor profile was not found.',
                    statusCode: 404,
                  )
                : value;
          }
        },
        (value) {
          doctor = value;
          failure = null;
        },
      );
    } catch (_) {
      if (doctor == null) {
        failure = const ServerFailure('Unable to load the Doctor dashboard.');
      }
    }
  }

  Future<void> _loadSummary() async {
    try {
      final result = await _appointmentData.getDoctorSummary();
      if (_inactive) return;
      result.fold((value) => summaryFailure = value, (value) {
        try {
          summary = DoctorAppointmentSummary.fromResponse(value);
          summaryFailure = null;
        } catch (_) {
          summaryFailure = const ServerFailure('Invalid appointment summary.');
        }
      });
    } catch (_) {
      summaryFailure = const ServerFailure(
        'Unable to load appointment summary.',
      );
    }
  }

  Future<void> _loadTodayAppointments() async {
    try {
      final result = await _appointmentData.getTodayDoctorAppointments();
      if (_inactive) return;
      result.fold((value) => todayAppointmentsFailure = value, (value) {
        try {
          todayAppointments = AppointmentModel.listFromResponse(value);
          todayAppointmentsFailure = null;
        } catch (_) {
          todayAppointmentsFailure = const ServerFailure(
            'Invalid today appointments response.',
          );
        }
      });
    } catch (_) {
      todayAppointmentsFailure = const ServerFailure(
        'Unable to load today appointments.',
      );
    }
  }

  @override
  void onClose() {
    _disposed = true;
    _notificationService?.removeListener(_notificationsChanged);
    super.onClose();
  }

  void _notificationsChanged() {
    if (!_inactive) update();
  }
}
