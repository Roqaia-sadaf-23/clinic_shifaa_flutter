import 'package:get/get.dart';

import '../../core/Error/Failure.dart';
import '../../core/class/ApiService.dart';
import '../../core/constant/Approutes.dart';
import '../../data/datasource/remote/Patients/DoctorPatientDetailsData.dart';
import '../../data/model/DoctorPatientDetailsModels.dart';
import '../../data/model/DoctorPatientModel.dart';

class PatientDetailsSectionState<T> {
  List<T> items = List<T>.empty();
  Failure? failure;
  bool isLoading = false;
  bool isRefreshing = false;
  bool hasLoaded = false;
  bool isRequesting = false;

  bool get isInitialLoading => isLoading && !hasLoaded && items.isEmpty;
}

class DoctorPatientDetailsController extends GetxController {
  DoctorPatientDetailsController(this._data);

  final DoctorPatientDetailsData _data;

  final appointments =
      PatientDetailsSectionState<DoctorPatientAppointmentDetailsModel>();
  final medicalRecords =
      PatientDetailsSectionState<DoctorPatientMedicalRecordModel>();
  final prescriptions =
      PatientDetailsSectionState<DoctorPatientPrescriptionModel>();
  final payments = PatientDetailsSectionState<DoctorPatientPaymentModel>();

  late final int patientId;
  DoctorPatientModel? patient;
  Failure? argumentFailure;
  bool _disposed = false;
  final Set<int> _appointmentsWithCreatedMedicalRecords = <int>{};

  bool get hasValidPatientId => patientId > 0;
  bool get _inactive => _disposed || isClosed;
  bool get canCheckMedicalRecordRelationships =>
      medicalRecords.hasLoaded &&
      !medicalRecords.isRequesting &&
      medicalRecords.failure == null;

  String? get patientName {
    final argumentName = patient?.patientName.trim();
    if (argumentName != null && argumentName.isNotEmpty) return argumentName;
    if (appointments.items.isNotEmpty) {
      final appointmentName = appointments.items.first.patientName.trim();
      if (appointmentName.isNotEmpty) return appointmentName;
    }
    return null;
  }

  DoctorPatientMedicalRecordModel? medicalRecordForAppointment(
    int appointmentId,
  ) {
    if (appointmentId <= 0) return null;
    for (final record in medicalRecords.items) {
      if (record.appointmentId == appointmentId) return record;
    }
    return null;
  }

  bool hasMedicalRecord(int appointmentId) {
    return appointmentId > 0 &&
        (_appointmentsWithCreatedMedicalRecords.contains(appointmentId) ||
            medicalRecordForAppointment(appointmentId) != null);
  }

  bool canCreateMedicalRecordFor(
    DoctorPatientAppointmentDetailsModel appointment,
  ) {
    return canCheckMedicalRecordRelationships &&
        hasValidPatientId &&
        appointment.patientId == patientId &&
        appointment.appointmentId > 0 &&
        !hasMedicalRecord(appointment.appointmentId);
  }

  bool containsMedicalRecord(DoctorPatientMedicalRecordModel record) {
    return containsMedicalRecordId(
      record.medicalRecordId,
      appointmentId: record.appointmentId,
    );
  }

  bool containsMedicalRecordId(int medicalRecordId, {int? appointmentId}) {
    if (medicalRecordId <= 0) return false;
    return medicalRecords.items.any(
      (record) =>
          record.medicalRecordId == medicalRecordId &&
          (appointmentId == null || record.appointmentId == appointmentId),
    );
  }

  void markAppointmentHasMedicalRecord(int appointmentId) {
    if (appointmentId <= 0) return;
    _appointmentsWithCreatedMedicalRecords.add(appointmentId);
    if (!_inactive) update();
  }

  void mergeCreatedMedicalRecord(DoctorPatientMedicalRecordModel record) {
    if (record.medicalRecordId <= 0 || record.appointmentId <= 0) return;
    _appointmentsWithCreatedMedicalRecords.add(record.appointmentId);
    medicalRecords.items = [
      record,
      ...medicalRecords.items.where(
        (item) =>
            item.medicalRecordId != record.medicalRecordId &&
            item.appointmentId != record.appointmentId,
      ),
    ];
    medicalRecords.hasLoaded = true;
    medicalRecords.failure = null;
    if (!_inactive) update();
  }

  void mergeCreatedPrescription(DoctorPatientPrescriptionModel prescription) {
    if (prescription.prescriptionId <= 0) return;
    prescriptions.items = [
      prescription,
      ...prescriptions.items.where(
        (item) => item.prescriptionId != prescription.prescriptionId,
      ),
    ];
    prescriptions.hasLoaded = true;
    prescriptions.failure = null;
    if (!_inactive) update();
  }

