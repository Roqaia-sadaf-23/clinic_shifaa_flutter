import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../Controller/Doctor/DoctorPatientDetailsController.dart';
import '../../../core/Error/Failure.dart';
import '../../../core/constant/Appcolor.dart';
import '../../../core/constant/Approutes.dart';
import '../../../data/model/DoctorPatientDetailsModels.dart';
import 'DoctorAppointmentsPage.dart';
import 'DoctorHomePage.dart';

class DoctorPatientDetailsPage extends StatelessWidget {
  const DoctorPatientDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: GetBuilder<DoctorPatientDetailsController>(
        builder: (controller) => Scaffold(
          backgroundColor: DoctorHomeColors.background(context),
          appBar: AppBar(
            title: Text(controller.patientName ?? 'patientDetails'.tr),
            bottom: TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: [
                Tab(text: 'appointments'.tr),
                Tab(text: 'medicalRecords'.tr),
                Tab(text: 'prescriptions'.tr),
                Tab(text: 'payments'.tr),
              ],
            ),
          ),
          body: controller.hasValidPatientId
              ? TabBarView(
                  children: [
                    _AppointmentsTab(controller: controller),
                    _MedicalRecordsTab(controller: controller),
                    _PrescriptionsTab(controller: controller),
                    _PaymentsTab(controller: controller),
                  ],
                )
              : const _InvalidPatientState(),
        ),
      ),
    );
  }
}

class _AppointmentsTab extends StatelessWidget {
  const _AppointmentsTab({required this.controller});

  final DoctorPatientDetailsController controller;

  @override
  Widget build(BuildContext context) {
    return _SectionView<DoctorPatientAppointmentDetailsModel>(
      state: controller.appointments,
      onRefresh: controller.refreshAppointments,
      onRetry: controller.loadAppointments,
      emptyIcon: Icons.event_busy_rounded,
      emptyMessage: 'noAppointments'.tr,
      errorMessageKey: 'appointmentsLoadError',
      itemBuilder: (item) => DoctorAppointmentCard(
        appointment: item,
        onTap: () => _openAppointment(item.appointmentId),
        additionalAction: controller.canCreateMedicalRecordFor(item)
            ? OutlinedButton.icon(
                onPressed: () => controller.openMedicalRecordForm(item),
                icon: const Icon(Icons.note_add_outlined, size: 18),
                label: Text('createMedicalRecord'.tr),
              )
            : null,
      ),
    );
  }
}

class _MedicalRecordsTab extends StatelessWidget {
  const _MedicalRecordsTab({required this.controller});

  final DoctorPatientDetailsController controller;

  @override
  Widget build(BuildContext context) {
    return _SectionView<DoctorPatientMedicalRecordModel>(
      state: controller.medicalRecords,
      onRefresh: controller.refreshMedicalRecords,
      onRetry: controller.loadMedicalRecords,
      emptyIcon: Icons.folder_off_outlined,
      emptyMessage: 'noMedicalRecords'.tr,
      errorMessageKey: 'medicalRecordsLoadError',
      itemBuilder: (item) =>
          _MedicalRecordCard(controller: controller, record: item),
    );
  }
}

class _PrescriptionsTab extends StatelessWidget {
  const _PrescriptionsTab({required this.controller});

  final DoctorPatientDetailsController controller;

  @override
  Widget build(BuildContext context) {
    return _SectionView<DoctorPatientPrescriptionModel>(
      state: controller.prescriptions,
      onRefresh: controller.refreshPrescriptions,
      onRetry: controller.loadPrescriptions,
      emptyIcon: Icons.medication_outlined,
      emptyMessage: 'noPrescriptions'.tr,
      errorMessageKey: 'prescriptionsLoadError',
      itemBuilder: (item) => _PrescriptionCard(prescription: item),
    );
  }
}

class _PaymentsTab extends StatelessWidget {
  const _PaymentsTab({required this.controller});

  final DoctorPatientDetailsController controller;

  @override
  Widget build(BuildContext context) {
    return _SectionView<DoctorPatientPaymentModel>(
      state: controller.payments,
      onRefresh: controller.refreshPayments,
      onRetry: controller.loadPayments,
      emptyIcon: Icons.payments_outlined,
      emptyMessage: 'noPayments'.tr,
      errorMessageKey: 'paymentsLoadError',
      itemBuilder: (item) => _PaymentCard(payment: item),
    );
  }
}

