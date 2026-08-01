import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../Controller/Doctor/DoctorAppointmentsController.dart';
import '../../../core/constant/Appcolor.dart';
import '../../../core/constant/Approutes.dart';
import '../../../core/helpers/image_path_helper.dart';
import '../../../data/model/DoctorAppointmentModel.dart';
import '../../Widget/Custome/AppProfileImage.dart';
import 'DoctorHomePage.dart';

class DoctorAppointmentsPage extends StatefulWidget {
  const DoctorAppointmentsPage({super.key});

  @override
  State<DoctorAppointmentsPage> createState() => _DoctorAppointmentsPageState();
}

class _DoctorAppointmentsPageState extends State<DoctorAppointmentsPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DoctorAppointmentsController>(
      autoRemove: false,
      builder: (controller) {
        final appointments = _search(controller.appointments);
        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification.metrics.extentAfter < 280) {
                  controller.loadMore();
                }
                return false;
              },
              child: RefreshIndicator(
                color: Appcolor.primary,
                onRefresh: controller.refreshList,
                child: CustomScrollView(
                  key: const PageStorageKey('doctor-appointments-list'),
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                      sliver: SliverToBoxAdapter(
                        child: AppointmentsHeader(controller: controller),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                      sliver: SliverToBoxAdapter(
                        child: AppointmentsFilters(controller: controller),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                      sliver: SliverToBoxAdapter(
                        child: AppointmentSearchField(
                          controller: _searchController,
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ),
                    if (controller.isInitialLoading)
                      const AppointmentSkeletonList()
                    else if (controller.hasError)
                      SliverToBoxAdapter(
                        child: AppointmentStatePanel.error(
                          onAction: controller.retry,
                          subtitle: controller.errorMessage,
                        ),
                      )
                    else if (appointments.isEmpty)
                      SliverToBoxAdapter(
                        child: AppointmentStatePanel.empty(
                          onAction: controller.refreshList,
                        ),
                      )
                    else
                      AppointmentCardsSliver(
                        appointments: appointments,
                        isLoadingMore: controller.isLoadingMore,
                        onAppointmentTap: _openDetails,
                        controller: controller,
                      ),
                    const SliverToBoxAdapter(child: SizedBox(height: 32)),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<DoctorAppointmentModel> _search(
    List<DoctorAppointmentModel> appointments,
  ) {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return appointments;
    return appointments
        .where(
          (appointment) =>
              appointment.patientName.toLowerCase().contains(query) ||
              appointment.id.toString().contains(query),
        )
        .toList(growable: false);
  }

  void _openDetails(DoctorAppointmentModel appointment) {
    if (Get.currentRoute == Approutes.doctorAppointmentDetails) return;
    Get.toNamed(Approutes.doctorAppointmentDetails, arguments: appointment.id);
  }
}

class AppointmentsHeader extends StatelessWidget {
  const AppointmentsHeader({super.key, required this.controller});

  final DoctorAppointmentsController controller;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayCount = controller.appointments
        .where((item) => _isSameDay(item.appointmentDate.toLocal(), today))
        .length;
    final total = controller.totalCount;
    final showPlaceholder =
        controller.isInitialLoading && controller.appointments.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Appcolor.primary.withValues(alpha: .1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.calendar_month_rounded,
                color: Appcolor.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'appointments'.tr,
                style: TextStyle(
                  color: DoctorHomeColors.text(context),
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: AppointmentMetricCard(
                icon: Icons.event_note_rounded,
                label: 'totalAppointments'.tr,
                value: showPlaceholder ? '—' : '$total',
                color: Appcolor.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppointmentMetricCard(
                icon: Icons.today_rounded,
                label: 'todayAppointments'.tr,
                value: showPlaceholder ? '—' : '$todayCount',
                color: Appcolor.info,
              ),
            ),
          ],
        ),
      ],
    );
  }

  bool _isSameDay(DateTime first, DateTime second) =>
      first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;
}

class AppointmentMetricCard extends StatelessWidget {
  const AppointmentMetricCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 94),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: DoctorHomeColors.surface(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: DoctorHomeColors.border(context)),
        boxShadow: Theme.of(context).brightness == Brightness.light
            ? [
                BoxShadow(
                  color: Appcolor.primary.withValues(alpha: .06),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: DoctorHomeColors.text(context),
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: DoctorHomeColors.mutedText(context),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AppointmentsFilters extends StatelessWidget {
  const AppointmentsFilters({super.key, required this.controller});

  final DoctorAppointmentsController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'filterAppointments'.tr,
          style: TextStyle(
            color: DoctorHomeColors.text(context),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              AppointmentStatusChip(
                label: 'all'.tr,
                selected: controller.selectedStatus == null,
                enabled: !controller.isBusy,
                onTap: () => controller.setStatus(null),
              ),
              ...DoctorAppointmentsController.statuses.map(
                (status) => Padding(
                  padding: const EdgeInsetsDirectional.only(start: 8),
                  child: AppointmentStatusChip(
                    label: status.toLowerCase().tr,
                    selected: controller.selectedStatus == status,
                    enabled: !controller.isBusy,
                    onTap: () => controller.setStatus(status),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            AppointmentDateButton(controller: controller),
            if (controller.selectedDate != null)
              IconButton.outlined(
                onPressed: controller.isBusy
                    ? null
                    : () => controller.setDate(null),
                tooltip: 'clearDate'.tr,
                icon: const Icon(Icons.close_rounded, size: 20),
              ),
            if (controller.selectedStatus != null ||
                controller.selectedDate != null)
              TextButton.icon(
                onPressed: controller.isBusy ? null : controller.clearFilters,
                icon: const Icon(Icons.filter_alt_off_rounded, size: 18),
                label: Text('clearFilters'.tr),
              ),
          ],
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: controller.isBusy && controller.appointments.isNotEmpty
              ? const Padding(
                  key: ValueKey('appointments-progress'),
                  padding: EdgeInsets.only(top: 12),
                  child: LinearProgressIndicator(
                    minHeight: 3,
                    color: Appcolor.primary,
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  ),
                )
              : const SizedBox.shrink(key: ValueKey('appointments-idle')),
        ),
      ],
    );
  }
}

class AppointmentStatusChip extends StatelessWidget {
  const AppointmentStatusChip({
    super.key,
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final unselectedColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white.withValues(alpha: .08)
        : const Color(0xFFF0F3F7);
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: enabled ? 1 : .55,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(30),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: selected ? Appcolor.primary : unselectedColor,
              borderRadius: BorderRadius.circular(30),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: Appcolor.primary.withValues(alpha: .22),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ]
                  : null,
            ),
            child: Text(
              label,
              style: TextStyle(
                color: selected
                    ? Colors.white
                    : DoctorHomeColors.mutedText(context),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AppointmentDateButton extends StatelessWidget {
  const AppointmentDateButton({super.key, required this.controller});

  final DoctorAppointmentsController controller;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: controller.isBusy ? null : () => _selectDate(context),
      style: OutlinedButton.styleFrom(
        foregroundColor: Appcolor.primary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        side: BorderSide(
          color: controller.selectedDate == null
              ? DoctorHomeColors.strongBorder(context)
              : Appcolor.primary,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      icon: const Icon(Icons.calendar_today_outlined, size: 18),
      label: Text(
        controller.selectedDate == null
            ? 'selectDate'.tr
            : DateFormat.yMMMd(
                Get.locale?.languageCode,
              ).format(controller.selectedDate!),
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: controller.selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(
            context,
          ).colorScheme.copyWith(primary: Appcolor.primary),
        ),
        child: child!,
      ),
    );
    if (selected != null) await controller.setDate(selected);
  }
}

class AppointmentSearchField extends StatelessWidget {
  const AppointmentSearchField({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'searchAppointments'.tr,
        hintStyle: TextStyle(color: DoctorHomeColors.mutedText(context)),
        prefixIcon: const Icon(Icons.search_rounded, color: Appcolor.primary),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
                tooltip: 'clearSearch'.tr,
                icon: const Icon(Icons.close_rounded),
              ),
        filled: true,
        fillColor: DoctorHomeColors.surface(context),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: DoctorHomeColors.border(context)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Appcolor.primary, width: 1.5),
        ),
      ),
    );
  }
}

