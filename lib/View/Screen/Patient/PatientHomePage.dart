import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../Controller/Patient/HomeController.dart';
import '../../../Controller/Patient/PatientBookingController.dart';
import '../../../core/class/AuthService.dart';
import '../../../core/constant/Appcolor.dart';
import '../../../core/constant/Approutes.dart';
import '../../../data/datasource/remote/Home/HomeData.dart';
import '../../../data/model/AppointmentModel.dart';
import '../../../data/model/DoctorModel.dart';
import '../../../data/model/PatientHomeProfileModel.dart';
import '../../Widget/Custome/AppProfileImage.dart';
import '../Doctor/DoctorHomePage.dart';

class PatientHomePage extends StatelessWidget {
  const PatientHomePage({super.key});

  @override
  Widget build(BuildContext context) => GetBuilder<PatientHomeControllerImp>(
    builder: (controller) => Scaffold(
      backgroundColor: DoctorHomeColors.background(context),
      bottomNavigationBar: PatientBottomNavigation(
        currentIndex: controller.selectedTab,
        unreadCount: controller.unreadNotificationsCount,
        onTap: controller.selectTab,
      ),
      body: SafeArea(child: _body(context, controller)),
    ),
  );

  Widget _body(BuildContext context, PatientHomeControllerImp controller) {
    return switch (controller.selectedTab) {
      1 => PatientDoctorsView(controller: controller),
      2 => PatientAppointmentsView(controller: controller),
      3 => PatientProfileView(controller: controller),
      _ => PatientDashboardView(controller: controller),
    };
  }
}

class PatientDashboardView extends StatelessWidget {
  const PatientDashboardView({super.key, required this.controller});

  final PatientHomeControllerImp controller;

  @override
  Widget build(BuildContext context) {
    if (controller.isLoading && !controller.hasDashboardData) {
      return const Center(
        child: CircularProgressIndicator(color: Appcolor.gold),
      );
    }
    final layout = DoctorHomeLayout.of(context);
    final bottomPadding =
        DoctorHomeLayout.navigationHeight +
        MediaQuery.paddingOf(context).bottom +
        layout.sectionSpacing;
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: RefreshIndicator(
          color: Appcolor.gold,
          onRefresh: controller.refreshDashboard,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              layout.horizontalPadding,
              18,
              layout.horizontalPadding,
              bottomPadding,
            ),
            children: [
              PatientProfileHeader(
                patient: controller.patient,
                unreadCount: controller.unreadNotificationsCount,
                onNotifications: controller.showNotifications,
              ),
              const SizedBox(height: 20),
              PatientDoctorSearchField(controller: controller),
              const SizedBox(height: 22),
              PatientQuickActions(controller: controller),
              const SizedBox(height: 28),
              PatientUpcomingSection(controller: controller),
              const SizedBox(height: 28),
              PatientDoctorsSection(controller: controller),
              if (_hasHealthInformation(controller.patient)) ...[
                const SizedBox(height: 28),
                PatientHealthInformation(patient: controller.patient!),
              ],
              if (controller.isRefreshing) ...[
                const SizedBox(height: 18),
                const LinearProgressIndicator(color: Appcolor.gold),
              ],
            ],
          ),
        ),
      ),
    );
  }

  bool _hasHealthInformation(PatientHomeProfileModel? patient) =>
      patient != null &&
      (patient.bloodType != null ||
          patient.age != null ||
          patient.gender != null);
}

class PatientProfileHeader extends StatelessWidget {
  const PatientProfileHeader({
    super.key,
    required this.patient,
    required this.unreadCount,
    required this.onNotifications,
  });

  final PatientHomeProfileModel? patient;
  final int unreadCount;
  final VoidCallback onNotifications;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(18, 14, 18, 22),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Appcolor.secondary, Appcolor.accent],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(28),
      border: Border.all(color: Colors.white.withValues(alpha: .08)),
      boxShadow: [
        BoxShadow(
          color: Appcolor.accent.withValues(alpha: .28),
          blurRadius: 28,
          offset: const Offset(0, 14),
        ),
      ],
    ),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            HeaderAction(
              icon: Icons.notifications_none_rounded,
              onTap: onNotifications,
              badge: unreadCount > 0,
            ),
          ],
        ),
        Transform.translate(
          offset: const Offset(0, -8),
          child: PatientAvatar(patient: patient, diameter: 88),
        ),
        Text(
          _greeting(patient),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Appcolor.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'healthyDay'.tr,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Appcolor.textLight, fontSize: 14),
        ),
      ],
    ),
  );

  String _greeting(PatientHomeProfileModel? patient) {
    final name = patient?.firstName.trim() ?? '';
    return name.isEmpty
        ? 'helloPatient'.tr
        : 'helloPatientName'.trParams({'name': name});
  }
}

