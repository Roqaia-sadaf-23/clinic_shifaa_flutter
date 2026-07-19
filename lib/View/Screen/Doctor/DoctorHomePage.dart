import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../Controller/Doctor/DoctorHome_Controller.dart';
import '../../../core/constant/ApiLinks.dart';
import '../../../core/constant/Appcolor.dart';
import '../../../data/model/CurrentDoctorModel.dart';
import 'DoctorProfilePage.dart';

class DoctorHomePage extends StatelessWidget {
  const DoctorHomePage({super.key});

  @override
  Widget build(BuildContext context) => GetBuilder<DoctorHomeController>(
    builder: (controller) => Scaffold(
      backgroundColor: DoctorHomeColors.background(context),
      bottomNavigationBar: DoctorBottomNavigation(
        currentIndex: controller.selectedTab,
        onTap: controller.selectTab,
      ),
      body: SafeArea(child: _body(context, controller)),
    ),
  );

  Widget _body(BuildContext context, DoctorHomeController controller) {
    if (controller.selectedTab == 3) {
      return const DoctorProfileView();
    }
    if (controller.isLoading && controller.doctor == null) {
      return const DoctorHomeSkeleton();
    }
    if (controller.failure != null) {
      return DoctorEmptyState(
        message: controller.failure!.message,
        onRetry: controller.retry,
      );
    }
    final doctor = controller.doctor;
    if (doctor == null) {
      return DoctorEmptyState(
        message: 'doctorProfileNotFound'.tr,
        onRetry: controller.retry,
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
          onRefresh: controller.refreshCurrentDoctor,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              layout.horizontalPadding,
              18,
              layout.horizontalPadding,
              bottomPadding,
            ),
            children: [
              DoctorProfileHeader(
                doctor: doctor,
                onAction: controller.showComingSoon,
              ),
              const SizedBox(height: 20),
              DoctorActionGrid(onAction: controller.handleAction),
              const SizedBox(height: 28),
              const AppointmentSummaryRow(),
              const SizedBox(height: 28),
              TodayAppointmentsSection(
                onViewAll: () => controller.handleAction(0),
              ),
              const SizedBox(height: 24),
              AllAppointmentsPreview(
                onViewAll: () => controller.handleAction(0),
              ),
              if (doctor.note != null) ...[
                const SizedBox(height: 24),
                DoctorNote(note: doctor.note!),
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
}

class DoctorProfileHeader extends StatelessWidget {
  const DoctorProfileHeader({
    super.key,
    required this.doctor,
    required this.onAction,
  });
  final CurrentDoctorModel doctor;
  final VoidCallback onAction;

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
              onTap: onAction,
              badge: true,
            ),
            const SizedBox(width: 8),
            HeaderAction(icon: Icons.settings_outlined, onTap: onAction),
          ],
        ),
        Transform.translate(
          offset: const Offset(0, -8),
          child: DoctorAvatar(
            doctor: doctor,
            diameter: DoctorHomeLayout.of(context).compact ? 84 : 96,
          ),
        ),
        Text(
          greetingKey.tr,
          style: const TextStyle(color: Appcolor.textLight, fontSize: 14),
        ),
        const SizedBox(height: 4),
        Text(
          '${'doctorTitle'.tr} ${doctor.fullName}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Appcolor.white,
            fontSize: 23,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 7,
          children: [
            ProfilePill(
              icon: Icons.medical_services_outlined,
              label: doctor.specialization,
            ),
            ProfilePill(
              icon: Icons.workspace_premium_outlined,
              label: '${doctor.experienceYears} ${'yearsExperience'.tr}',
            ),
          ],
        ),
      ],
    ),
  );

  String get greetingKey {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'goodMorning';
    if (hour < 18) return 'goodAfternoon';
    return 'goodEvening';
  }
}

class DoctorAvatar extends StatelessWidget {
  const DoctorAvatar({super.key, required this.doctor, this.diameter = 96});
  final CurrentDoctorModel doctor;
  final double diameter;

