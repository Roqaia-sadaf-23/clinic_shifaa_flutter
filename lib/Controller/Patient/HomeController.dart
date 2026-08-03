import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/Error/Failure.dart';
import '../../core/constant/Approutes.dart';
import '../../core/services/ClinicNotificationService.dart';
import '../../data/datasource/remote/Home/HomeData.dart';
import '../../data/datasource/remote/Appointments/DoctorAppointmentData.dart';
import '../../data/model/AppointmentModel.dart';
import '../../data/model/DoctorModel.dart';
import '../../data/model/PatientHomeProfileModel.dart';
import '../../data/model/ClinicNotification.dart';
import '../../data/datasource/remote/images/imagesdta.dart';

enum PatientAppointmentFilter { all, upcoming, completed, cancelled }

class PatientHomeControllerImp extends GetxController {
  PatientHomeControllerImp(
    this._homeData, {
    DoctorAppointmentData? appointmentData,
    ImagesData? imageData,
    ClinicNotificationService? notificationService,
    this.autoLoad = true,
  }) : _appointmentData = appointmentData,
       _imageData = imageData,
       _notificationService = notificationService;

  final HomeData _homeData;
  final DoctorAppointmentData? _appointmentData;
  final ImagesData? _imageData;
  final ClinicNotificationService? _notificationService;
  final bool autoLoad;
  final TextEditingController searchController = TextEditingController();
  final patientEditFormKey = GlobalKey<FormState>();
  final patientFirstNameController = TextEditingController();
  final patientLastNameController = TextEditingController();
  final patientPhoneController = TextEditingController();
  final patientAddressController = TextEditingController();
  final patientNoteController = TextEditingController();
  final patientAgeController = TextEditingController();

  PatientHomeProfileModel? patient;
  List<DoctorDetailsModel> doctors = const [];
  List<AppointmentModel> appointments = const [];
  Failure? profileFailure;
  Failure? doctorsFailure;
  Failure? appointmentsFailure;
  Failure? appointmentActionFailure;
  bool isLoading = false;
  bool isLoadingProfile = false;
  bool isLoadingDoctors = false;
  bool isLoadingAppointments = false;
  bool isRefreshing = false;
  bool _loading = false;
  bool _disposed = false;
  int selectedTab = 0;
  PatientAppointmentFilter selectedAppointmentFilter =
      PatientAppointmentFilter.all;
  String searchQuery = '';
  String? selectedPatientBloodType;
  int selectedPatientGender = 0;
  String? selectedPatientImagePath;
  String? _uploadedPatientImageName;
  Failure? profileEditFailure;
  bool isSavingPatientProfile = false;
  bool isPickingPatientImage = false;

  final Map<PatientResourceType, List<Map<String, dynamic>>> resourceItems = {};
  final Map<PatientResourceType, Failure> resourceFailures = {};
  final Set<PatientResourceType> loadingResources = {};
  final Set<int> cancellingAppointments = {};
  final Set<int> _paymentEligibleAppointmentIds = {};
  final Set<int> _submittedPaymentAppointmentIds = {};