  void openMedicalRecordForm(DoctorPatientAppointmentDetailsModel appointment) {
    if (!hasValidPatientId ||
        appointment.patientId != patientId ||
        appointment.appointmentId <= 0) {
      Get.snackbar('error'.tr, 'invalidAppointment'.tr);
      return;
    }
    if (!canCheckMedicalRecordRelationships) return;
    if (hasMedicalRecord(appointment.appointmentId)) {
      Get.snackbar('error'.tr, 'alreadyHasMedicalRecord'.tr);
      return;
    }
    if (Get.currentRoute == Approutes.createMedicalRecord) return;
    Get.toNamed(
      Approutes.createMedicalRecord,
      arguments: MedicalRecordFormArguments(
        patientId: patientId,
        appointmentId: appointment.appointmentId,
        appointment: appointment,
      ),
    );
  }

  void openPrescriptionForm(DoctorPatientMedicalRecordModel medicalRecord) {
    if (!hasValidPatientId ||
        medicalRecord.medicalRecordId <= 0 ||
        medicalRecord.appointmentId <= 0 ||
        !containsMedicalRecord(medicalRecord)) {
      Get.snackbar('error'.tr, 'medicalRecordNotFound'.tr);
      return;
    }
    if (Get.currentRoute == Approutes.createPrescription) return;
    Get.toNamed(
      Approutes.createPrescription,
      arguments: PrescriptionFormArguments(
        patientId: patientId,
        medicalRecordId: medicalRecord.medicalRecordId,
        medicalRecord: medicalRecord,
      ),
    );
  }

  @override
  void onInit() {
    super.onInit();
    patientId = _readPatientId(Get.arguments);
    if (!hasValidPatientId) {
      argumentFailure = const ServerFailure('Invalid patient id.');
      return;
    }
    loadAll();
  }

  Future<void> loadAll({bool refreshing = false}) async {
    if (!hasValidPatientId || _inactive) return;
    await Future.wait<void>([
      loadAppointments(refreshing: refreshing),
      loadMedicalRecords(refreshing: refreshing),
      loadPrescriptions(refreshing: refreshing),
      loadPayments(refreshing: refreshing),
    ]);
  }

  Future<void> refreshAll() => loadAll(refreshing: true);

  Future<void> loadAppointments({bool refreshing = false}) {
    return _load(
      appointments,
      () => _data.getAppointments(patientId),
      refreshing: refreshing,
      fallbackMessage: 'Unable to load appointments.',
    );
  }

  Future<void> refreshAppointments() => loadAppointments(refreshing: true);

  Future<void> loadMedicalRecords({bool refreshing = false}) {
    return _load(
      medicalRecords,
      () => _data.getMedicalRecords(patientId),
      refreshing: refreshing,
      fallbackMessage: 'Unable to load medical records.',
    );
  }

  Future<void> refreshMedicalRecords() => loadMedicalRecords(refreshing: true);

  Future<void> loadPrescriptions({bool refreshing = false}) {
    return _load(
      prescriptions,
      () => _data.getPrescriptions(patientId),
      refreshing: refreshing,
      fallbackMessage: 'Unable to load prescriptions.',
    );
  }

  Future<void> refreshPrescriptions() => loadPrescriptions(refreshing: true);

  Future<void> loadPayments({bool refreshing = false}) {
    return _load(
      payments,
      () => _data.getPayments(patientId),
      refreshing: refreshing,
      fallbackMessage: 'Unable to load payments.',
    );
  }

  Future<void> refreshPayments() => loadPayments(refreshing: true);

  Future<void> _load<T>(
    PatientDetailsSectionState<T> section,
    Future<Either<Failure, List<T>>> Function() request, {
    required bool refreshing,
    required String fallbackMessage,
  }) async {
    if (!hasValidPatientId || section.isRequesting || _inactive) return;

    section.isRequesting = true;
    section.failure = null;
    if (refreshing) {
      section.isRefreshing = true;
    } else {
      section.isLoading = true;
    }
    update();

    try {
      final result = await request();
      if (_inactive) return;
      result.fold((failure) => section.failure = failure, (items) {
        section.items = items;
        section.hasLoaded = true;
        section.failure = null;
      });
    } catch (_) {
      if (!_inactive) section.failure = ServerFailure(fallbackMessage);
    } finally {
      section.isRequesting = false;
      section.isLoading = false;
      section.isRefreshing = false;
      if (!_inactive) update();
    }
  }

  int _readPatientId(Object? arguments) {
    if (arguments is DoctorPatientModel) {
      patient = arguments;
      return arguments.patientId;
    }
    if (arguments is int) return arguments;
    if (arguments is num && arguments.isFinite) return arguments.toInt();
    if (arguments is Map) {
      final value = _mapValue(arguments, 'patientId');
      if (value is int) return value;
      if (value is num && value.isFinite) return value.toInt();
      return int.tryParse(value?.toString().trim() ?? '') ?? 0;
    }
    return int.tryParse(arguments?.toString().trim() ?? '') ?? 0;
  }

  Object? _mapValue(Map<dynamic, dynamic> map, String name) {
    for (final entry in map.entries) {
      final key = entry.key;
      if (key is String && key.toLowerCase() == name.toLowerCase()) {
        return entry.value;
      }
    }
    return null;
  }

  @override
  void onClose() {
    _disposed = true;
    super.onClose();
  }
}