class _SectionView<T> extends StatelessWidget {
  const _SectionView({
    required this.state,
    required this.onRefresh,
    required this.onRetry,
    required this.emptyIcon,
    required this.emptyMessage,
    required this.errorMessageKey,
    required this.itemBuilder,
  });

  final PatientDetailsSectionState<T> state;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onRetry;
  final IconData emptyIcon;
  final String emptyMessage;
  final String errorMessageKey;
  final Widget Function(T item) itemBuilder;

  @override
  Widget build(BuildContext context) {
    if ((state.isInitialLoading || !state.hasLoaded) &&
        state.failure == null &&
        state.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.failure != null && state.items.isEmpty) {
      return _SectionErrorState(
        message: _failureMessage(state.failure!, errorMessageKey),
        onRetry: onRetry,
        isRetrying: state.isRequesting,
      );
    }

    final hasInlineError = state.failure != null;
    final itemCount = state.items.length + (hasInlineError ? 1 : 0);
    return RefreshIndicator(
      color: Appcolor.gold,
      onRefresh: onRefresh,
      child: itemCount == 0
          ? _SectionEmptyState(icon: emptyIcon, message: emptyMessage)
          : ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              itemCount: itemCount,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (hasInlineError && index == 0) {
                  return _InlineSectionError(
                    message: _failureMessage(state.failure!, errorMessageKey),
                    onRetry: onRetry,
                    isRetrying: state.isRequesting,
                  );
                }
                final itemIndex = index - (hasInlineError ? 1 : 0);
                return itemBuilder(state.items[itemIndex]);
              },
            ),
    );
  }
}

class _SectionEmptyState extends StatelessWidget {
  const _SectionEmptyState({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(32),
      children: [
        SizedBox(height: MediaQuery.sizeOf(context).height * .2),
        Icon(icon, size: 56, color: Appcolor.info),
        const SizedBox(height: 14),
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: DoctorHomeColors.text(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'pullToRefresh'.tr,
          textAlign: TextAlign.center,
          style: TextStyle(color: DoctorHomeColors.mutedText(context)),
        ),
      ],
    );
  }
}

class _SectionErrorState extends StatelessWidget {
  const _SectionErrorState({
    required this.message,
    required this.onRetry,
    required this.isRetrying,
  });

  final String message;
  final Future<void> Function() onRetry;
  final bool isRetrying;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 54,
              color: Appcolor.error,
            ),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: DoctorHomeColors.text(context)),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: isRetrying ? null : onRetry,
              icon: isRetrying
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh_rounded),
              label: Text('retry'.tr),
            ),
          ],
        ),
      ),
    );
  }
}

class _InlineSectionError extends StatelessWidget {
  const _InlineSectionError({
    required this.message,
    required this.onRetry,
    required this.isRetrying,
  });

  final String message;
  final Future<void> Function() onRetry;
  final bool isRetrying;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Appcolor.error),
          const SizedBox(width: 10),
          Expanded(child: Text(message)),
          TextButton(
            onPressed: isRetrying ? null : onRetry,
            child: Text('retry'.tr),
          ),
        ],
      ),
    );
  }
}

class _InvalidPatientState extends StatelessWidget {
  const _InvalidPatientState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.person_off_outlined,
              size: 56,
              color: Appcolor.error,
            ),
            const SizedBox(height: 14),
            Text(
              'invalidPatient'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(color: DoctorHomeColors.text(context)),
            ),
          ],
        ),
      ),
    );
  }
}

class _MedicalRecordCard extends StatelessWidget {
  const _MedicalRecordCard({required this.controller, required this.record});

