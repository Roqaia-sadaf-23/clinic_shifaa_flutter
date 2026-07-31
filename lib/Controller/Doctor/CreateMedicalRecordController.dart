import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/Error/Failure.dart';
import '../../data/datasource/remote/Patients/DoctorPatientDetailsData.dart';
import '../../data/model/DoctorPatientDetailsModels.dart';
import 'DoctorAppointmentsController.dart';
import 'DoctorPatientDetailsController.dart';

class CreateMedicalRecordController extends GetxController {
  CreateMedicalRecordController(this._data, this._patientDetailsController);

  final DoctorPatientDetailsData _data;
  final DoctorPatientDetailsController? _patientDetailsController;

  final formKey = GlobalKey<FormState>();
  final diagnosisController = TextEditingController();
  final visitDescriptionController = TextEditingController();
  final notesController = TextEditingController();

  int patientId = 0;
  int appointmentId = 0;
  DoctorPatientAppointmentDetailsModel? appointment;
  Failure? failure;
  String? argumentErrorKey;
  bool isSubmitting = false;
  bool _disposed = false;

  bool get hasValidArguments =>
      argumentErrorKey == null && patientId > 0 && appointmentId > 0;

  String? get failureMessage =>
      failure == null ? null : _messageForFailure(failure!);

  @override
  void onInit() {
    super.onInit();
    final arguments = Get.arguments;
    if (arguments is! MedicalRecordFormArguments ||
        arguments.patientId <= 0 ||
        arguments.appointmentId <= 0 ||
        arguments.appointment.patientId <= 0 ||
        arguments.appointment.patientId != arguments.patientId ||
        arguments.appointment.appointmentId <= 0 ||
        arguments.appointment.appointmentId != arguments.appointmentId) {
      argumentErrorKey = 'invalidAppointment';
      return;
    }

    patientId = arguments.patientId;
    appointmentId = arguments.appointmentId;
    appointment = arguments.appointment;
    if (_matchingPatientDetailsController?.hasMedicalRecord(appointmentId) ??
        false) {
      argumentErrorKey = 'alreadyHasMedicalRecord';
    }
  }

  String? validateDiagnosis(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'diagnosisRequired'.tr;
    if (text.length > 500) return 'valueTooLong'.tr;
    return null;
  }

  String? validateVisitDescription(String? value) {
    if ((value?.trim().length ?? 0) > 1000) return 'valueTooLong'.tr;
    return null;
  }

  String? validateNotes(String? value) {
    if ((value?.trim().length ?? 0) > 1000) return 'valueTooLong'.tr;
    return null;
  }

  Future<void> submit() async {
    if (isSubmitting || _disposed || !hasValidArguments) return;
    final parent = _matchingPatientDetailsController;
    if (parent?.hasMedicalRecord(appointmentId) ?? false) {
      argumentErrorKey = 'alreadyHasMedicalRecord';
      update();
      return;
    }
    if (!(formKey.currentState?.validate() ?? false)) return;

    isSubmitting = true;
    failure = null;
    update();

    try {
      final request = CreateMedicalRecordRequest(
        appointmentId: appointmentId,
        diagnosis: diagnosisController.text.trim(),
        visitDescription: _optional(visitDescriptionController.text),
        notes: _optional(notesController.text),
      );
      final result = await _data.createMedicalRecord(request);
      if (_disposed) return;

      Failure? requestFailure;
      CreatedMedicalRecordResult? createdRecord;
      var succeeded = false;
      result.fold((value) => requestFailure = value, (value) {
        createdRecord = value;
        succeeded = true;
      });
      if (!succeeded) {
        failure = requestFailure;
        if (requestFailure?.statusCode == 409 &&
            Get.isRegistered<DoctorAppointmentsController>()) {
          await Get.find<DoctorAppointmentsController>().refreshList();
          if (_disposed) return;
        }
        Get.snackbar('error'.tr, _messageForFailure(requestFailure!));
        return;
      }

      final createdId = createdRecord?.medicalRecordId;
      if (parent != null) {
        parent.markAppointmentHasMedicalRecord(appointmentId);
        final sourceAppointment = appointment;
        if (createdId != null && createdId > 0 && sourceAppointment != null) {
          parent.mergeCreatedMedicalRecord(
            DoctorPatientMedicalRecordModel(
              medicalRecordId: createdId,
              appointmentId: appointmentId,
              appointmentDate: sourceAppointment.appointmentDate,
              diagnosis: request.diagnosis,
              visitDescription: request.visitDescription,
              notes: request.notes,
            ),
          );
        }
        await parent.refreshMedicalRecords();
        if (_disposed) return;
      }
      Get.back(
        result:
            createdRecord ??
            const CreatedMedicalRecordResult(medicalRecordId: null),
      );
      Get.snackbar(
        'success'.tr,
        'medicalRecordCreatedSuccessfully'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
      failure = const ServerFailure('Unable to create medical record.');
      if (!_disposed) {
        Get.snackbar('error'.tr, 'unableToCreateMedicalRecord'.tr);
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
      404 => 'appointmentNotFound'.tr,
      409 => 'alreadyHasMedicalRecord'.tr,
      _ when value is NetworkFailure => 'pleaseTryAgain'.tr,
      _ => 'unableToCreateMedicalRecord'.tr,
    };
  }

  String? _optional(String value) {
    final text = value.trim();
    return text.isEmpty ? null : text;
  }

  DoctorPatientDetailsController? get _matchingPatientDetailsController {
    final parent = _patientDetailsController;
    if (parent == null || parent.isClosed) return null;
    try {
      if (!parent.hasValidPatientId || parent.patientId != patientId) {
        return null;
      }
      return parent;
    } catch (_) {
      return null;
    }
  }

  @override
  void onClose() {
    _disposed = true;
    diagnosisController.dispose();
    visitDescriptionController.dispose();
    notesController.dispose();
    super.onClose();
  }
}
