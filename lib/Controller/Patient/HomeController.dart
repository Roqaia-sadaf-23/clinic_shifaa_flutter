import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/Error/Failure.dart';
import '../../core/constant/Approutes.dart';
import '../../data/datasource/remote/Home/HomeData.dart';
import '../../data/datasource/remote/Appointments/DoctorAppointmentData.dart';
import '../../data/model/AppointmentModel.dart';
import '../../data/model/DoctorModel.dart';
import '../../data/model/PatientHomeProfileModel.dart';

class PatientHomeControllerImp extends GetxController {
  PatientHomeControllerImp(
    this._homeData, {
    DoctorAppointmentData? appointmentData,
    this.autoLoad = true,
  }) : _appointmentData = appointmentData;

  final HomeData _homeData;
  final DoctorAppointmentData? _appointmentData;
  final bool autoLoad;
  final TextEditingController searchController = TextEditingController();

  PatientHomeProfileModel? patient;
  List<DoctorDetailsModel> doctors = const [];
  List<AppointmentModel> appointments = const [];
  Failure? profileFailure;
  Failure? doctorsFailure;
  Failure? appointmentsFailure;
  Failure? appointmentActionFailure;
  bool isLoading = false;
  bool isRefreshing = false;
  bool _loading = false;
  bool _disposed = false;
  int selectedTab = 0;
  String searchQuery = '';

  final Map<PatientResourceType, List<Map<String, dynamic>>> resourceItems = {};
  final Map<PatientResourceType, Failure> resourceFailures = {};
  final Set<PatientResourceType> loadingResources = {};
  final Set<int> cancellingAppointments = {};
  final Set<int> _paymentEligibleAppointmentIds = {};
  final Set<int> _submittedPaymentAppointmentIds = {};

  static const List<String> supportedPaymentMethods = ['Cash', 'Card'];
  AppointmentModel? paymentAppointment;
  Failure? paymentFailure;
  String selectedPaymentMethod = '';
  bool isPaying = false;
  bool paymentSubmitted = false;
  int? createdPaymentId;
  double? paidAmount;
  String? paidPaymentMethod;

  bool get _inactive => _disposed || isClosed;
  bool get hasDashboardData =>
      patient != null || doctors.isNotEmpty || appointments.isNotEmpty;

  List<DoctorDetailsModel> get filteredDoctors {
    final query = searchQuery.trim().toLowerCase();
    if (query.isEmpty) return doctors;
    return doctors
        .where(
          (doctor) =>
              doctor.fullName.toLowerCase().contains(query) ||
              doctor.specialization.toLowerCase().contains(query),
        )
        .toList(growable: false);
  }

  AppointmentModel? get upcomingAppointment {
    final now = DateTime.now();
    final eligible =
        appointments.where((appointment) {
          final status = appointment.status.trim().toLowerCase();
          final active =
              status != 'completed' &&
              status != 'cancelled' &&
              status != 'canceled';
          return active && !appointment.appointmentDate.isBefore(now);
        }).toList()..sort(
          (first, second) =>
              first.appointmentDate.compareTo(second.appointmentDate),
        );
    return eligible.isEmpty ? null : eligible.first;
  }

  int get unreadNotificationsCount => 0;

  @override
  void onInit() {
    super.onInit();
    final arguments = Get.arguments;
    if (arguments is Map) {
      final initialTab = arguments['patientTab'];
      if (initialTab is int && initialTab >= 0 && initialTab <= 3) {
        selectedTab = initialTab;
      }
    }
    if (autoLoad) loadDashboard();
  }

  Future<void> loadDashboard() => _load(refreshing: false);
  Future<void> refreshDashboard() => _load(refreshing: true);

  Future<void> _load({required bool refreshing}) async {
    if (_loading || _inactive) return;
    _loading = true;
    if (refreshing) {
      isRefreshing = true;
    } else {
      isLoading = true;
    }
    profileFailure = null;
    doctorsFailure = null;
    appointmentsFailure = null;
    update();

    try {
      final role = (await _homeData.getAuthenticatedRole())
          ?.trim()
          .toLowerCase();
      if (role == 'doctor') {
        Get.offAllNamed(Approutes.doctorHome);
        return;
      }
      final userId = await _homeData.getAuthenticatedUserId();
      final email = await _homeData.getAuthenticatedEmail();
      if (_inactive) return;
      if (userId == null || userId <= 0) {
        const failure = ServerFailure(
          'Unable to identify the authenticated patient.',
          statusCode: 401,
        );
        profileFailure = failure;
        appointmentsFailure = failure;
        await _loadDoctors();
        return;
      }

      await Future.wait([
        _loadProfile(userId, email),
        _loadDoctors(),
        _loadAppointments(),
      ]);
    } finally {
      _loading = false;
      isLoading = false;
      isRefreshing = false;
      if (!_inactive) update();
    }
  }

  Future<void> _loadProfile(int userId, String? email) async {
    final result = await _homeData.getPatientProfile(
      userId: userId,
      email: email,
    );
    if (_inactive) return;
    result.fold((failure) => profileFailure = failure, (value) {
      patient = value;
      profileFailure = null;
    });
  }

  Future<void> _loadDoctors() async {
    final result = await _homeData.getDoctors();
    if (_inactive) return;
    result.fold((failure) => doctorsFailure = failure, (value) {
      doctors = value;
      doctorsFailure = null;
    });
  }

  Future<void> _loadAppointments() async {
    final result = await _homeData.getPatientAppointments();
    if (_inactive) return;
    result.fold((failure) => appointmentsFailure = failure, (value) {
      appointments = value;
      appointmentsFailure = null;
    });
  }