class PatientAvatar extends StatelessWidget {
  const PatientAvatar({super.key, required this.patient, this.diameter = 72});

  final PatientHomeProfileModel? patient;
  final double diameter;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      padding: const EdgeInsets.all(3),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: Appcolor.gradientColors),
      ),
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Appcolor.secondary,
        ),
        child: AppProfileImage(
          imagePath: patient?.imagePath,
          size: diameter - 12,
          backgroundColor: Appcolor.primary,
          loadingIndicatorColor: Appcolor.white,
          fallback: _PatientInitials(patient: patient),
        ),
      ),
    );
  }
}

class _PatientInitials extends StatelessWidget {
  const _PatientInitials({required this.patient});

  final PatientHomeProfileModel? patient;

  @override
  Widget build(BuildContext context) {
    final first = patient?.firstName.trim() ?? '';
    final last = patient?.lastName.trim() ?? '';
    final initials =
        '${first.isEmpty ? '' : first[0]}${last.isEmpty ? '' : last[0]}'
            .toUpperCase();
    return ColoredBox(
      color: Appcolor.primary,
      child: Center(
        child: initials.isEmpty
            ? const Icon(Icons.person_outline, color: Appcolor.white, size: 38)
            : Text(
                initials,
                style: const TextStyle(
                  color: Appcolor.white,
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}

class PatientDoctorSearchField extends StatelessWidget {
  const PatientDoctorSearchField({super.key, required this.controller});

  final PatientHomeControllerImp controller;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller.searchController,
    textInputAction: TextInputAction.search,
    onChanged: controller.updateSearch,
    onSubmitted: controller.submitSearch,
    decoration: InputDecoration(
      hintText: 'searchDoctorOrSpecialty'.tr,
      prefixIcon: const Icon(Icons.search_rounded),
      suffixIcon: controller.searchQuery.isEmpty
          ? null
          : IconButton(
              tooltip: 'clearSearch'.tr,
              onPressed: controller.clearSearch,
              icon: const Icon(Icons.close_rounded),
            ),
      filled: true,
      fillColor: DoctorHomeColors.surface(context),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: DoctorHomeColors.border(context)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: DoctorHomeColors.border(context)),
      ),
    ),
  );
}

class PatientQuickActions extends StatelessWidget {
  const PatientQuickActions({super.key, required this.controller});

  final PatientHomeControllerImp controller;

  @override
  Widget build(BuildContext context) {
    final actions = [
      (Icons.search_rounded, 'findDoctor', controller.findDoctor),
      (
        Icons.calendar_month_outlined,
        'myAppointments',
        controller.showAppointments,
      ),
      (
        Icons.folder_shared_outlined,
        'medicalRecords',
        () => controller.openResource(PatientResourceType.medicalRecords),
      ),
      (
        Icons.medication_outlined,
        'prescriptions',
        () => controller.openResource(PatientResourceType.prescriptions),
      ),
      (
        Icons.payments_outlined,
        'payments',
        () => controller.openResource(PatientResourceType.payments),
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title: 'quickActions'.tr),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 360;
            final columns = compact ? 2 : 3;
            const spacing = 12.0;
            final width =
                (constraints.maxWidth - spacing * (columns - 1)) / columns;
            return Wrap(
              spacing: spacing,
              runSpacing: 16,
              children: [
                for (final action in actions)
                  SizedBox(
                    width: width,
                    child: DoctorActionItem(
                      icon: action.$1,
                      label: action.$2.tr,
                      onTap: action.$3,
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class PatientUpcomingSection extends StatelessWidget {
  const PatientUpcomingSection({super.key, required this.controller});

  final PatientHomeControllerImp controller;

  @override
  Widget build(BuildContext context) {
    final appointment = controller.upcomingAppointment;
    return Column(
      children: [
        SectionTitle(
          title: 'yourUpcomingAppointment'.tr,
          onViewAll: controller.showAppointments,
        ),
        const SizedBox(height: 13),
        if (controller.appointmentsFailure != null &&
            controller.appointments.isEmpty)
          _SectionError(
            message: 'appointmentsLoadError'.tr,
            onRetry: controller.refreshDashboard,
          )
        else if (appointment == null)
          _UpcomingEmpty(onBook: controller.findDoctor)
        else
          PatientAppointmentCard(
            appointment: appointment,
            onTap: () =>
                showPatientAppointmentDetails(context, appointment, controller),
          ),
      ],
    );
  }
}

class _UpcomingEmpty extends StatelessWidget {
  const _UpcomingEmpty({required this.onBook});

  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) => SurfaceCard(
    child: Column(
      children: [
        const Icon(
          Icons.event_available_outlined,
          color: Appcolor.gold,
          size: 38,
        ),
        const SizedBox(height: 10),
        Text(
          'noUpcomingAppointment'.tr,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: DoctorHomeColors.text(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: onBook,
          icon: const Icon(Icons.add_rounded),
          label: Text('bookAppointment'.tr),
        ),
      ],
    ),
  );
}

class PatientDoctorsSection extends StatelessWidget {
  const PatientDoctorsSection({super.key, required this.controller});

  final PatientHomeControllerImp controller;

  @override
  Widget build(BuildContext context) {
    final items = controller.filteredDoctors.take(4).toList(growable: false);
    return Column(
      children: [
        SectionTitle(title: 'doctors'.tr, onViewAll: controller.findDoctor),
        const SizedBox(height: 13),
        if (controller.doctorsFailure != null && controller.doctors.isEmpty)
          _SectionError(
            message: 'doctorsLoadError'.tr,
            onRetry: controller.refreshDashboard,
          )
        else if (items.isEmpty)
          _PatientEmptyState(message: 'noDoctorsFound'.tr)
        else
          for (final doctor in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: PatientDoctorCard(
                doctor: doctor,
                onTap: () =>
                    showPatientDoctorDetails(context, doctor, controller),
              ),
            ),
      ],
    );
  }
}

class PatientDoctorCard extends StatelessWidget {
  const PatientDoctorCard({
    super.key,
    required this.doctor,
    required this.onTap,
  });

  final DoctorDetailsModel doctor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => SurfaceCard(
    child: Row(
      children: [
        _DoctorAvatar(doctor: doctor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _doctorName(doctor),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: DoctorHomeColors.text(context),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (doctor.specialization.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  doctor.specialization,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Appcolor.textLight),
                ),
              ],
              if (doctor.experienceYears != null) ...[
                const SizedBox(height: 5),
                Text(
                  '${doctor.experienceYears} ${'yearsExperience'.tr}',
                  style: const TextStyle(
                    color: Appcolor.textLight,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 8),
        TextButton(onPressed: onTap, child: Text('viewDetails'.tr)),
      ],
    ),
  );
}

class _DoctorAvatar extends StatelessWidget {
  const _DoctorAvatar({required this.doctor});

  final DoctorDetailsModel doctor;

  @override
  Widget build(BuildContext context) => AppProfileImage(
    imagePath: doctor.imagePath,
    size: 56,
    backgroundColor: Appcolor.primary,
    loadingIndicatorColor: Appcolor.white,
    fallback: const Icon(
      Icons.medical_services_outlined,
      color: Appcolor.white,
    ),
  );
}

class PatientAppointmentCard extends StatelessWidget {
  const PatientAppointmentCard({
    super.key,
    required this.appointment,
    required this.onTap,
  });

  final AppointmentModel appointment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        children: [
          Row(
            children: [
              AppProfileImage(
                imagePath: appointment.doctorImage,
                size: 54,
                backgroundColor: Appcolor.primary,
                loadingIndicatorColor: Appcolor.white,
                fallback: const Icon(
                  Icons.medical_services_outlined,
                  color: Appcolor.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _appointmentDoctorName(appointment),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: DoctorHomeColors.text(context),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (appointment.doctorSpecialization != null)
                      Text(
                        appointment.doctorSpecialization!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Appcolor.textLight),
                      ),
                  ],
                ),
              ),
              PatientStatusBadge(status: appointment.status),
            ],
          ),
          const SizedBox(height: 13),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 17,
                color: Appcolor.gold,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  DateFormat.yMMMd(
                    Get.locale?.languageCode,
                  ).add_jm().format(appointment.appointmentDate.toLocal()),
                  style: TextStyle(color: DoctorHomeColors.text(context)),
                ),
              ),
              TextButton(onPressed: onTap, child: Text('viewDetails'.tr)),
            ],
          ),
        ],
      ),
    );
  }
}

class PatientStatusBadge extends StatelessWidget {
  const PatientStatusBadge({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final normalized = status.trim().toLowerCase();
    final color = switch (normalized) {
      'completed' => Appcolor.success,
      'confirmed' => Appcolor.info,
      'cancelled' || 'canceled' => Appcolor.error,
      _ => Appcolor.warning,
    };
    final key = normalized == 'canceled' ? 'cancelled' : normalized;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .13),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        key.tr,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class PatientHealthInformation extends StatelessWidget {
  const PatientHealthInformation({super.key, required this.patient});

  final PatientHomeProfileModel patient;

  @override
  Widget build(BuildContext context) {
    final items = <(IconData, String, String)>[
      if (patient.bloodType != null)
        (Icons.bloodtype_outlined, 'bloodType'.tr, patient.bloodType!),
      if (patient.age != null)
        (Icons.cake_outlined, 'age'.tr, patient.age.toString()),
      if (patient.gender != null)
        (Icons.person_outline, 'gender'.tr, _gender(patient.gender)),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title: 'healthInformation'.tr),
        const SizedBox(height: 13),
        SurfaceCard(
          child: Wrap(
            spacing: 14,
            runSpacing: 12,
            children: [
              for (final item in items)
                ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 115),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(item.$1, color: Appcolor.gold, size: 20),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.$2,
                            style: const TextStyle(
                              color: Appcolor.textLight,
                              fontSize: 11,
                            ),
                          ),
                          Text(
                            item.$3,
                            style: TextStyle(
                              color: DoctorHomeColors.text(context),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  String _gender(Object? value) {
    final normalized = value?.toString().trim().toLowerCase();
    return switch (normalized) {
      '0' || 'male' => 'male'.tr,
      '1' || 'female' => 'female'.tr,
      _ => 'notProvided'.tr,
    };
  }
}

class PatientDoctorsView extends StatelessWidget {
  const PatientDoctorsView({super.key, required this.controller});

  final PatientHomeControllerImp controller;

  @override
  Widget build(BuildContext context) => _PatientTabFrame(
    title: 'doctors'.tr,
    child: Column(
      children: [
        PatientDoctorSearchField(controller: controller),
        const SizedBox(height: 16),
        Expanded(
          child: controller.doctorsFailure != null && controller.doctors.isEmpty
              ? DoctorEmptyState(
                  message: 'doctorsLoadError'.tr,
                  onRetry: controller.refreshDashboard,
                )
              : controller.filteredDoctors.isEmpty
              ? _PatientEmptyState(message: 'noDoctorsFound'.tr)
              : RefreshIndicator(
                  color: Appcolor.gold,
                  onRefresh: controller.refreshDashboard,
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: controller.filteredDoctors.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final doctor = controller.filteredDoctors[index];
                      return PatientDoctorCard(
                        doctor: doctor,
                        onTap: () => showPatientDoctorDetails(
                          context,
                          doctor,
                          controller,
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    ),
  );
}

class PatientAppointmentsView extends StatelessWidget {
  const PatientAppointmentsView({super.key, required this.controller});

  final PatientHomeControllerImp controller;

  @override
  Widget build(BuildContext context) {
    final items = [...controller.appointments]
      ..sort((a, b) => b.appointmentDate.compareTo(a.appointmentDate));
    return _PatientTabFrame(
      title: 'myAppointments'.tr,
      child: controller.appointmentsFailure != null && items.isEmpty
          ? DoctorEmptyState(
              message: 'appointmentsLoadError'.tr,
              onRetry: controller.refreshDashboard,
            )
          : items.isEmpty
          ? _PatientEmptyState(message: 'noAppointments'.tr)
          : RefreshIndicator(
              color: Appcolor.gold,
              onRefresh: controller.refreshDashboard,
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) => PatientAppointmentCard(
                  appointment: items[index],
                  onTap: () => showPatientAppointmentDetails(
                    context,
                    items[index],
                    controller,
                  ),
                ),
              ),
            ),
    );
  }
}

class PatientNotificationsView extends StatelessWidget {
  const PatientNotificationsView({super.key});

  @override
  Widget build(BuildContext context) => _PatientTabFrame(
    title: 'notifications'.tr,
    child: _PatientEmptyState(message: 'noNotifications'.tr),
  );
}

class PatientProfileView extends StatelessWidget {
  const PatientProfileView({super.key, required this.controller});

  final PatientHomeControllerImp controller;

  @override
  Widget build(BuildContext context) {
    final patient = controller.patient;
    return _PatientTabFrame(
      title: 'profile'.tr,
      child: patient == null
          ? DoctorEmptyState(
              message: 'patientProfileNotFound'.tr,
              onRetry: controller.refreshDashboard,
            )
          : ListView(
              children: [
                SurfaceCard(
                  child: Column(
                    children: [
                      PatientAvatar(patient: patient, diameter: 92),
                      const SizedBox(height: 12),
                      Text(
                        patient.fullName,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: DoctorHomeColors.text(context),
                          fontSize: 21,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (patient.email != null) ...[
                        const SizedBox(height: 5),
                        Text(
                          patient.email!,
                          style: const TextStyle(color: Appcolor.textLight),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (patient.bloodType != null ||
                    patient.age != null ||
                    patient.gender != null)
                  PatientHealthInformation(patient: patient),
                const SizedBox(height: 22),
                OutlinedButton.icon(
                  onPressed: () async {
                    await AuthService.clearTokens();
                    Get.offAllNamed(Approutes.login);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Appcolor.error,
                  ),
                  icon: const Icon(Icons.logout_rounded),
                  label: Text('logout'.tr),
                ),
              ],
            ),
    );
  }
}

class _PatientTabFrame extends StatelessWidget {
  const _PatientTabFrame({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final layout = DoctorHomeLayout.of(context);
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            layout.horizontalPadding,
            18,
            layout.horizontalPadding,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: DoctorHomeColors.text(context),
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 18),
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionError extends StatelessWidget {
  const _SectionError({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) => SurfaceCard(
    child: Row(
      children: [
        const Icon(Icons.cloud_off_rounded, color: Appcolor.error),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            message,
            style: TextStyle(color: DoctorHomeColors.text(context)),
          ),
        ),
        TextButton(onPressed: onRetry, child: Text('retry'.tr)),
      ],
    ),
  );
}

class _PatientEmptyState extends StatelessWidget {
  const _PatientEmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.inbox_outlined, size: 52, color: Appcolor.gold),
          const SizedBox(height: 14),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: DoctorHomeColors.text(context)),
          ),
        ],
      ),
    ),
  );
}

class PatientBottomNavigation extends StatelessWidget {
  const PatientBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.unreadCount,
    required this.onTap,
  });

  final int currentIndex;
  final int unreadCount;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) => NavigationBar(
    selectedIndex: currentIndex,
    onDestinationSelected: onTap,
    destinations: [
      NavigationDestination(
        icon: const Icon(Icons.home_outlined),
        selectedIcon: const Icon(Icons.home_rounded),
        label: 'home'.tr,
      ),
      NavigationDestination(
        icon: const Icon(Icons.medical_services_outlined),
        selectedIcon: const Icon(Icons.medical_services_rounded),
        label: 'doctors'.tr,
      ),
      NavigationDestination(
        icon: const Icon(Icons.calendar_month_outlined),
        selectedIcon: const Icon(Icons.calendar_month_rounded),
        label: 'appointments'.tr,
      ),
      /*  NavigationDestination(
        icon: Badge(
          isLabelVisible: unreadCount > 0,
          label: Text('$unreadCount'),
          child: const Icon(Icons.notifications_none_rounded),
        ),
        selectedIcon: Badge(
          isLabelVisible: unreadCount > 0,
          label: Text('$unreadCount'),
          child: const Icon(Icons.notifications_rounded),
        ),
        label: 'notifications'.tr,
      ), */
      NavigationDestination(
        icon: const Icon(Icons.person_outline_rounded),
        selectedIcon: const Icon(Icons.person_rounded),
        label: 'profile'.tr,
      ),
    ],
  );
}

Future<void> showPatientDoctorDetails(
  BuildContext context,
  DoctorDetailsModel doctor,
  PatientHomeControllerImp patientController,
) {
  final bookingController = PatientBookingController(
    Get.find<HomeData>(),
    doctorId: doctor.id,
  );
  return Get.bottomSheet<void>(
    GetBuilder<PatientBookingController>(
      init: bookingController,
      global: false,
      builder: (booking) => _PatientDoctorDetailsSheet(
        doctor: doctor,
        booking: booking,
        patientController: patientController,
      ),
    ),
    isScrollControlled: true,
  );
}

class _PatientDoctorDetailsSheet extends StatelessWidget {
  const _PatientDoctorDetailsSheet({
    required this.doctor,
    required this.booking,
    required this.patientController,
  });

  final DoctorDetailsModel doctor;
  final PatientBookingController booking;
  final PatientHomeControllerImp patientController;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Container(
      constraints: BoxConstraints(
        maxWidth: 720,
        maxHeight: MediaQuery.sizeOf(context).height * .9,
      ),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DoctorHomeColors.surface(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DoctorAvatar(doctor: doctor),
            const SizedBox(height: 12),
            Text(
              _doctorName(doctor),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: DoctorHomeColors.text(context),
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (doctor.specialization.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                doctor.specialization,
                style: const TextStyle(color: Appcolor.textLight),
              ),
            ],
            if (doctor.experienceYears != null) ...[
              const SizedBox(height: 8),
              Text(
                '${doctor.experienceYears} ${'yearsExperience'.tr}',
                style: TextStyle(color: DoctorHomeColors.text(context)),
              ),
            ],
            if (doctor.note?.trim().isNotEmpty == true) ...[
              const SizedBox(height: 14),
              Text(
                doctor.note!,
                textAlign: TextAlign.start,
                style: TextStyle(color: DoctorHomeColors.text(context)),
              ),
            ],
            const SizedBox(height: 20),
            Divider(color: DoctorHomeColors.border(context)),
            const SizedBox(height: 12),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                'availableAppointments'.tr,
                style: TextStyle(
                  color: DoctorHomeColors.text(context),
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: booking.isBooking
                    ? null
                    : () => _selectDate(context),
                icon: const Icon(Icons.calendar_month_outlined),
                label: Text(
                  DateFormat.yMMMMd(
                    Get.locale?.languageCode,
                  ).format(booking.selectedDate),
                ),
              ),
            ),
            const SizedBox(height: 14),
            if (booking.isLoadingSlots)
              const Padding(
                padding: EdgeInsets.all(14),
                child: CircularProgressIndicator(color: Appcolor.gold),
              )
            else if (booking.slotsFailure != null)
              _SectionError(
                message: 'availableAppointmentsLoadError'.tr,
                onRetry: booking.loadAvailableSlots,
              )
            else if (booking.availableSlots.isEmpty)
              _PatientEmptyState(message: 'noAvailableAppointments'.tr)
            else ...[
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  'selectAppointmentTime'.tr,
                  style: TextStyle(color: DoctorHomeColors.text(context)),
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final slot in booking.availableSlots)
                    ChoiceChip(
                      label: Text(
                        '${DateFormat.jm(Get.locale?.languageCode).format(slot.startTime)}'
                        ' - '
                        '${DateFormat.jm(Get.locale?.languageCode).format(slot.endTime)}',
                      ),
                      selected: identical(booking.selectedSlot, slot),
                      onSelected: (_) => booking.selectSlot(slot),
                    ),
                ],
              ),
            ],
            if (booking.bookingFailure != null) ...[
              const SizedBox(height: 12),
              Text(
                'requestFailed'.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Appcolor.error),
              ),
            ],
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: booking.selectedSlot == null || booking.isBooking
                    ? null
                    : _bookAppointment,
                icon: booking.isBooking
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Appcolor.white,
                        ),
                      )
                    : const Icon(Icons.event_available_outlined),
                label: Text('bookAppointment'.tr),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Future<void> _selectDate(BuildContext context) async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year, now.month, now.day);
    final selected = await showDatePicker(
      context: context,
      initialDate: booking.selectedDate,
      firstDate: firstDate,
      lastDate: DateTime(now.year + 1, now.month, now.day),
    );
    if (selected != null) await booking.selectDate(selected);
  }

