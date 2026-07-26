import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../Controller/Doctor/DoctorAppointmentsController.dart';
import '../../../core/constant/Appcolor.dart';
import '../../../core/constant/Approutes.dart';
import '../../../data/model/AppointmentModel.dart';
import 'DoctorHomePage.dart';

class DoctorAppointmentsPage extends StatelessWidget {
  const DoctorAppointmentsPage({super.key});

  @override
  Widget build(BuildContext context) =>
      GetBuilder<DoctorAppointmentsController>(
        autoRemove: false,
        builder: (controller) {
          return Column(
            children: [
              _Filters(controller: controller),
              Expanded(child: _content(context, controller)),
            ],
          );
        },
      );

  Widget _content(
    BuildContext context,
    DoctorAppointmentsController controller,
  ) {
    if (controller.isInitialLoading && controller.appointments.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (controller.failure != null && controller.appointments.isEmpty) {
      return DoctorEmptyState(
        message: 'appointmentsLoadError'.tr,
        onRetry: controller.retry,
      );
    }
    if (controller.appointments.isEmpty) {
      return RefreshIndicator(
        onRefresh: controller.refreshList,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.sizeOf(context).height * .2),
            const Icon(
              Icons.event_busy_rounded,
              size: 54,
              color: Appcolor.info,
            ),
            const SizedBox(height: 12),
            Center(child: Text('noAppointments'.tr)),
          ],
        ),
      );
    }
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.extentAfter < 240) controller.loadMore();
        return false;
      },
      child: RefreshIndicator(
        onRefresh: controller.refreshList,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
          itemCount:
              controller.appointments.length +
              (controller.isLoadingMore ? 1 : 0),
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            if (index == controller.appointments.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            return DoctorAppointmentCard(
              appointment: controller.appointments[index],
              onTap: () {
                if (Get.currentRoute == Approutes.doctorAppointmentDetails) {
                  return;
                }
                Get.toNamed(
                  Approutes.doctorAppointmentDetails,
                  arguments: controller.appointments[index].id,
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _Filters extends StatelessWidget {
  const _Filters({required this.controller});
  final DoctorAppointmentsController controller;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
    child: Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        DropdownButton<String?>(
          value: controller.selectedStatus,
          hint: Text('statusFilter'.tr),
          items: [
            DropdownMenuItem(value: null, child: Text('allStatuses'.tr)),
            ...DoctorAppointmentsController.statuses.map(
              (value) => DropdownMenuItem(
                value: value,
                child: Text(value.toLowerCase().tr),
              ),
            ),
          ],
          onChanged: controller.isBusy ? null : controller.setStatus,
        ),
        OutlinedButton.icon(
          icon: const Icon(Icons.calendar_today_outlined, size: 18),
          label: Text(
            controller.selectedDate == null
                ? 'dateFilter'.tr
                : DateFormat.yMd(
                    Get.locale?.languageCode,
                  ).format(controller.selectedDate!),
          ),
          onPressed: controller.isBusy
              ? null
              : () async {
                  final selected = await showDatePicker(
                    context: context,
                    initialDate: controller.selectedDate ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (selected != null) await controller.setDate(selected);
                },
        ),
        if (controller.selectedStatus != null ||
            controller.selectedDate != null)
          TextButton(
            onPressed: controller.isBusy ? null : controller.clearFilters,
            child: Text('clearFilters'.tr),
          ),
      ],
    ),
  );
}

class DoctorAppointmentCard extends StatelessWidget {
  const DoctorAppointmentCard({
    super.key,
    required this.appointment,
    this.onTap,
  });
  final AppointmentModel appointment;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final status = appointment.status.toLowerCase();
    final color = switch (status) {
      'completed' => Appcolor.success,
      'cancelled' => Appcolor.error,
      'confirmed' => Appcolor.info,
      _ => Appcolor.warning,
    };
    return Card(
      color: DoctorHomeColors.surface(context),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: .14),
          child: Icon(Icons.calendar_month_rounded, color: color),
        ),
        title: Text(
          DateFormat.yMMMd(
            Get.locale?.languageCode,
          ).add_jm().format(appointment.appointmentDate.toLocal()),
        ),
        subtitle: Text('${'patientId'.tr}: ${appointment.patientId}'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: color.withValues(alpha: .13),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(status.tr, style: TextStyle(color: color, fontSize: 12)),
        ),
      ),
    );
  }
}