  final DoctorPatientDetailsController controller;
  final DoctorPatientMedicalRecordModel record;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeading(
            icon: Icons.medical_information_outlined,
            title: _display(record.diagnosis),
            trailing: '#${record.medicalRecordId}',
          ),
          const SizedBox(height: 14),
          _InfoRow(
            label: 'appointmentDate'.tr,
            value: _dateTime(record.appointmentDate),
          ),
          _InfoRow(
            label: 'visitDescription'.tr,
            value: _display(record.visitDescription),
          ),
          _InfoRow(label: 'notes'.tr, value: _display(record.notes)),
          const SizedBox(height: 4),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 8,
            runSpacing: 8,
            children: [
              TextButton.icon(
                onPressed: () => _openAppointment(record.appointmentId),
                icon: const Icon(Icons.open_in_new_rounded, size: 18),
                label: Text('viewAppointment'.tr),
              ),
              FilledButton.icon(
                onPressed: () => controller.openPrescriptionForm(record),
                icon: const Icon(Icons.medication_outlined, size: 18),
                label: Text('createPrescription'.tr),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PrescriptionCard extends StatelessWidget {
  const _PrescriptionCard({required this.prescription});

  final DoctorPatientPrescriptionModel prescription;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeading(
            icon: Icons.medication_outlined,
            title: _display(prescription.medicationName),
            trailing: '#${prescription.prescriptionId}',
          ),
          const SizedBox(height: 14),
          _InfoRow(label: 'dosage'.tr, value: _display(prescription.dosage)),
          _InfoRow(
            label: 'frequency'.tr,
            value: _display(prescription.frequency),
          ),
          _InfoRow(
            label: 'specialInstructions'.tr,
            value: _display(prescription.specialInstructions),
          ),
          _InfoRow(
            label: 'appointmentDate'.tr,
            value: _dateTime(prescription.appointmentDate),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton.icon(
              onPressed: () => _openAppointment(prescription.appointmentId),
              icon: const Icon(Icons.open_in_new_rounded, size: 18),
              label: Text('viewAppointment'.tr),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({required this.payment});

  final DoctorPatientPaymentModel payment;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: Appcolor.gold.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.payments_outlined,
                  color: Appcolor.gold,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _amount(payment.amount),
                      style: TextStyle(
                        color: DoctorHomeColors.text(context),
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '#${payment.paymentId}',
                      style: TextStyle(
                        color: DoctorHomeColors.mutedText(context),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _PaymentStatusBadge(status: payment.status),
            ],
          ),
          const SizedBox(height: 14),
          _InfoRow(
            label: 'paymentMethod'.tr,
            value: _display(payment.paymentMethod),
          ),
          _InfoRow(
            label: 'appointmentDate'.tr,
            value: _dateTime(payment.appointmentDate),
          ),
          _InfoRow(
            label: 'createdDate'.tr,
            value: _dateTime(payment.createdAt),
          ),
          if (payment.note != null)
            _InfoRow(label: 'notes'.tr, value: payment.note!),
        ],
      ),
    );
  }
}

class _CardHeading extends StatelessWidget {
  const _CardHeading({
    required this.icon,
    required this.title,
    required this.trailing,
  });

  final IconData icon;
  final String title;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: Appcolor.info.withValues(alpha: .12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Appcolor.info),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: DoctorHomeColors.text(context),
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          trailing,
          style: TextStyle(
            color: DoctorHomeColors.mutedText(context),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(color: DoctorHomeColors.mutedText(context)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: DoctorHomeColors.text(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentStatusBadge extends StatelessWidget {
  const _PaymentStatusBadge({required this.status});

  final String? status;

  @override
  Widget build(BuildContext context) {
    final value = status?.trim();
    final normalized = value?.toLowerCase() ?? '';
    final color = switch (normalized) {
      'paid' || 'completed' || 'success' => Appcolor.success,
      'pending' => Appcolor.warning,
      'cancelled' || 'canceled' || 'failed' => Appcolor.error,
      _ => Appcolor.info,
    };
    final label = value == null || value.isEmpty
        ? 'notProvided'.tr
        : normalized.tr;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .13),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

String _display(String? value) {
  final text = value?.trim();
  return text == null || text.isEmpty ? 'notProvided'.tr : text;
}

String _dateTime(DateTime value) {
  return DateFormat.yMMMd(
    Get.locale?.languageCode,
  ).add_jm().format(value.toLocal());
}

String _amount(double value) {
  return NumberFormat('#,##0.00', Get.locale?.languageCode).format(value);
}

String _failureMessage(Failure failure, String fallbackKey) {
  return switch (failure.statusCode) {
    401 => 'sessionExpired'.tr,
    403 => 'patientAccessForbidden'.tr,
    404 => 'patientDetailsNotFound'.tr,
    _ => fallbackKey.tr,
  };
}

void _openAppointment(int appointmentId) {
  if (appointmentId <= 0 ||
      Get.currentRoute == Approutes.doctorAppointmentDetails) {
    return;
  }
  Get.toNamed(Approutes.doctorAppointmentDetails, arguments: appointmentId);
}