class AppointmentCardsSliver extends StatelessWidget {
  const AppointmentCardsSliver({
    super.key,
    required this.appointments,
    required this.isLoadingMore,
    required this.onAppointmentTap,
    required this.controller,
  });

  final List<DoctorAppointmentModel> appointments;
  final bool isLoadingMore;
  final ValueChanged<DoctorAppointmentModel> onAppointmentTap;
  final DoctorAppointmentsController controller;

  @override
  Widget build(BuildContext context) {
    final itemCount = appointments.length + (isLoadingMore ? 1 : 0);
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, rawIndex) {
          if (rawIndex.isOdd) return const SizedBox(height: 12);
          final index = rawIndex ~/ 2;
          if (index == appointments.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(color: Appcolor.primary),
              ),
            );
          }
          final appointment = appointments[index];
          return DoctorAppointmentCard(
                key: ValueKey(appointment.id),
                appointment: appointment,
                onTap: () => onAppointmentTap(appointment),
                additionalAction: controller.canCreateMedicalRecord(appointment)
                    ? OutlinedButton.icon(
                        onPressed: controller.isOpeningCreateMedicalRecord
                            ? null
                            : () => controller.openCreateMedicalRecord(
                                appointment,
                              ),
                        icon: const Icon(Icons.note_add_outlined, size: 18),
                        label: Text('createMedicalRecord'.tr),
                      )
                    : null,
              )
              .animate(delay: Duration(milliseconds: math.min(index * 55, 275)))
              .fadeIn(
                duration: const Duration(milliseconds: 360),
                curve: Curves.easeOut,
              )
              .slideY(
                begin: .07,
                end: 0,
                duration: const Duration(milliseconds: 420),
                curve: Curves.easeOutCubic,
              );
        }, childCount: math.max(0, itemCount * 2 - 1)),
      ),
    );
  }
}

