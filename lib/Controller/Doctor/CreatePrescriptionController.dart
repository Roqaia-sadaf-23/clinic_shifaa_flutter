import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/Error/Failure.dart';
import '../../data/datasource/remote/Patients/DoctorPatientDetailsData.dart';
import '../../data/model/DoctorPatientDetailsModels.dart';
import 'DoctorPatientDetailsController.dart';

class CreatePrescriptionController extends GetxController {
  CreatePrescriptionController(this._data, this._patientDetailsController);

  final DoctorPatientDetailsData _data;
  final DoctorPatientDetailsController? _patientDetailsController;

  final formKey = GlobalKey<FormState>();
  final medicationNameController = TextEditingController();
  final frequencyController = TextEditingController();
  final dosageController = TextEditingController();
  final specialInstructionsController = TextEditingController();

  int patientId = 0;
  int appointmentId = 0;
  int medicalRecordId = 0;
  DoctorPatientMedicalRecordModel? medicalRecord;
  Failure? failure;
  String? argumentErrorKey;
  bool isSubmitting = false;
  bool _disposed = false;

  bool get hasValidArguments =>
      argumentErrorKey == null &&
      patientId > 0 &&
      appointmentId > 0 &&
      medicalRecordId > 0;

  String? get failureMessage =>
      failure == null ? null : _messageForFailure(failure!);

  @override
  void onInit() {
    super.onInit();
    final arguments = Get.arguments;
    final parent = _patientDetailsController;
    if (arguments is! PrescriptionFormArguments ||
        arguments.patientId <= 0 ||
        arguments.medicalRecordId <= 0 ||
        arguments.medicalRecord.medicalRecordId <= 0 ||
        arguments.medicalRecord.medicalRecordId != arguments.medicalRecordId ||
        arguments.medicalRecord.appointmentId <= 0 ||
        parent == null ||
        !parent.hasValidPatientId ||
        parent.patientId != arguments.patientId ||
        !parent.containsMedicalRecord(arguments.medicalRecord)) {
      argumentErrorKey = 'medicalRecordNotFound';
      return;
    }

    patientId = arguments.patientId;
    appointmentId = arguments.medicalRecord.appointmentId;
    medicalRecordId = arguments.medicalRecordId;
    medicalRecord = arguments.medicalRecord;
  }

  String? validateMedicationName(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'medicationNameRequired'.tr;
    if (text.length > 100) return 'valueTooLong'.tr;
    return null;
  }

  String? validateFrequency(String? value) {
    if ((value?.trim().length ?? 0) > 50) return 'valueTooLong'.tr;
    return null;
  }

  String? validateDosage(String? value) {
    if ((value?.trim().length ?? 0) > 50) return 'valueTooLong'.tr;
    return null;
  }

  String? validateSpecialInstructions(String? value) {
    if ((value?.trim().length ?? 0) > 200) return 'valueTooLong'.tr;
    return null;
  }

  Future<void> submit() async {
    if (isSubmitting || _disposed || !hasValidArguments) return;
    final parent = _patientDetailsController;
    if (parent == null ||
        !parent.containsMedicalRecordId(
          medicalRecordId,
          appointmentId: appointmentId,
        )) {
      argumentErrorKey = 'medicalRecordNotFound';
      update();
      return;
    }
    if (!(formKey.currentState?.validate() ?? false)) return;

    isSubmitting = true;
    failure = null;
    update();

    try {
      final request = CreatePrescriptionRequest(
        medicalRecordId: medicalRecordId,
        medicationName: medicationNameController.text.trim(),
        frequency: _optional(frequencyController.text),
        dosage: _optional(dosageController.text),
        specialInstructions: _optional(specialInstructionsController.text),
      );
      final result = await _data.createPrescription(request);
      if (_disposed) return;

      Failure? requestFailure;
      CreatedPrescriptionResult? createdPrescription;
      var succeeded = false;
      result.fold((value) => requestFailure = value, (value) {
        createdPrescription = value;
        succeeded = true;
      });
      if (!succeeded) {
        failure = requestFailure;
        Get.snackbar('error'.tr, _messageForFailure(requestFailure!));
        return;
      }

      final createdId = createdPrescription?.prescriptionId;
      final sourceMedicalRecord = medicalRecord;
      if (createdId != null && createdId > 0 && sourceMedicalRecord != null) {
        parent.mergeCreatedPrescription(
          DoctorPatientPrescriptionModel(
            prescriptionId: createdId,
            medicalRecordId: medicalRecordId,
            appointmentId: appointmentId,
            appointmentDate: sourceMedicalRecord.appointmentDate,
            medicationName: request.medicationName,
            dosage: request.dosage,
            frequency: request.frequency,
            specialInstructions: request.specialInstructions,
          ),
        );
      }
      await parent.refreshPrescriptions();
      if (_disposed) return;
      Get.back();
      Get.snackbar(
        'success'.tr,
        'prescriptionCreatedSuccessfully'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
      failure = const ServerFailure('Unable to create prescription.');
      if (!_disposed) {
        Get.snackbar('error'.tr, 'unableToCreatePrescription'.tr);
      }
    } finally {
      isSubmitting = false;
      if (!_disposed) update();
    }
  }

  String _messageForFailure(Failure value) {
    return switch (value.statusCode) {
      400 when value.message.trim().isNotEmpty => value.message.trim(),
      401 => 'sessionExpired'.tr,
      403 => 'doctorPatientAccessForbidden'.tr,
      404 => 'medicalRecordNotFound'.tr,
      409 => 'unableToCreatePrescription'.tr,
      _ when value is NetworkFailure => 'pleaseTryAgain'.tr,
      _ => 'unableToCreatePrescription'.tr,
    };
  }

  String? _optional(String value) {
    final text = value.trim();
    return text.isEmpty ? null : text;
  }

  @override
  void onClose() {
    _disposed = true;
    medicationNameController.dispose();
    frequencyController.dispose();
    dosageController.dispose();
    specialInstructionsController.dispose();
    super.onClose();
  }
}
