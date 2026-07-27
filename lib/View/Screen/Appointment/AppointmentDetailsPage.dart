import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../Controller/Doctor/DoctorAppointmentDetailsController.dart';
import '../../../core/constant/Appcolor.dart';
import '../Doctor/DoctorHomePage.dart';

class AppointmentDetailsPage extends StatelessWidget {
  const AppointmentDetailsPage({super.key});

  @override
  Widget build(BuildContext context) =>
      GetBuilder<DoctorAppointmentDetailsController>(
        builder: (controller) => Scaffold(
          backgroundColor: DoctorHomeColors.background(context),
          appBar: AppBar(title: Text('appointmentDetails'.tr)),
          body: _body(context, controller),
        ),
      );

  Widget _body(
    BuildContext context,
    DoctorAppointmentDetailsController controller,
  ) {
    if (controller.isLoading && controller.appointment == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (controller.failure != null && controller.appointment == null) {
      return DoctorEmptyState(
        message: 'appointmentLoadError'.tr,
        onRetry: controller.load,
      );
    }
    final item = controller.appointment;
    if (item == null) {
      return DoctorEmptyState(
        message: 'appointmentNotFound'.tr,
        onRetry: controller.load,
      );
    }
    final busy = controller.isBusy;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SurfaceCard(
          child: Column(
            children: [
              _row('patient'.tr, item.patientName),
              _row('doctor'.tr, _doctorDisplayName(item.doctorName)),
              _row(
                'appointmentDate'.tr,
                DateFormat.yMMMMd(
                  Get.locale?.languageCode,
                ).format(item.appointmentDate.toLocal()),
              ),
              _row(
                'appointmentTime'.tr,
                DateFormat.jm(
                  Get.locale?.languageCode,
                ).format(item.appointmentDate.toLocal()),
              ),
              _row('status'.tr, item.status.toLowerCase().tr),
              if (item.lastStatusDate != null)
                _row(
                  'lastStatusDate'.tr,
                  DateFormat.yMMMMd(
                    Get.locale?.languageCode,
                  ).add_jm().format(item.lastStatusDate!.toLocal()),
                ),
              //  if (item.notes != null) _row('notes'.tr, item.notes!),
            ],
          ),
        ),
        const SizedBox(height: 18),
        if (controller.canComplete)
          FilledButton.icon(
            onPressed: busy ? null : () => controller.complete(context),
            icon: controller.isCompleting
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.task_alt_rounded),
            label: Text('completeAppointment'.tr),
          ),
        if (controller.canCancel) ...[
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: busy ? null : () => controller.cancel(context),
            style: OutlinedButton.styleFrom(foregroundColor: Appcolor.error),
            icon: controller.isCancelling
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.cancel_outlined),
            label: Text('cancelAppointment'.tr),
          ),
        ],
      ],
    );
  }

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(label, style: const TextStyle(color: Appcolor.grey)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );

  String _doctorDisplayName(String value) {
    final name = value.trim();
    final lowerName = name.toLowerCase();
    if (lowerName.startsWith('dr.') ||
        lowerName.startsWith('dr ') ||
        name.startsWith('د.')) {
      return name;
    }
    return '${'doctorTitle'.tr} $name';
  }
}
