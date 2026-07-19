import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../Controller/Doctor/DoctorProfileController.dart';
import '../../../core/constant/ApiLinks.dart';
import '../../../core/constant/Appcolor.dart';
import '../../../data/model/CurrentDoctorModel.dart';

class DoctorProfileView extends StatelessWidget {
  const DoctorProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DoctorProfileController>(
      builder: (controller) {
        if (controller.isLoading && controller.doctor == null) {
          return const DoctorProfileSkeleton();
        }
        final doctor = controller.doctor;
        if (doctor == null) {
          return DoctorProfileErrorState(
            message: controller.failure?.message ?? 'doctorProfileNotFound'.tr,
            onRetry: controller.retry,
          );
        }
        return _ProfileContent(controller: controller, doctor: doctor);
      },
    );
  }
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent({required this.controller, required this.doctor});

  final DoctorProfileController controller;
  final CurrentDoctorModel doctor;

  @override
  Widget build(BuildContext context) {
    final metrics = DoctorProfileMetrics.of(context);
    final bottomPadding =
        80 + MediaQuery.paddingOf(context).bottom + metrics.sectionSpacing;
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: RefreshIndicator(
          color: Appcolor.gold,
          onRefresh: controller.refreshProfile,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              metrics.horizontalPadding,
              18,
              metrics.horizontalPadding,
              bottomPadding,
            ),
            children: [
              AuthenticatedDoctorProfileHeader(
                doctor: doctor,
                localImagePath: controller.localImagePath,
                isUpdatingImage:
                    controller.isUploadingImage || controller.isSaving,
                onEdit: controller.openEditProfile,
                onChangePhoto: controller.changeProfileImage,
              ),
              if (controller.failure != null) ...[
                const SizedBox(height: 12),
                _RefreshFailureBanner(
                  message: controller.failure!.message,
                  onRetry: controller.refreshProfile,
                ),
              ],
              SizedBox(height: metrics.sectionSpacing),
              DoctorProfileStatistics(onTap: controller.showUnavailable),
              SizedBox(height: metrics.sectionSpacing),
              DoctorInformationSection(
                title: 'personalInformation'.tr,
                icon: Icons.person_outline_rounded,
                rows: [
                  DoctorInformationRowData(
                    icon: Icons.badge_outlined,
                    label: 'fullName'.tr,
                    value: doctor.fullName,
                  ),
                  DoctorInformationRowData(
                    icon: Icons.cake_outlined,
                    label: 'age'.tr,
                    value: doctor.age.toString(),
                  ),
                  DoctorInformationRowData(
                    icon: Icons.notes_rounded,
                    label: 'biography'.tr,
                    value: doctor.note,
                  ),
                ],
              ),
              SizedBox(height: metrics.sectionSpacing),
              DoctorInformationSection(
                title: 'professionalInformation'.tr,
                icon: Icons.medical_services_outlined,
                rows: [
                  DoctorInformationRowData(
                    icon: Icons.medical_services_outlined,
                    label: 'specialization'.tr,
                    value: doctor.specialization,
                  ),
                  DoctorInformationRowData(
                    icon: Icons.workspace_premium_outlined,
                    label: 'experienceYears'.tr,
                    value: '${doctor.experienceYears} ${'yearsExperience'.tr}',
                  ),
                ],
              ),
              SizedBox(height: metrics.sectionSpacing),
              DoctorProfileActions(
                isBusy: controller.isSaving,
                onEdit: controller.openEditProfile,
                onPhoto: controller.changeProfileImage,
                onLanguage: () => _showLanguageSheet(context, controller),
                onTheme: controller.showUnavailable,
                onLogout: () => _confirmLogout(context, controller),
              ),
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

  Future<void> _confirmLogout(
    BuildContext context,
    DoctorProfileController controller,
  ) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: DoctorProfileColors.surface(context),
        icon: const Icon(Icons.logout_rounded, color: Appcolor.gold),
        title: Text('logout'.tr),
        content: Text('logoutConfirmation'.tr),
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
    if (confirmed == true) await controller.logout();
  }

  void _showLanguageSheet(
    BuildContext context,
    DoctorProfileController controller,
  ) {
    Get.bottomSheet<void>(
      SafeArea(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: DoctorProfileColors.surface(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'language'.tr,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.language_rounded),
                title: const Text('English'),
                onTap: () {
                  Get.back();
                  controller.changeLanguage('en');
                },
              ),
              ListTile(
                leading: const Icon(Icons.translate_rounded),
                title: const Text('العربية'),
                onTap: () {
                  Get.back();
                  controller.changeLanguage('ar');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AuthenticatedDoctorProfileHeader extends StatelessWidget {
  const AuthenticatedDoctorProfileHeader({
    super.key,
    required this.doctor,
    required this.localImagePath,
    required this.isUpdatingImage,
    required this.onEdit,
    required this.onChangePhoto,
  });

  final CurrentDoctorModel doctor;
  final String? localImagePath;
  final bool isUpdatingImage;
  final VoidCallback onEdit;
  final VoidCallback onChangePhoto;

  @override
  Widget build(BuildContext context) {
    final metrics = DoctorProfileMetrics.of(context);
    final avatarSize = metrics.compact ? 90.0 : 108.0;
    return Container(
      padding: EdgeInsets.fromLTRB(
        metrics.compact ? 16 : 22,
        16,
        metrics.compact ? 16 : 22,
        24,
      ),
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
            color: Appcolor.accent.withValues(alpha: .26),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'doctorProfile'.tr,
                  style: const TextStyle(
                    color: Appcolor.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Material(
                color: Colors.white.withValues(alpha: .1),
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onEdit,
                  child: const Padding(
                    padding: EdgeInsets.all(11),
                    child: Icon(
                      Icons.edit_outlined,
                      color: Appcolor.white,
                      size: 21,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          DoctorProfileAvatar(
            doctor: doctor,
            diameter: avatarSize,
            localImagePath: localImagePath,
            isUpdating: isUpdatingImage,
            onTap: onChangePhoto,
          ),
          const SizedBox(height: 14),
          Text(
            '${'doctorTitle'.tr} ${doctor.fullName}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Appcolor.white,
              fontSize: metrics.compact ? 21 : 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            doctor.specialization,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Appcolor.textLight, fontSize: 14),
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              _HeaderChip(
                icon: Icons.workspace_premium_outlined,
                label: '${doctor.experienceYears} ${'yearsExperience'.tr}',
              ),
              _HeaderChip(
                icon: Icons.verified_user_outlined,
                label: 'authenticatedProfile'.tr,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DoctorProfileAvatar extends StatelessWidget {
  const DoctorProfileAvatar({
    super.key,
    required this.doctor,
    required this.diameter,
    required this.localImagePath,
    required this.isUpdating,
    required this.onTap,
  });

  final CurrentDoctorModel doctor;
  final double diameter;
  final String? localImagePath;
  final bool isUpdating;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'changePhoto'.tr,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: diameter,
              height: diameter,
              padding: const EdgeInsets.all(4),
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
              end: 1,
              bottom: 5,
              child: Container(
                width: 31,
                height: 31,
                decoration: BoxDecoration(
                  color: Appcolor.gold,
                  shape: BoxShape.circle,
                  border: Border.all(color: Appcolor.secondary, width: 3),
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: Appcolor.white,
                  size: 15,
                ),
              ),
            ),
            if (isUpdating)
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Appcolor.secondary.withValues(alpha: .58),
                  ),
                  child: const Center(
                    child: SizedBox.square(
                      dimension: 26,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Appcolor.white,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _image() {
    if (localImagePath != null) {
      return Image.file(
        File(localImagePath!),
        width: diameter - 14,
        height: diameter - 14,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _serverImage(),
      );
    }
    return _serverImage();
  }

  Widget _serverImage() {
    if (!doctor.hasImage) return _ProfileInitials(doctor: doctor);
    final path = doctor.imagePath!;
    final uri = Uri.tryParse(path);
    final url = uri != null && uri.hasScheme ? path : '${ApiLinks.images}$path';
    return Image.network(
      url,
      width: diameter - 14,
      height: diameter - 14,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => _ProfileInitials(doctor: doctor),
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

class _ProfileInitials extends StatelessWidget {
  const _ProfileInitials({required this.doctor});
  final CurrentDoctorModel doctor;

  @override
  Widget build(BuildContext context) {
    final first = doctor.firstName.trim();
    final last = doctor.lastName.trim();
    final initials =
        '${first.isEmpty ? '' : first[0]}${last.isEmpty ? '' : last[0]}'
            .toUpperCase();
    return ColoredBox(
      color: Appcolor.primary,
      child: Center(
        child: Text(
          initials.isEmpty ? 'DR' : initials,
          style: const TextStyle(
            color: Appcolor.white,
            fontSize: 29,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _HeaderChip extends StatelessWidget {
  const _HeaderChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    constraints: BoxConstraints(
      maxWidth: MediaQuery.sizeOf(context).width - 80,
    ),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .09),
      borderRadius: BorderRadius.circular(22),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Appcolor.textLight, size: 15),
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

class DoctorProfileStatistics extends StatelessWidget {
  const DoctorProfileStatistics({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.calendar_month_outlined, 'appointments', Appcolor.info),
      (Icons.task_alt_rounded, 'completed', Appcolor.success),
      (Icons.today_rounded, 'today', Appcolor.warning),
      (Icons.people_alt_outlined, 'patients', Appcolor.accent),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ProfileSectionTitle(
          icon: Icons.insights_outlined,
          title: 'profileStatistics'.tr,
        ),
        const SizedBox(height: 13),
        LayoutBuilder(
          builder: (context, constraints) {
            final metrics = DoctorProfileMetrics.of(context);
            final columns = metrics.compact || metrics.largeText ? 1 : 2;
            final width =
                (constraints.maxWidth - (metrics.itemSpacing * (columns - 1))) /
                columns;
            return Wrap(
              spacing: metrics.itemSpacing,
              runSpacing: metrics.itemSpacing,
              children: items
                  .map(
                    (item) => SizedBox(
                      width: width,
                      child: _StatisticCard(
                        icon: item.$1,
                        label: item.$2.tr,
                        color: item.$3,
                        onTap: onTap,
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        ),
        const SizedBox(height: 9),
        Text(
          'statisticsUnavailable'.tr,
          style: const TextStyle(color: Appcolor.textLight, fontSize: 12),
        ),
      ],
    );
  }
}

class _StatisticCard extends StatelessWidget {
  const _StatisticCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: DoctorProfileColors.surface(context),
    borderRadius: BorderRadius.circular(18),
    child: InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: DoctorProfileColors.border(context)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: color, size: 21),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '—',
                    style: TextStyle(
                      color: DoctorProfileColors.text(context),
                      fontSize: 19,
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

class DoctorInformationRowData {
  const DoctorInformationRowData({
    required this.icon,
    required this.label,
    this.value,
  });
  final IconData icon;
  final String label;
  final String? value;
}

class DoctorInformationSection extends StatelessWidget {
  const DoctorInformationSection({
    super.key,
    required this.title,
    required this.icon,
    required this.rows,
  });
  final String title;
  final IconData icon;
  final List<DoctorInformationRowData> rows;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _ProfileSectionTitle(icon: icon, title: title),
      const SizedBox(height: 13),
      Container(
        decoration: BoxDecoration(
          color: DoctorProfileColors.surface(context),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: DoctorProfileColors.border(context)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(rows.length, (index) {
            final row = rows[index];
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DoctorInformationRow(data: row),
                if (index != rows.length - 1)
                  Divider(
                    height: 1,
                    indent: 58,
                    endIndent: 16,
                    color: DoctorProfileColors.border(context),
                  ),
              ],
            );
          }),
        ),
      ),
    ],
  );
}

class DoctorInformationRow extends StatelessWidget {
  const DoctorInformationRow({super.key, required this.data});
  final DoctorInformationRowData data;

  @override
  Widget build(BuildContext context) {
    final value = data.value?.trim();
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Appcolor.accent.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(data.icon, color: Appcolor.accent, size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.label,
                  style: const TextStyle(
                    color: Appcolor.textLight,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value == null || value.isEmpty ? 'notProvided'.tr : value,
                  softWrap: true,
                  style: TextStyle(
                    color: DoctorProfileColors.text(context),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
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

class DoctorProfileActions extends StatelessWidget {
  const DoctorProfileActions({
    super.key,
    required this.isBusy,
    required this.onEdit,
    required this.onPhoto,
    required this.onLanguage,
    required this.onTheme,
    required this.onLogout,
  });
  final bool isBusy;
  final VoidCallback onEdit;
  final VoidCallback onPhoto;
  final VoidCallback onLanguage;
  final VoidCallback onTheme;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _ProfileSectionTitle(
        icon: Icons.tune_rounded,
        title: 'profileActions'.tr,
      ),
      const SizedBox(height: 13),
      Container(
        decoration: BoxDecoration(
          color: DoctorProfileColors.surface(context),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: DoctorProfileColors.border(context)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ActionTile(
              icon: Icons.edit_outlined,
              label: 'editProfile'.tr,
              onTap: onEdit,
            ),
            _ActionTile(
              icon: Icons.add_a_photo_outlined,
              label: 'changePhoto'.tr,
              onTap: onPhoto,
            ),
            _ActionTile(
              icon: Icons.language_rounded,
              label: 'language'.tr,
              onTap: onLanguage,
            ),
            _ActionTile(
              icon: Icons.dark_mode_outlined,
              label: 'theme'.tr,
              onTap: onTheme,
            ),
            _ActionTile(
              icon: Icons.logout_rounded,
              label: 'logout'.tr,
              color: Appcolor.error,
              trailing: isBusy
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : null,
              onTap: isBusy ? null : onLogout,
              showDivider: false,
            ),
          ],
        ),
      ),
    ],
  );
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = Appcolor.accent,
    this.trailing,
    this.showDivider = true,
  });
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color color;
  final Widget? trailing;
  final bool showDivider;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
        leading: Icon(icon, color: color),
        title: Text(
          label,
          style: TextStyle(
            color: color == Appcolor.error
                ? color
                : DoctorProfileColors.text(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing:
            trailing ??
            Icon(
              Directionality.of(context) == TextDirection.rtl
                  ? Icons.chevron_left_rounded
                  : Icons.chevron_right_rounded,
              color: Appcolor.textLight,
            ),
        onTap: onTap,
      ),
      if (showDivider)
        Divider(
          height: 1,
          indent: 56,
          endIndent: 16,
          color: DoctorProfileColors.border(context),
        ),
    ],
  );
}

class _ProfileSectionTitle extends StatelessWidget {
  const _ProfileSectionTitle({required this.icon, required this.title});
  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, color: Appcolor.gold, size: 21),
      const SizedBox(width: 9),
      Expanded(
        child: Text(
          title,
          style: TextStyle(
            color: DoctorProfileColors.text(context),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ],
  );
}

class _RefreshFailureBanner extends StatelessWidget {
  const _RefreshFailureBanner({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Appcolor.error.withValues(alpha: .1),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Appcolor.error.withValues(alpha: .3)),
    ),
    child: Row(
      children: [
        const Icon(Icons.info_outline, color: Appcolor.error),
        const SizedBox(width: 10),
        Expanded(child: Text(message, maxLines: 3)),
        TextButton(onPressed: onRetry, child: Text('retry'.tr)),
      ],
    ),
  );
}

class DoctorProfileSkeleton extends StatelessWidget {
  const DoctorProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final metrics = DoctorProfileMetrics.of(context);
    return ListView(
      padding: EdgeInsets.all(metrics.horizontalPadding),
      children: [
        _box(context, 300),
        SizedBox(height: metrics.sectionSpacing),
        Wrap(
          spacing: metrics.itemSpacing,
          runSpacing: metrics.itemSpacing,
          children: List.generate(
            4,
            (_) => SizedBox(
              width: metrics.compact
                  ? double.infinity
                  : (MediaQuery.sizeOf(context).width -
                            (metrics.horizontalPadding * 2) -
                            metrics.itemSpacing) /
                        2,
              child: _box(context, 76),
            ),
          ),
        ),
        SizedBox(height: metrics.sectionSpacing),
        _box(context, 220),
      ],
    );
  }

  Widget _box(BuildContext context, double height) => Container(
    height: height,
    decoration: BoxDecoration(
      color: DoctorProfileColors.surface(context),
      borderRadius: BorderRadius.circular(22),
    ),
  );
}

class DoctorProfileErrorState extends StatelessWidget {
  const DoctorProfileErrorState({
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
          const Icon(Icons.person_off_outlined, size: 56, color: Appcolor.gold),
          const SizedBox(height: 14),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: DoctorProfileColors.text(context)),
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

class DoctorProfileMetrics {
  const DoctorProfileMetrics({
    required this.compact,
    required this.largeText,
    required this.horizontalPadding,
    required this.itemSpacing,
    required this.sectionSpacing,
  });
  final bool compact;
  final bool largeText;
  final double horizontalPadding;
  final double itemSpacing;
  final double sectionSpacing;

  factory DoctorProfileMetrics.of(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 360;
    final scale = MediaQuery.textScalerOf(context).scale(1);
    return DoctorProfileMetrics(
      compact: compact,
      largeText: scale >= 1.3,
      horizontalPadding: compact ? 14 : 20,
      itemSpacing: compact ? 8 : 10,
      sectionSpacing: compact ? 20 : 28,
    );
  }
}

abstract final class DoctorProfileColors {
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