  static const List<String> supportedPaymentMethods = ['Cash', 'Card'];
  static const List<String> supportedBloodTypes = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];
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

  List<AppointmentModel> get filteredAppointments {
    final result = appointments
        .where((appointment) {
          final status = appointment.status.trim().toLowerCase();
          return switch (selectedAppointmentFilter) {
            PatientAppointmentFilter.all => true,
            PatientAppointmentFilter.upcoming =>
              status == 'pending' || status == 'confirmed',
            PatientAppointmentFilter.completed => status == 'completed',
            PatientAppointmentFilter.cancelled =>
              status == 'cancelled' || status == 'canceled',
          };
        })
        .toList(growable: false);
    result.sort(
      selectedAppointmentFilter == PatientAppointmentFilter.upcoming
          ? (first, second) =>
                first.appointmentDate.compareTo(second.appointmentDate)
          : (first, second) =>
                second.appointmentDate.compareTo(first.appointmentDate),
    );
    return result;
  }

  int get unreadNotificationsCount => _notificationService?.unreadCount ?? 0;
  bool get isPatientProfileEditBusy =>
      isSavingPatientProfile || isPickingPatientImage;

  List<String> get editableBloodTypes {
    final current = selectedPatientBloodType;
    if (current == null || supportedBloodTypes.contains(current)) {
      return supportedBloodTypes;
    }
    return [current, ...supportedBloodTypes];
  }

  @override
  void onInit() {
    super.onInit();
    _notificationService?.addListener(_notificationsChanged);
    _notificationService?.loadForCurrentUser(role: 'patient');
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
    isLoadingProfile = true;
    isLoadingDoctors = true;
    isLoadingAppointments = true;
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
        isLoadingProfile = false;
        isLoadingAppointments = false;
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
      isLoadingProfile = false;
      isLoadingDoctors = false;
      isLoadingAppointments = false;
      isRefreshing = false;
      if (!_inactive) update();
    }
  }

  Future<void> _loadProfile(int userId, String? email) async {
    try {
      final result = await _homeData.getPatientProfile(
        userId: userId,
        email: email,
      );
      if (_inactive) return;
      result.fold((failure) => profileFailure = failure, (value) {
        patient = value;
        profileFailure = null;
      });
    } finally {
      isLoadingProfile = false;
    }
  }

  Future<void> _loadDoctors() async {
    try {
      final result = await _homeData.getDoctors();
      if (_inactive) return;
      result.fold((failure) => doctorsFailure = failure, (value) {
        doctors = value;
        doctorsFailure = null;
        _enrichAppointmentsWithDoctors();
      });
    } finally {
      isLoadingDoctors = false;
    }
  }

  Future<void> _loadAppointments() async {
    List<AppointmentModel>? loadedAppointments;
    try {
      final result = await _homeData.getPatientAppointments();
      if (_inactive) return;
      result.fold((failure) => appointmentsFailure = failure, (value) {
        appointments = value;
        loadedAppointments = value;
        appointmentsFailure = null;
        _enrichAppointmentsWithDoctors();
      });
      if (loadedAppointments != null) {
        await _notificationService?.syncPatientAppointments(
          loadedAppointments!.map(_patientNotificationSnapshot),
        );
      }
    } finally {
      isLoadingAppointments = false;
    }
  }

  Future<void> refreshAppointments() async {
    if (_inactive) return;
    appointmentsFailure = null;
    isLoadingAppointments = true;
    update();
    await _loadAppointments();
    if (!_inactive) update();
  }

  Future<void> refreshDoctors() async {
    if (_inactive || isLoadingDoctors) return;
    doctorsFailure = null;
    isLoadingDoctors = true;
    update();
    await _loadDoctors();
    if (!_inactive) update();
  }

  Future<void> refreshPatientProfile() async {
    if (_inactive || isLoadingProfile) return;
    final userId = await _homeData.getAuthenticatedUserId();
    final email = await _homeData.getAuthenticatedEmail();
    if (_inactive) return;
    if (userId == null || userId <= 0) {
      profileFailure = const ServerFailure(
        'Unable to identify the authenticated patient.',
        statusCode: 401,
      );
      update();
      return;
    }
    isLoadingProfile = true;
    profileFailure = null;
    update();
    await _loadProfile(userId, email);
    if (!_inactive) update();
  }

  void _enrichAppointmentsWithDoctors() {
    if (appointments.isEmpty || doctors.isEmpty) return;
    appointments = appointments
        .map((appointment) {
          final appointmentDoctor = _normalizedName(appointment.doctorName);
          DoctorDetailsModel? doctor;
          for (final candidate in doctors) {
            if (_normalizedName(candidate.fullName) == appointmentDoctor) {
              doctor = candidate;
              break;
            }
          }
          if (doctor == null) return appointment;
          return AppointmentModel(
            id: appointment.id,
            doctorName: appointment.doctorName,
            doctorId: appointment.doctorId ?? doctor.id,
            patientId: appointment.patientId,
            doctorSpecialization:
                appointment.doctorSpecialization ?? doctor.specialization,
            doctorImage: appointment.doctorImage ?? doctor.imagePath,
            patientName: appointment.patientName,
            appointmentDate: appointment.appointmentDate,
            status: appointment.status,
            lastStatusDate: appointment.lastStatusDate,
            medicalRecordId: appointment.medicalRecordId,
            appointmentNotes: appointment.appointmentNotes,
          );
        })
        .toList(growable: false);
  }

  String _normalizedName(String value) => value
      .trim()
      .toLowerCase()
      .replaceFirst(RegExp(r'^dr\.?\s*'), '')
      .replaceAll(RegExp(r'\s+'), ' ');

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
    if (succeeded) {
      await _notificationService?.recordPatientAppointmentCancelled(
        _patientNotificationSnapshot(appointment),
      );
    }
    if (succeeded) await refreshAppointments();
    if (!_inactive) update();
    return succeeded;
  }

  void registerCreatedAppointment(int appointmentId) {
    if (_inactive || appointmentId <= 0) return;
    _paymentEligibleAppointmentIds.add(appointmentId);
  }

  Future<void> recordCreatedAppointment(AppointmentModel appointment) async {
    if (_inactive || appointment.id <= 0) return;
    registerCreatedAppointment(appointment.id);
    await _notificationService?.recordAppointmentCreated(
      _patientNotificationSnapshot(appointment),
    );
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
      final existingPayments =
          resourceItems[PatientResourceType.payments] ?? const [];
      resourceItems[PatientResourceType.payments] = [
        {
          'id': value,
          'appointmentId': appointmentId,
          'amount': amount,
          'paymentMethod': paymentMethod,
          'status': 'Pending',
        },
        ...existingPayments.where((item) => item['id'] != value),
      ];
      resourceFailures.remove(PatientResourceType.payments);
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
  void showAppointments() {
    final changedFilter =
        selectedAppointmentFilter != PatientAppointmentFilter.all;
    selectedAppointmentFilter = PatientAppointmentFilter.all;
    if (selectedTab == 2) {
      if (changedFilter) update();
      return;
    }
    selectTab(2);
  }

  void showProfile() => selectTab(3);

  void openEditProfile() {
    if (!preparePatientProfileEdit()) {
      Get.snackbar('editProfile'.tr, 'patientEditProfileUnavailable'.tr);
      return;
    }
    Get.toNamed<void>(Approutes.patientEditProfile);
  }

  bool preparePatientProfileEdit() {
    final current = patient;
    if (_inactive || current == null) return false;
    patientFirstNameController.text = current.firstName;
    patientLastNameController.text = current.lastName;
    patientPhoneController.text = current.phoneNumber ?? '';
    patientAddressController.text = current.address ?? '';
    patientNoteController.text = current.note ?? '';
    patientAgeController.text = current.age?.toString() ?? '';
    selectedPatientGender = _patientGenderValue(current.gender);
    selectedPatientBloodType = current.bloodType;
    selectedPatientImagePath = null;
    _uploadedPatientImageName = null;
    profileEditFailure = null;
    return true;
  }

  void selectPatientGender(int value) {
    if (_inactive || isPatientProfileEditBusy || (value != 0 && value != 1)) {
      return;
    }
    if (selectedPatientGender == value) return;
    selectedPatientGender = value;
    profileEditFailure = null;
    update();
  }

  void selectPatientBloodType(String? value) {
    if (_inactive || isPatientProfileEditBusy || value == null) return;
    if (!editableBloodTypes.contains(value) ||
        selectedPatientBloodType == value) {
      return;
    }
    selectedPatientBloodType = value;
    profileEditFailure = null;
    update();
  }

  String? validatePatientName(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'fieldRequired'.tr;
    if (text.length < 2) return 'nameTooShort'.tr;
    if (text.length > 100) return 'valueTooLong'.tr;
    return null;
  }

  String? validatePatientAge(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    final age = int.tryParse(text);
    if (age == null) return 'validNumberRequired'.tr;
    if (age < 1 || age > 120) return 'validAgeRequired'.tr;
    return null;
  }

  String? validatePatientOptionalText(String? value) {
    if ((value?.trim().length ?? 0) > 1000) return 'valueTooLong'.tr;
    return null;
  }

  Future<void> pickPatientProfileImage() async {
    if (_inactive || isPatientProfileEditBusy) return;
    isPickingPatientImage = true;
    profileEditFailure = null;
    update();
    try {
      final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (_inactive || picked == null) return;
      selectedPatientImagePath = picked.path;
      _uploadedPatientImageName = null;
    } catch (_) {
      profileEditFailure = ServerFailure('imageSelectionFailed'.tr);
    } finally {
      isPickingPatientImage = false;
      if (!_inactive) update();
    }
  }

  Future<void> savePatientProfile() async {
    if (_inactive || isPatientProfileEditBusy) return;
    if (!(patientEditFormKey.currentState?.validate() ?? false)) return;
    final current = patient;
    final bloodType = selectedPatientBloodType;
    final nationalityNo = current?.nationalityNo?.trim() ?? '';
    final nationalityCountryId = current?.nationalityCountryId ?? 0;
    if (current == null ||
        current.patientId <= 0 ||
        current.personId <= 0 ||
        nationalityNo.isEmpty ||
        nationalityCountryId <= 0 ||
        bloodType == null ||
        bloodType.trim().isEmpty) {
      profileEditFailure = ServerFailure('patientEditProfileUnavailable'.tr);
      update();
      return;
    }

    isSavingPatientProfile = true;
    profileEditFailure = null;
    update();
    try {
      var savedImagePath = current.imagePath;
      final localImage = selectedPatientImagePath;
      if (localImage != null && _uploadedPatientImageName == null) {
        final imageData = _imageData;
        if (imageData == null) {
          _patientProfileSaveFailed(ServerFailure('imageUploadUnavailable'.tr));
          return;
        }
        final uploadResult = await imageData.uploadAuthenticatedImageName(
          localImage,
        );
        if (_inactive) return;
        Failure? uploadFailure;
        uploadResult.fold(
          (failure) => uploadFailure = failure,
          (imageName) => _uploadedPatientImageName = imageName,
        );
        if (uploadFailure != null) {
          _patientProfileSaveFailed(uploadFailure!);
          return;
        }
      }
      savedImagePath = _uploadedPatientImageName ?? savedImagePath;

      final personResult = await _homeData.updatePersonProfile(
        personId: current.personId,
        firstName: patientFirstNameController.text.trim(),
        lastName: patientLastNameController.text.trim(),
        nationalityNo: nationalityNo,
        phoneNumber: _nullableText(patientPhoneController.text),
        age: int.tryParse(patientAgeController.text.trim()),
        address: _nullableText(patientAddressController.text),
        gender: selectedPatientGender,
        nationalityCountryId: nationalityCountryId,
        imagePath: savedImagePath,
        note: _nullableText(patientNoteController.text),
      );
      if (_inactive) return;
      Failure? personFailure;
      personResult.fold((failure) => personFailure = failure, (_) {});
      if (personFailure != null) {
        _patientProfileSaveFailed(personFailure!);
        return;
      }

      _applyEditedPatientProfile(
        current,
        imagePath: savedImagePath,
        bloodType: current.bloodType,
      );

      final patientResult = await _homeData.updatePatientProfile(
        patientId: current.patientId,
        personId: current.personId,
        bloodType: bloodType,
      );
      if (_inactive) return;
      Failure? patientFailure;
      patientResult.fold((failure) => patientFailure = failure, (_) {});
      if (patientFailure != null) {
        await refreshPatientProfile();
        if (_inactive) return;
        final refreshedProfile = patient ?? current;
        _applyEditedPatientProfile(
          refreshedProfile,
          imagePath: savedImagePath,
          bloodType: refreshedProfile.bloodType,
        );
        _patientProfileSaveFailed(
          ServerFailure(
            '${'profilePartiallyUpdated'.tr} ${patientFailure!.message}',
          ),
        );
        return;
      }

      _applyEditedPatientProfile(
        patient!,
        imagePath: savedImagePath,
        bloodType: bloodType,
      );
      await refreshPatientProfile();
      if (_inactive) return;
      _applyEditedPatientProfile(
        patient ?? current,
        imagePath: savedImagePath,
        bloodType: bloodType,
      );
      selectedPatientImagePath = null;
      _uploadedPatientImageName = null;
      profileEditFailure = null;
      Get.back<void>();
      Get.snackbar('profile'.tr, 'profileUpdated'.tr);
    } finally {
      isSavingPatientProfile = false;
      if (!_inactive) update();
    }
  }

  void _applyEditedPatientProfile(
    PatientHomeProfileModel current, {
    required String? imagePath,
    required String? bloodType,
  }) {
    patient = PatientHomeProfileModel(
      userId: current.userId,
      patientId: current.patientId,
      personId: current.personId,
      firstName: patientFirstNameController.text.trim(),
      lastName: patientLastNameController.text.trim(),
      email: current.email,
      phoneNumber: _nullableText(patientPhoneController.text),
      address: _nullableText(patientAddressController.text),
      note: _nullableText(patientNoteController.text),
      nationalityNo: current.nationalityNo,
      nationalityCountryId: current.nationalityCountryId,
      imagePath: imagePath,
      bloodType: bloodType,
      age: int.tryParse(patientAgeController.text.trim()),
      gender: selectedPatientGender,
    );
    profileFailure = null;
    update();
  }

  void _patientProfileSaveFailed(Failure failure) {
    profileEditFailure = failure;
    Get.snackbar('editProfile'.tr, failure.message);
  }

  int _patientGenderValue(Object? value) {
    final parsed = value is num
        ? value.toInt()
        : int.tryParse(value?.toString().trim() ?? '');
    return parsed == 1 ? 1 : 0;
  }

  String? _nullableText(String value) {
    final text = value.trim();
    return text.isEmpty ? null : text;
  }

  void selectAppointmentFilter(PatientAppointmentFilter value) {
    if (_inactive || selectedAppointmentFilter == value) return;
    selectedAppointmentFilter = value;
    update();
  }

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
    _notificationService?.removeListener(_notificationsChanged);
    searchController.dispose();
    patientFirstNameController.dispose();
    patientLastNameController.dispose();
    patientPhoneController.dispose();
    patientAddressController.dispose();
    patientNoteController.dispose();
    patientAgeController.dispose();
    super.onClose();
  }

  ClinicAppointmentNotificationSnapshot _patientNotificationSnapshot(
    AppointmentModel appointment,
  ) => ClinicAppointmentNotificationSnapshot(
    id: appointment.id,
    personName: appointment.doctorName,
    appointmentDate: appointment.appointmentDate,
    status: appointment.status,
    lastStatusDate: appointment.lastStatusDate,
  );

  void _notificationsChanged() {
    if (!_inactive) update();
  }
}