  Future<void> _bookAppointment() async {
    final succeeded = await booking.bookSelectedSlot();
    if (!succeeded) return;
    await patientController.completePatientBooking();
    if (Get.isBottomSheetOpen == true) Get.back<void>();
    Get.snackbar('success'.tr, 'appointmentBooked'.tr);
  }
}

Future<void> showPatientAppointmentDetails(
  BuildContext context,
  AppointmentModel appointment,
  PatientHomeControllerImp controller,
) {
  return Get.bottomSheet<void>(
    GetBuilder<PatientHomeControllerImp>(
      init: controller,
      autoRemove: false,
      builder: (current) => SafeArea(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: DoctorHomeColors.surface(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppProfileImage(
                  imagePath: appointment.doctorImage,
                  size: 64,
                  backgroundColor: Appcolor.primary,
                  loadingIndicatorColor: Appcolor.white,
                  fallback: const Icon(
                    Icons.medical_services_outlined,
                    color: Appcolor.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'appointmentDetails'.tr,
                  style: TextStyle(
                    color: DoctorHomeColors.text(context),
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 18),
                _detailRow(context, 'appointmentId'.tr, '${appointment.id}'),
                _detailRow(
                  context,
                  'doctor'.tr,
                  _appointmentDoctorName(appointment),
                ),
                if (appointment.doctorSpecialization != null)
                  _detailRow(
                    context,
                    'specialization'.tr,
                    appointment.doctorSpecialization!,
                  ),
                _detailRow(
                  context,
                  'appointmentDate'.tr,
                  DateFormat.yMMMMd(
                    Get.locale?.languageCode,
                  ).format(appointment.appointmentDate.toLocal()),
                ),
                _detailRow(
                  context,
                  'appointmentTime'.tr,
                  DateFormat.jm(
                    Get.locale?.languageCode,
                  ).format(appointment.appointmentDate.toLocal()),
                ),
                _detailRow(
                  context,
                  'status'.tr,
                  (appointment.status.toLowerCase() == 'canceled'
                          ? 'cancelled'
                          : appointment.status.toLowerCase())
                      .tr,
                ),
                if (appointment.appointmentNotes?.trim().isNotEmpty == true)
                  _detailRow(
                    context,
                    'notes'.tr,
                    appointment.appointmentNotes!,
                  ),
                if (current.canCancelAppointment(appointment)) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed:
                          current.cancellingAppointments.contains(
                            appointment.id,
                          )
                          ? null
                          : () =>
                                _cancelPatientAppointment(current, appointment),
                      icon:
                          current.cancellingAppointments.contains(
                            appointment.id,
                          )
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.event_busy_outlined),
                      label: Text('cancelAppointment'.tr),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    ),
    isScrollControlled: true,
  );
}

Future<void> _cancelPatientAppointment(
  PatientHomeControllerImp controller,
  AppointmentModel appointment,
) async {
  final confirmed = await Get.dialog<bool>(
    AlertDialog(
      title: Text('cancelAppointment'.tr),
      content: Text('cancelAppointmentQuestion'.tr),
      actions: [
        TextButton(
          onPressed: () => Get.back(result: false),
          child: Text('cancel'.tr),
        ),
        FilledButton(
          onPressed: () => Get.back(result: true),
          child: Text('confirm'.tr),
        ),
      ],
    ),
  );
  if (confirmed != true) return;

  final succeeded = await controller.cancelAppointment(appointment);
  if (succeeded) {
    if (Get.isBottomSheetOpen == true) Get.back<void>();
    Get.snackbar('success'.tr, 'appointmentUpdated'.tr);
  } else {
    Get.snackbar('error'.tr, 'requestFailed'.tr);
  }
}

Widget _detailRow(BuildContext context, String label, String value) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 7),
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: Text(label, style: const TextStyle(color: Appcolor.textLight)),
      ),
      const SizedBox(width: 12),
      Expanded(
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

String _doctorName(DoctorDetailsModel doctor) {
  final name = doctor.fullName;
  return name.isEmpty ? 'doctor'.tr : '${'doctorTitle'.tr} $name';
}

String _appointmentDoctorName(AppointmentModel appointment) {
  final name = appointment.doctorName.trim();
  final lower = name.toLowerCase();
  if (lower.startsWith('dr.') ||
      lower.startsWith('dr ') ||
      name.startsWith('د.')) {
    return name;
  }
  return '${'doctorTitle'.tr} $name';
}