  @override
  Widget build(BuildContext context) => Stack(
    clipBehavior: Clip.none,
    children: [
      Container(
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
          child: ClipOval(child: _image()),
        ),
      ),
      PositionedDirectional(
        end: 4,
        bottom: 4,
        child: Container(
          width: 17,
          height: 17,
          decoration: BoxDecoration(
            color: Appcolor.success,
            shape: BoxShape.circle,
            border: Border.all(color: Appcolor.secondary, width: 3),
          ),
        ),
      ),
    ],
  );

  Widget _image() {
    if (!doctor.hasImage) return InitialsAvatar(doctor: doctor);
    final path = doctor.imagePath!;
    final uri = Uri.tryParse(path);
    final url = uri != null && uri.hasScheme ? path : '${ApiLinks.images}$path';
    return Image.network(
      url,
      width: diameter - 12,
      height: diameter - 12,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => InitialsAvatar(doctor: doctor),
      loadingBuilder: (_, child, progress) => progress == null
          ? child
          : const ColoredBox(
              color: Appcolor.primary,
              child: Center(
                child: SizedBox.square(
                  dimension: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Appcolor.white,
                  ),
                ),
              ),
            ),
    );
  }
}

class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({super.key, required this.doctor});
  final CurrentDoctorModel doctor;

  @override
  Widget build(BuildContext context) {
    final first = doctor.firstName.trim();
    final last = doctor.lastName.trim();
    final value =
        '${first.isEmpty ? '' : first[0]}${last.isEmpty ? '' : last[0]}'
            .toUpperCase();
    return ColoredBox(
      color: Appcolor.primary,
      child: Center(
        child: Text(
          value.isEmpty ? 'DR' : value,
          style: const TextStyle(
            color: Appcolor.white,
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class HeaderAction extends StatelessWidget {
  const HeaderAction({
    super.key,
    required this.icon,
    required this.onTap,
    this.badge = false,
  });
  final IconData icon;
  final VoidCallback onTap;
  final bool badge;

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      Material(
        color: Colors.white.withValues(alpha: .09),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(9),
            child: Icon(icon, color: Appcolor.white, size: 21),
          ),
        ),
      ),
      if (badge)
        const PositionedDirectional(
          end: 2,
          top: 2,
          child: CircleAvatar(radius: 4, backgroundColor: Appcolor.gold),
        ),
    ],
  );
}

class ProfilePill extends StatelessWidget {
  const ProfilePill({super.key, required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    constraints: BoxConstraints(
      maxWidth: MediaQuery.sizeOf(context).width - 72,
    ),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .09),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Appcolor.textLight, size: 14),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Appcolor.white, fontSize: 12),
          ),
        ),
      ],
    ),
  );
}

class DoctorActionGrid extends StatelessWidget {
  const DoctorActionGrid({super.key, required this.onAction});
  final ValueChanged<int> onAction;

  @override
  Widget build(BuildContext context) {
    final actions = [
      (Icons.calendar_month_rounded, 'allAppointments'),
      (Icons.add_circle_outline_rounded, 'addAppointment'),
      (Icons.today_rounded, 'todayAppointments'),
      (Icons.people_alt_rounded, 'myPatients'),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final layout = DoctorHomeLayout.of(context);
        final columns = layout.compact || layout.largeText ? 2 : 4;
        final spacing = layout.itemSpacing;
        final itemWidth =
            (constraints.maxWidth - (spacing * (columns - 1))) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: 16,
          children: List.generate(actions.length, (index) {
            return SizedBox(
              width: itemWidth,
              child: DoctorActionItem(
                icon: actions[index].$1,
                label: actions[index].$2.tr,
                onTap: () => onAction(index),
              ),
            );
          }),
        );
      },
    );
  }
}

class DoctorActionItem extends StatelessWidget {
  const DoctorActionItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Material(
        color: DoctorHomeColors.surface(context),
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Container(
            height: 58,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: DoctorHomeColors.border(context)),
            ),
            child: Center(child: Icon(icon, color: Appcolor.gold, size: 26)),
          ),
        ),
      ),
      const SizedBox(height: 8),
      Text(
        label,
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: DoctorHomeColors.text(context),
          fontSize: 11,
          fontWeight: FontWeight.w600,
          height: 1.25,
        ),
      ),
    ],
  );
}

