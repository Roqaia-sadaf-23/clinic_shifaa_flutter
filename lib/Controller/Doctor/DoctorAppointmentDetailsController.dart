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
  bool _isConfirming = false;
  bool _disposed = false;
  late final int _appointmentId;

  bool get isBusy => isLoading || _isConfirming || isCancelling || isCompleting;
  bool get _inactive => _disposed || isClosed;

  int get appointmentId {
    return _appointmentId;
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

  bool get _belongsToCurrentDoctor => Get.isRegistered<DoctorHomeController>();

  @override
  void onInit() {
    final value = Get.arguments;
    _appointmentId = value is int ? value : int.tryParse('$value') ?? 0;
    super.onInit();
    load();
  }

  Future<void> load() async {
    if (isLoading || _inactive || appointmentId <= 0) return;
    isLoading = true;
    failure = null;
    update();
    try {
      final result = await _data.getAppointmentById(appointmentId);
      if (_inactive) return;
      result.fold((value) => failure = value, (body) {
        try {
          final value = _responseMap(body);
          appointment = AppointmentModel.fromJson(
            Map<String, dynamic>.from(value),
          );
        } catch (_) {
          failure = const ServerFailure('Invalid appointment response.');
        }
      });
    } catch (_) {
      failure = const ServerFailure('Unable to load appointment.');
    } finally {
      isLoading = false;
      if (!_inactive) update();
    }
  }

  Future<void> cancel(BuildContext context) async {
    await _confirmAndChange(
      context,
      message: 'cancelAppointmentQuestion'.tr,
      cancel: true,
    );
  }

  Future<void> complete(BuildContext context) async {
    await _confirmAndChange(
      context,
      message: 'completeAppointmentQuestion'.tr,
      cancel: false,
    );
  }

  Future<void> _confirmAndChange(
    BuildContext context, {
    required String message,
    required bool cancel,
  }) async {
    final allowed = cancel ? canCancel : canComplete;
    if (!allowed || isBusy || _inactive) return;
    _isConfirming = true;
    update();
    var confirmed = false;
    try {
      confirmed = await _confirm(context, message);
    } finally {
      _isConfirming = false;
      if (!_inactive) update();
    }
    if (!confirmed || _inactive) return;
    await _changeStatus(cancel: cancel);
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
    if (_inactive || isCancelling || isCompleting) return;
    cancel ? isCancelling = true : isCompleting = true;
    update();
    try {
      final result = cancel
          ? await _data.cancelAppointment(appointmentId)
          : await _data.completeAppointment(appointmentId);
      if (_inactive) return;
      await result.fold(
        (value) async {
          failure = value;
          if (!_inactive) Get.snackbar('error'.tr, 'requestFailed'.tr);
        },
        (_) async {
          await load();
          if (_inactive) return;
          if (Get.isRegistered<DoctorAppointmentsController>()) {
            await Get.find<DoctorAppointmentsController>().refreshList();
          }
          if (_inactive) return;
          if (Get.isRegistered<DoctorHomeController>()) {
            await Get.find<DoctorHomeController>().refreshAppointments();
          }
          if (!_inactive) {
            Get.snackbar('success'.tr, 'appointmentUpdated'.tr);
          }
        },
      );
    } catch (_) {
      failure = const ServerFailure('Unable to update appointment.');
      if (!_inactive) Get.snackbar('error'.tr, 'requestFailed'.tr);
    } finally {
      isCancelling = false;
      isCompleting = false;
      if (!_inactive) update();
    }
  }

  Map<dynamic, dynamic> _responseMap(Object? response) {
    if (response is! Map) throw const FormatException();
    final nested = response['data'] ?? response['result'];
    if (nested == null) return response;
    if (nested is Map) return nested;
    throw const FormatException();
  }

  @override
  void onClose() {
    _disposed = true;
    super.onClose();
  }
}
