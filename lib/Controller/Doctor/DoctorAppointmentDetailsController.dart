import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/Error/Failure.dart';
import '../../data/datasource/remote/Appointments/DoctorAppointmentData.dart';
import '../../data/model/AppointmentModel.dart';
import 'DoctorAppointmentsController.dart';
import 'DoctorHome_Controller.dart';

class DoctorAppointmentDetailsController extends GetxController {
  DoctorAppointmentDetailsController(this._data);
  final DoctorAppointmentData _data;
  AppointmentModel? appointment;
  Failure? failure;
  bool isLoading = false;
  bool isCancelling = false;
  bool isCompleting = false;
  bool _disposed = false;

  int get appointmentId {
    final value = Get.arguments;
    return value is int ? value : int.tryParse('$value') ?? 0;
  }

  bool get canCancel {
    final status = appointment?.status.toLowerCase();
    return _belongsToCurrentDoctor &&
        (status == 'pending' || status == 'confirmed');
  }

  bool get canComplete {
    final status = appointment?.status.toLowerCase();
    return _belongsToCurrentDoctor &&
        (status == 'pending' || status == 'confirmed');
  }

  bool get _belongsToCurrentDoctor =>
      Get.isRegistered<DoctorHomeController>() &&
      Get.find<DoctorHomeController>().doctor?.id == appointment?.doctorId;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    if (isLoading || _disposed || appointmentId <= 0) return;
    isLoading = true;
    failure = null;
    update();
    try {
      final result = await _data.getAppointmentById(appointmentId);
      if (_disposed) return;
      result.fold((value) => failure = value, (body) {
        try {
          if (body is! Map) throw const FormatException();
          appointment = AppointmentModel.fromJson(
            Map<String, dynamic>.from(body),
          );
        } catch (_) {
          failure = const ServerFailure('Invalid appointment response.');
        }
      });
    } catch (_) {
      failure = const ServerFailure('Unable to load appointment.');
    } finally {
      isLoading = false;
      if (!_disposed && !isClosed) update();
    }
  }

  Future<void> cancel(BuildContext context) async {
    if (!canCancel || isCancelling || isCompleting) return;
    if (!await _confirm(context, 'cancelAppointmentQuestion'.tr)) return;
    await _changeStatus(cancel: true);
  }

  Future<void> complete(BuildContext context) async {
    if (!canComplete || isCancelling || isCompleting) return;
    if (!await _confirm(context, 'completeAppointmentQuestion'.tr)) return;
    await _changeStatus(cancel: false);
  }

  Future<bool> _confirm(BuildContext context, String message) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('confirm'.tr),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('cancel'.tr),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('confirm'.tr),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _changeStatus({required bool cancel}) async {
    cancel ? isCancelling = true : isCompleting = true;
    update();
    try {
      final result = cancel
          ? await _data.cancelAppointment(appointmentId)
          : await _data.completeAppointment(appointmentId);
      if (_disposed) return;
      await result.fold(
        (value) async {
          failure = value;
          Get.snackbar('error'.tr, 'requestFailed'.tr);
        },
        (_) async {
          await load();
          if (Get.isRegistered<DoctorAppointmentsController>()) {
            await Get.find<DoctorAppointmentsController>().refreshList();
          }
          if (Get.isRegistered<DoctorHomeController>()) {
            await Get.find<DoctorHomeController>().refreshDashboard();
          }
          Get.snackbar('success'.tr, 'appointmentUpdated'.tr);
        },
      );
    } catch (_) {
      failure = const ServerFailure('Unable to update appointment.');
      Get.snackbar('error'.tr, 'requestFailed'.tr);
    } finally {
      isCancelling = false;
      isCompleting = false;
      if (!_disposed && !isClosed) update();
    }
  }

  @override
  void onClose() {
    _disposed = true;
    super.onClose();
  }
}