class AppointmentSummaryRow extends StatelessWidget {
  const AppointmentSummaryRow({super.key});

  @override
  Widget build(BuildContext context) {
    final cards = [
      (Icons.today_outlined, 'todayAppointments', Appcolor.info),
      (Icons.event_available_outlined, 'upcoming', Appcolor.accent),
      (Icons.task_alt_rounded, 'completed', Appcolor.success),
      (Icons.pending_actions_rounded, 'pending', Appcolor.warning),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title: 'appointmentSummary'.tr),
        const SizedBox(height: 13),
        LayoutBuilder(
          builder: (context, constraints) {
            final layout = DoctorHomeLayout.of(context);
            final columns = layout.compact || layout.largeText ? 1 : 2;
            final spacing = layout.itemSpacing;
            final cardWidth =
                (constraints.maxWidth - (spacing * (columns - 1))) / columns;
            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: List.generate(cards.length, (index) {
                return SizedBox(
                  width: cardWidth,
                  child: AppointmentSummaryCard(
                    icon: cards[index].$1,
                    label: cards[index].$2.tr,
                    color: cards[index].$3,
                  ),
                );
              }),
            );
          },
        ),
      ],
    );
  }
}

class AppointmentSummaryCard extends StatelessWidget {
  const AppointmentSummaryCard({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
  });
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => SurfaceCard(
    child: Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withValues(alpha: .13),
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
                '—',
                style: TextStyle(
                  color: DoctorHomeColors.text(context),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Appcolor.textLight,
                  fontSize: 12,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class TodayAppointmentsSection extends StatelessWidget {
  const TodayAppointmentsSection({super.key, required this.onViewAll});
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      SectionTitle(title: 'todayAppointments'.tr, onViewAll: onViewAll),
      const SizedBox(height: 13),
      NeutralAppointmentState(
        icon: Icons.event_busy_rounded,
        title: 'noAppointmentsToday'.tr,
      ),
    ],
  );
}

class AllAppointmentsPreview extends StatelessWidget {
  const AllAppointmentsPreview({super.key, required this.onViewAll});
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      SectionTitle(title: 'allAppointments'.tr, onViewAll: onViewAll),
      const SizedBox(height: 13),
      NeutralAppointmentState(
        icon: Icons.calendar_month_outlined,
        title: 'appointmentsNotConnected'.tr,
      ),
    ],
  );
}

class NeutralAppointmentState extends StatelessWidget {
  const NeutralAppointmentState({
    super.key,
    required this.icon,
    required this.title,
  });
  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) => SurfaceCard(
    child: Column(
      children: [
        Icon(icon, color: Appcolor.info, size: 28),
        const SizedBox(height: 10),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: DoctorHomeColors.text(context),
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'appointmentsUnavailable'.tr,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Appcolor.textLight,
            fontSize: 12,
            height: 1.35,
          ),
        ),
      ],
    ),
  );
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({super.key, required this.title, this.onViewAll});
  final String title;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          title,
          style: TextStyle(
            color: DoctorHomeColors.text(context),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      if (onViewAll != null)
        TextButton(
          onPressed: onViewAll,
          child: Text(
            'viewAll'.tr,
            style: const TextStyle(color: Appcolor.gold, fontSize: 12),
          ),
        ),
    ],
  );
}

class SurfaceCard extends StatelessWidget {
  const SurfaceCard({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: DoctorHomeColors.surface(context),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: DoctorHomeColors.border(context)),
    ),
    child: child,
  );
}

class DoctorNote extends StatelessWidget {
  const DoctorNote({super.key, required this.note});
  final String note;

  @override
  Widget build(BuildContext context) => SurfaceCard(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.notes_rounded, color: Appcolor.gold),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            note,
            style: TextStyle(
              color: DoctorHomeColors.text(context),
              height: 1.45,
            ),
          ),
        ),
      ],
    ),
  );
}

