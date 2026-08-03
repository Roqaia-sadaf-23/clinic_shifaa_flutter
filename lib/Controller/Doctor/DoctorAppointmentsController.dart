import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../core/Error/Failure.dart';
import '../../core/constant/Approutes.dart';
import '../../core/services/ClinicNotificationService.dart';
import '../../data/datasource/remote/Appointments/DoctorAppointmentData.dart';
import '../../data/model/DoctorAppointmentModel.dart';
import '../../data/model/DoctorPatientDetailsModels.dart';
import '../../data/model/ClinicNotification.dart';
import 'DoctorHome_Controller.dart';

class DoctorAppointmentsController extends GetxController {
  DoctorAppointmentsController(
    this._data, {
    ClinicNotificationService? notificationService,
  }) : _notificationService = notificationService;
  final DoctorAppointmentData _data;
  final ClinicNotificationService? _notificationService;

  static const statuses = ['Pending', 'Confirmed', 'Completed', 'Cancelled'];
  final appointments = <DoctorAppointmentModel>[];
  Failure? failure;
  String? selectedStatus;
  DateTime? selectedDate;
  bool isInitialLoading = false;
  bool isRefreshing = false;
  bool isLoadingMore = false;
  bool hasMore = true;
  bool hasLoaded = false;
  int currentPage = 1;
  int pageSize = 10;
  int totalCount = 0;
  int totalPages = 0;
  int? totalAppointments;
  Failure? appointmentsTotalFailure;
  bool isAppointmentsTotalLoading = false;
  bool _disposed = false;
  bool _reloadRequested = false;
  bool _isOpeningCreateMedicalRecord = false;
  int _filterRevision = 0;

  bool get isBusy => isInitialLoading || isRefreshing || isLoadingMore;
  bool get isOpeningCreateMedicalRecord => _isOpeningCreateMedicalRecord;
  bool get hasError => failure != null;
  String get errorMessage => failure?.message ?? 'Unable to load appointments.';
  bool get _inactive => _disposed || isClosed;

  @override
  void onInit() {
    super.onInit();
    loadInitial();
  }

  Future<void> loadInitial() => _load(reset: true);
  Future<void> refreshList() => _load(reset: true, refreshing: true);
  Future<void> retry() => loadInitial();

  Future<void> retryAppointmentsTotal() async {
    if (_inactive || isBusy || isAppointmentsTotalLoading) return;
    isAppointmentsTotalLoading = true;
    appointmentsTotalFailure = null;
    update();
    try {
      final result = await _data.getDoctorAppointments(
        page: 1,
        pageSize: pageSize,
      );
      if (_inactive) return;
      result.fold((value) => appointmentsTotalFailure = value, (response) {
        totalAppointments = response.totalCount;
        appointmentsTotalFailure = null;
      });
    } catch (_) {
      appointmentsTotalFailure = const ServerFailure(
        'Unable to load appointments total.',
      );
    } finally {
      isAppointmentsTotalLoading = false;
      if (!_inactive) update();
    }
  }

  Future<void> loadMore() async {
    if (_inactive || !hasMore || isBusy) return;
    await _load(reset: false);
  }

  bool canCreateMedicalRecord(DoctorAppointmentModel appointment) {
    return appointment.id > 0 &&
        appointment.patientId > 0 &&
        appointment.status.trim().toLowerCase() == 'completed' &&
        (appointment.medicalRecordId == null ||
            appointment.medicalRecordId! <= 0);
  }

  Future<void> openCreateMedicalRecord(
    DoctorAppointmentModel appointment,
  ) async {
    if (_inactive ||
        _isOpeningCreateMedicalRecord ||
        !canCreateMedicalRecord(appointment) ||
        Get.currentRoute == Approutes.createMedicalRecord) {
      return;
    }

    final formAppointment = DoctorPatientAppointmentDetailsModel(
      appointmentId: appointment.id,
      patientId: appointment.patientId,
      patientName: appointment.patientName,
      patientImage: appointment.patientImage,
      appointmentDate: appointment.appointmentDate,
      status: appointment.status,
      lastStatusDate: appointment.lastStatusDate,
      note: appointment.notes,
    );
    final arguments = MedicalRecordFormArguments(
      patientId: appointment.patientId,
      appointmentId: appointment.id,
      appointment: formAppointment,
    );

    _isOpeningCreateMedicalRecord = true;
    update();
    try {
      final result = await Get.toNamed(
        Approutes.createMedicalRecord,
        arguments: arguments,
      );
      if (_inactive || result is! CreatedMedicalRecordResult) return;

      await refreshList();
      if (_inactive) return;
      if (Get.isRegistered<DoctorHomeController>()) {
        await Get.find<DoctorHomeController>().refreshAppointments();
      }
    } finally {
      _isOpeningCreateMedicalRecord = false;
      if (!_inactive) update();
    }
  }