  Future<void> refreshAppointments() async {
    if (_inactive) return;
    appointmentsFailure = null;
    update();
    await _loadAppointments();
    if (!_inactive) update();
  }

  bool canCancelAppointment(AppointmentModel appointment) {
    final status = appointment.status.trim().toLowerCase();
    return appointment.id > 0 && (status == 'pending' || status == 'confirmed');
  }

  Future<bool> cancelAppointment(AppointmentModel appointment) async {
    final data = _appointmentData;
    if (data == null ||
        !canCancelAppointment(appointment) ||
        cancellingAppointments.contains(appointment.id)) {
      return false;
    }

    cancellingAppointments.add(appointment.id);
    appointmentActionFailure = null;
    update();
    final result = await data.cancelAppointment(appointment.id);
    if (_inactive) return false;
    var succeeded = false;
    result.fold((failure) => appointmentActionFailure = failure, (_) {
      succeeded = true;
      appointmentActionFailure = null;
    });
    cancellingAppointments.remove(appointment.id);
    if (succeeded) await refreshAppointments();
    if (!_inactive) update();
    return succeeded;
  }

  void registerCreatedAppointment(int appointmentId) {
    if (_inactive || appointmentId <= 0) return;
    _paymentEligibleAppointmentIds.add(appointmentId);
  }

  bool preparePayment(AppointmentModel appointment) {
    if (_inactive || appointment.id <= 0 || !canCreatePayment(appointment)) {
      return false;
    }
    paymentAppointment = appointment;
    paymentFailure = null;
    selectedPaymentMethod = '';
    isPaying = false;
    paymentSubmitted = false;
    createdPaymentId = null;
    paidAmount = null;
    paidPaymentMethod = null;
    update();
    return true;
  }

  bool get hasPreparedPayment {
    final appointment = paymentAppointment;
    return appointment != null && canCreatePayment(appointment);
  }

  bool canCreatePayment(AppointmentModel appointment) {
    final status = appointment.status.trim().toLowerCase();
    return appointment.id > 0 &&
        _paymentEligibleAppointmentIds.contains(appointment.id) &&
        status != 'cancelled' &&
        status != 'canceled' &&
        !_submittedPaymentAppointmentIds.contains(appointment.id);
  }

  void selectPaymentMethod(String method) {
    if (_inactive ||
        isPaying ||
        !supportedPaymentMethods.contains(method) ||
        selectedPaymentMethod == method) {
      return;
    }
    selectedPaymentMethod = method;
    paymentFailure = null;
    update();
  }

  Future<int?> submitPayment({required double amount, String note = ''}) async {
    final appointment = paymentAppointment;
    final paymentMethod = selectedPaymentMethod;
    if (appointment == null) return null;
    final appointmentId = appointment.id;
    if (!canCreatePayment(appointment) ||
        isPaying ||
        !supportedPaymentMethods.contains(paymentMethod) ||
        !amount.isFinite ||
        amount <= 0) {
      return null;
    }

    isPaying = true;
    paymentFailure = null;
    update();
    final result = await _homeData.createPayment(
      appointmentId: appointmentId,
      paymentMethod: paymentMethod,
      amount: amount,
      note: note.trim(),
    );
    if (_inactive) return null;
    int? paymentId;
    result.fold((failure) => paymentFailure = failure, (value) {
      paymentId = value;
      createdPaymentId = value;
      paidAmount = amount;
      paidPaymentMethod = paymentMethod;
      paymentSubmitted = true;
      paymentFailure = null;
      _paymentEligibleAppointmentIds.remove(appointmentId);
      _submittedPaymentAppointmentIds.add(appointmentId);
    });
    isPaying = false;
    update();
    if (paymentId != null) await refreshAppointments();
    return paymentId;
  }

  void selectTab(int index) {
    if (_inactive || index < 0 || index > 3 || index == selectedTab) {
      return;
    }

    selectedTab = index;
    update();
  }

  void showHome() => selectTab(0);
  void findDoctor() => selectTab(1);
  void showAppointments() => selectTab(2);
  void showProfile() => selectTab(3);

  void showNotifications() {
    Get.toNamed(Approutes.Notvications);
  }

  void updateSearch(String value) {
    if (searchQuery == value) return;
    searchQuery = value;
    update();
  }

  void submitSearch(String value) {
    updateSearch(value);
    selectTab(1);
  }

  void clearSearch() {
    searchController.clear();
    updateSearch('');
  }

  Future<void> openResource(PatientResourceType type) async {
    await loadResource(type);
    if (_inactive) return;
    await Get.toNamed(Approutes.patientResource, arguments: type.name);
  }

  Future<void> loadResource(
    PatientResourceType type, {
    bool force = false,
  }) async {
    if (_inactive || loadingResources.contains(type)) return;
    if (!force && resourceItems.containsKey(type)) return;
    loadingResources.add(type);
    resourceFailures.remove(type);
    update();
    final result = await _homeData.getPatientResource(
      type,
      patientId: patient?.patientId,
    );
    if (_inactive) return;
    result.fold((failure) => resourceFailures[type] = failure, (items) {
      resourceItems[type] = items;
      resourceFailures.remove(type);
    });
    loadingResources.remove(type);
    update();
  }

  PatientResourceType? resourceFromArguments(Object? value) {
    final name = value?.toString();
    for (final type in PatientResourceType.values) {
      if (type.name == name) return type;
    }
    return null;
  }

  @override
  void onClose() {
    _disposed = true;
    searchController.dispose();
    super.onClose();
  }
}