class DoctorBottomNavigation extends StatelessWidget {
  const DoctorBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) => NavigationBar(
    selectedIndex: currentIndex,
    onDestinationSelected: onTap,
    backgroundColor: DoctorHomeColors.surface(context),
    indicatorColor: Appcolor.accent.withValues(alpha: .16),
    destinations: [
      NavigationDestination(
        icon: const Icon(Icons.home_outlined),
        selectedIcon: const Icon(Icons.home_rounded),
        label: 'home'.tr,
      ),
      NavigationDestination(
        icon: const Icon(Icons.calendar_month_outlined),
        selectedIcon: const Icon(Icons.calendar_month_rounded),
        label: 'appointments'.tr,
      ),
      NavigationDestination(
        icon: const Icon(Icons.people_outline_rounded),
        selectedIcon: const Icon(Icons.people_alt_rounded),
        label: 'patients'.tr,
      ),
      NavigationDestination(
        icon: const Icon(Icons.person_outline_rounded),
        selectedIcon: const Icon(Icons.person_rounded),
        label: 'profile'.tr,
      ),
    ],
  );
}

class DoctorHomeSkeleton extends StatelessWidget {
  const DoctorHomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final layout = DoctorHomeLayout.of(context);
    final availableWidth =
        MediaQuery.sizeOf(context).width - (layout.horizontalPadding * 2);
    final itemWidth = layout.compact
        ? (availableWidth - layout.itemSpacing) / 2
        : (availableWidth - (layout.itemSpacing * 3)) / 4;
    return ListView(
      padding: EdgeInsets.fromLTRB(
        layout.horizontalPadding,
        20,
        layout.horizontalPadding,
        DoctorHomeLayout.navigationHeight +
            MediaQuery.paddingOf(context).bottom,
      ),
      children: [
        _box(context, 260),
        const SizedBox(height: 20),
        Wrap(
          spacing: layout.itemSpacing,
          runSpacing: layout.itemSpacing,
          children: List.generate(
            4,
            (_) => SizedBox(width: itemWidth, child: _box(context, 66)),
          ),
        ),
        const SizedBox(height: 28),
        _box(context, 86),
        const SizedBox(height: 14),
        _box(context, 132),
      ],
    );
  }

  Widget _box(BuildContext context, double height) => Container(
    height: height,
    decoration: BoxDecoration(
      color: DoctorHomeColors.surface(context),
      borderRadius: BorderRadius.circular(22),
    ),
  );
}

class DoctorEmptyState extends StatelessWidget {
  const DoctorEmptyState({
    super.key,
    required this.message,
    required this.onRetry,
  });
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_rounded, size: 54, color: Appcolor.gold),
          const SizedBox(height: 14),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: DoctorHomeColors.text(context)),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: Text('retry'.tr),
          ),
        ],
      ),
    ),
  );
}

abstract final class DoctorHomeColors {
  static Color background(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? Appcolor.cardBg
      : const Color(0xFFF6F7FB);
  static Color surface(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? Appcolor.secondary
      : Colors.white;
  static Color text(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? Appcolor.white
      : Appcolor.secondary;
  static Color border(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? Colors.white.withValues(alpha: .08)
      : Appcolor.primary.withValues(alpha: .08);
}

class DoctorHomeLayout {
  const DoctorHomeLayout({
    required this.compact,
    required this.largeText,
    required this.horizontalPadding,
    required this.itemSpacing,
    required this.sectionSpacing,
  });

  /// Material 3 navigation bars are 80 logical pixels tall.
  static const double navigationHeight = 80;

  final bool compact;
  final bool largeText;
  final double horizontalPadding;
  final double itemSpacing;
  final double sectionSpacing;

  factory DoctorHomeLayout.of(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final compact = width < 360;
    return DoctorHomeLayout(
      compact: compact,
      largeText: textScale >= 1.3,
      horizontalPadding: compact ? 14 : 20,
      itemSpacing: compact ? 8 : 10,
      sectionSpacing: compact ? 20 : 28,
    );
  }
}