  Future<void> setStatus(String? value) async {
    final normalized = value?.trim();
    final nextStatus =
        normalized == null ||
            normalized.isEmpty ||
            normalized.toLowerCase() == 'all'
        ? null
        : normalized;
    if (selectedStatus == nextStatus) return;
    selectedStatus = nextStatus;
    _filterRevision++;
    await loadInitial();
  }

  Future<void> setDate(DateTime? value) async {
    if (_sameDate(selectedDate, value)) return;
    selectedDate = value;
    _filterRevision++;
    await loadInitial();
  }

  Future<void> clearFilters() async {
    if (selectedStatus == null && selectedDate == null) return;
    selectedStatus = null;
    selectedDate = null;
    _filterRevision++;
    await loadInitial();
  }

  Future<void> _load({required bool reset, bool refreshing = false}) async {
    if (_inactive) return;
    if (isBusy) {
      if (reset) _reloadRequested = true;
      return;
    }
    final loadsAppointmentsTotal =
        reset && selectedStatus == null && selectedDate == null;
    if (reset) {
      failure = null;
      if (loadsAppointmentsTotal) {
        appointmentsTotalFailure = null;
        isAppointmentsTotalLoading = true;
      }
      if (refreshing) {
        isRefreshing = true;
      } else {
        isInitialLoading = true;
      }
    } else {
      isLoadingMore = true;
    }
    update();
    final requestedPage = reset ? 1 : currentPage + 1;
    final requestRevision = _filterRevision;
    var shouldSyncNotifications = false;
    try {
      final result = await _data.getDoctorAppointments(
        status: selectedStatus,
        date: selectedDate,
        page: requestedPage,
        pageSize: pageSize,
      );
      if (_inactive || requestRevision != _filterRevision) return;
      result.fold(
        (value) {
          failure = value;
          if (loadsAppointmentsTotal) appointmentsTotalFailure = value;
          if (!reset) hasMore = false;
        },
        (response) {
          if (loadsAppointmentsTotal) {
            totalAppointments = response.totalCount;
            appointmentsTotalFailure = null;
          }
          if (reset) appointments.clear();
          appointments.addAll(response.items);
          currentPage = response.page;
          pageSize = response.pageSize;
          totalCount = response.totalCount;
          totalPages = response.totalPages;
          hasMore = totalPages > 0
              ? currentPage < totalPages
              : appointments.length < totalCount;
          hasLoaded = true;
          failure = null;
          shouldSyncNotifications =
              selectedStatus == null && selectedDate == null;
        },
      );
      if (shouldSyncNotifications) {
        await _notificationService?.syncDoctorAppointments(
          appointments.map(
            (appointment) => ClinicAppointmentNotificationSnapshot(
              id: appointment.id,
              personName: appointment.patientName,
              appointmentDate: appointment.appointmentDate,
              status: appointment.status,
              lastStatusDate: appointment.lastStatusDate,
            ),
          ),
          detectNew: reset,
        );
      }
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Doctor appointments error: $error');
        debugPrintStack(stackTrace: stackTrace);
      }
      if (requestRevision == _filterRevision) {
        failure = ServerFailure(error.toString());
        if (loadsAppointmentsTotal) {
          appointmentsTotalFailure = const ServerFailure(
            'Unable to load appointments total.',
          );
        }
        if (!reset) hasMore = false;
      }
    } finally {
      isInitialLoading = false;
      isRefreshing = false;
      isLoadingMore = false;
      if (loadsAppointmentsTotal) isAppointmentsTotalLoading = false;
      if (!_inactive) update();
      if (_reloadRequested && !_inactive) {
        _reloadRequested = false;
        await _load(reset: true);
      }
    }
  }

  bool _sameDate(DateTime? first, DateTime? second) {
    if (identical(first, second)) return true;
    if (first == null || second == null) return false;
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  @override
  void onClose() {
    _disposed = true;
    super.onClose();
  }
}
