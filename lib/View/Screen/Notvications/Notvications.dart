import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../Controller/Notifications/ClinicNotificationsController.dart';
import '../../../core/constant/Appcolor.dart';
import '../../../data/model/ClinicNotification.dart';
import '../Doctor/DoctorHomePage.dart';

class Notvications extends StatelessWidget {
  const Notvications({super.key});

  @override
  Widget build(BuildContext context) =>
      GetBuilder<ClinicNotificationsController>(
        builder: (controller) => Scaffold(
          backgroundColor: DoctorHomeColors.background(context),
          appBar: AppBar(
            title: Text('notifications'.tr),
            actions: [
              if (controller.notifications.any((item) => item.isRead))
                IconButton(
                  tooltip: 'clearReadNotifications'.tr,
                  onPressed: controller.clearRead,
                  icon: const Icon(Icons.delete_sweep_outlined),
                ),
            ],
          ),
          body: SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: _body(context, controller),
              ),
            ),
          ),
        ),
      );

  Widget _body(BuildContext context, ClinicNotificationsController controller) {
    if (controller.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Appcolor.gold),
      );
    }
    final content = controller.notifications.isEmpty
        ? Center(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.notifications_none_rounded,
                    size: 64,
                    color: Appcolor.gold,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'noNotifications'.tr,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          )
        : ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
            itemCount: controller.notifications.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) => _NotificationCard(
              notification: controller.notifications[index],
              onTap: () =>
                  controller.openNotification(controller.notifications[index]),
            ),
          );

    if (controller.devicePermissionGranted != false) return content;
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Appcolor.gold.withValues(alpha: .1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Appcolor.gold.withValues(alpha: .35)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.notifications_off_outlined,
                color: Appcolor.gold,
              ),
              const SizedBox(width: 12),
              Expanded(child: Text('notificationPermissionDenied'.tr)),
              TextButton(
                onPressed: controller.isRequestingPermission
                    ? null
                    : controller.requestPermission,
                child: Text('enableNotifications'.tr),
              ),
            ],
          ),
        ),
        Expanded(child: content),
      ],
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.notification, required this.onTap});

  final ClinicNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final locale = Get.locale?.languageCode ?? 'en';
    final color = _color(notification.type);
    return Material(
      color: notification.isRead
          ? DoctorHomeColors.surface(context)
          : color.withValues(alpha: .09),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: notification.isRead
                  ? DoctorHomeColors.border(context)
                  : color.withValues(alpha: .32),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .14),
                  shape: BoxShape.circle,
                ),
                child: Icon(_icon(notification.type), color: color),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.titleKey.trParams(
                              notification.parameters,
                            ),
                            style: TextStyle(
                              color: DoctorHomeColors.text(context),
                              fontSize: 16,
                              fontWeight: notification.isRead
                                  ? FontWeight.w600
                                  : FontWeight.w800,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notification.bodyKey.trParams(notification.parameters),
                      style: TextStyle(
                        height: 1.45,
                        color: DoctorHomeColors.mutedText(context),
                      ),
                    ),
                    const SizedBox(height: 9),
                    Text(
                      _formatTimestamp(notification.createdAt, locale),
                      style: TextStyle(
                        color: DoctorHomeColors.mutedText(context),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static IconData _icon(ClinicNotificationType type) => switch (type) {
    ClinicNotificationType.appointmentCreated ||
    ClinicNotificationType.newAppointmentForDoctor =>
      Icons.event_available_rounded,
    ClinicNotificationType.appointmentConfirmed => Icons.verified_rounded,
    ClinicNotificationType.appointmentCancelled => Icons.event_busy_rounded,
    ClinicNotificationType.appointmentReminder => Icons.alarm_rounded,
    ClinicNotificationType.paymentCompleted => Icons.payments_rounded,
    ClinicNotificationType.medicalRecordCreated =>
      Icons.medical_information_rounded,
    ClinicNotificationType.prescriptionCreated => Icons.medication_rounded,
  };

  static Color _color(ClinicNotificationType type) => switch (type) {
    ClinicNotificationType.appointmentCancelled => Colors.redAccent,
    ClinicNotificationType.appointmentConfirmed ||
    ClinicNotificationType.paymentCompleted => Colors.green,
    ClinicNotificationType.medicalRecordCreated ||
    ClinicNotificationType.prescriptionCreated => Colors.teal,
    ClinicNotificationType.appointmentCreated ||
    ClinicNotificationType.appointmentReminder ||
    ClinicNotificationType.newAppointmentForDoctor => Appcolor.gold,
  };

  static String _formatTimestamp(DateTime value, String locale) {
    final local = value.toLocal();
    try {
      return DateFormat.yMMMd(locale).add_jm().format(local);
    } catch (_) {
      return '${local.year}-${local.month.toString().padLeft(2, '0')}-'
          '${local.day.toString().padLeft(2, '0')} '
          '${local.hour.toString().padLeft(2, '0')}:'
          '${local.minute.toString().padLeft(2, '0')}';
    }
  }
}