class DoctorAppointmentCard extends StatelessWidget {
  const DoctorAppointmentCard({
    super.key,
    required this.appointment,
    this.onTap,
    this.additionalAction,
  });

  final AppointmentDisplayData appointment;
  final VoidCallback? onTap;
  final Widget? additionalAction;

  @override
  Widget build(BuildContext context) {
    final localDate = appointment.appointmentDate.toLocal();
    final status = appointment.status.toLowerCase();

    return Material(
      color: DoctorHomeColors.surface(context),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: DoctorHomeColors.border(context)),
            boxShadow: Theme.of(context).brightness == Brightness.light
                ? [
                    BoxShadow(
                      color: Appcolor.primary.withValues(alpha: .07),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PatientAvatar(imagePath: appointment.patientImage),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${'patient'.tr}: ${appointment.patientName}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: DoctorHomeColors.text(context),
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '#${appointment.id}',
                          style: TextStyle(
                            color: DoctorHomeColors.mutedText(context),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  AppointmentStatusBadge(status: status),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 10,
                children: [
                  AppointmentInfoPill(
                    icon: Icons.calendar_today_outlined,
                    value: DateFormat.yMMMd(
                      Get.locale?.languageCode,
                    ).format(localDate),
                  ),
                  AppointmentInfoPill(
                    icon: Icons.access_time_rounded,
                    value: DateFormat.jm(
                      Get.locale?.languageCode,
                    ).format(localDate),
                  ),
                ],
              ),
              if (appointment.notes != null) ...[
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.notes_rounded,
                      size: 17,
                      color: DoctorHomeColors.mutedText(context),
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        appointment.notes!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: DoctorHomeColors.mutedText(context),
                          fontSize: 13,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              Divider(height: 1, color: DoctorHomeColors.border(context)),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  final stacked =
                      constraints.maxWidth < 300 ||
                      MediaQuery.textScalerOf(context).scale(1) >= 1.3;
                  final details = FilledButton.icon(
                    onPressed: onTap,
                    style: FilledButton.styleFrom(
                      backgroundColor: Appcolor.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.visibility_outlined, size: 18),
                    label: Text('viewDetails'.tr),
                  );
                  final call = OutlinedButton.icon(
                    onPressed: null,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.call_outlined, size: 18),
                    label: Text('call'.tr),
                  );
                  if (stacked) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [details, const SizedBox(height: 8), call],
                    );
                  }
                  return Row(
                    children: [
                      Expanded(child: details),
                      const SizedBox(width: 10),
                      Expanded(child: call),
                    ],
                  );
                },
              ),
              if (additionalAction != null) ...[
                const SizedBox(height: 8),
                SizedBox(width: double.infinity, child: additionalAction),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class PatientAvatar extends StatelessWidget {
  const PatientAvatar({super.key, this.imagePath});

  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Appcolor.primary.withValues(alpha: .11),
        shape: BoxShape.circle,
        border: Border.all(color: Appcolor.primary.withValues(alpha: .12)),
      ),
      alignment: Alignment.center,
      clipBehavior: Clip.antiAlias,
      child: AppProfileImage(
        imagePath: imagePath,
        size: 50,
        loadingIndicatorColor: Appcolor.primary,
        fallback: const Icon(
          Icons.person_rounded,
          color: Appcolor.primary,
          size: 26,
        ),
      ),
    );
  }
}

String? doctorPatientImageUrl(String? imagePath) {
  return imageUrlForPath(imagePath);
}

class AppointmentStatusBadge extends StatelessWidget {
  const AppointmentStatusBadge({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = appointmentStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        status.tr,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class AppointmentInfoPill extends StatelessWidget {
  const AppointmentInfoPill({
    super.key,
    required this.icon,
    required this.value,
  });

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 17, color: Appcolor.primary),
        const SizedBox(width: 7),
        Text(
          value,
          style: TextStyle(
            color: DoctorHomeColors.mutedText(context),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

Color appointmentStatusColor(String status) {
  return switch (status.toLowerCase()) {
    'confirmed' => Appcolor.info,
    'completed' => Appcolor.success,
    'cancelled' || 'canceled' => Appcolor.error,
    _ => Appcolor.warning,
  };
}

class AppointmentStatePanel extends StatelessWidget {
  const AppointmentStatePanel._({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
  });

  factory AppointmentStatePanel.empty({required VoidCallback onAction}) {
    return AppointmentStatePanel._(
      icon: Icons.event_available_rounded,
      iconColor: Appcolor.info,
      title: 'noAppointmentsTitle'.tr,
      subtitle: 'noAppointmentsSubtitle'.tr,
      actionLabel: 'refresh'.tr,
      onAction: onAction,
    );
  }

  factory AppointmentStatePanel.error({
    required VoidCallback onAction,
    required String subtitle,
  }) {
    return AppointmentStatePanel._(
      icon: Icons.medical_services_outlined,
      iconColor: Appcolor.error,
      title: 'appointmentsErrorTitle'.tr,
      subtitle: subtitle,
      actionLabel: 'retry'.tr,
      onAction: onAction,
    );
  }

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 28, 28, 64),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 104,
              height: 104,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: .09),
                shape: BoxShape.circle,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(icon, size: 52, color: iconColor),
                  PositionedDirectional(
                    end: 22,
                    bottom: 22,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: DoctorHomeColors.surface(context),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        size: 14,
                        color: Appcolor.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: DoctorHomeColors.text(context),
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: DoctorHomeColors.mutedText(context),
                  fontSize: 14,
                  height: 1.45,
                ),
              ),
            ),
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: onAction,
              style: FilledButton.styleFrom(
                backgroundColor: Appcolor.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(180, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class AppointmentSkeletonList extends StatelessWidget {
  const AppointmentSkeletonList({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: const AppointmentSkeletonCard()
                .animate(onPlay: (controller) => controller.repeat())
                .shimmer(
                  duration: const Duration(milliseconds: 1400),
                  color: Colors.white.withValues(alpha: .38),
                ),
          ),
          childCount: 5,
        ),
      ),
    );
  }
}

class AppointmentSkeletonCard extends StatelessWidget {
  const AppointmentSkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).brightness == Brightness.dark
        ? Colors.white.withValues(alpha: .08)
        : const Color(0xFFE9EDF3);
    return Container(
      height: 208,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DoctorHomeColors.surface(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: DoctorHomeColors.border(context)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _SkeletonBox(color: base, width: 50, height: 50, circular: true),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SkeletonBox(color: base, width: 150, height: 14),
                    const SizedBox(height: 9),
                    _SkeletonBox(color: base, width: 70, height: 10),
                  ],
                ),
              ),
              _SkeletonBox(color: base, width: 70, height: 26),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              _SkeletonBox(color: base, width: 118, height: 14),
              const SizedBox(width: 18),
              _SkeletonBox(color: base, width: 72, height: 14),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(child: _SkeletonBox(color: base, height: 44)),
              const SizedBox(width: 10),
              Expanded(child: _SkeletonBox(color: base, height: 44)),
            ],
          ),
        ],
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({
    required this.color,
    this.width,
    required this.height,
    this.circular = false,
  });

  final Color color;
  final double? width;
  final double height;
  final bool circular;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        shape: circular ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circular ? null : BorderRadius.circular(10),
      ),
    );
  }
}
