import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../Controller/Doctor/DoctorEditProfileController.dart';
import '../../../core/constant/Appcolor.dart';
import 'DoctorProfilePage.dart';

class DoctorEditProfilePage extends StatelessWidget {
  const DoctorEditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DoctorEditProfileController>(
      builder: (controller) {
        final metrics = DoctorProfileMetrics.of(context);
        return Scaffold(
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? Appcolor.cardBg
              : const Color(0xFFF6F7FB),
          body: SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Form(
                  key: controller.formKey,
                  child: ListView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: EdgeInsets.fromLTRB(
                      metrics.horizontalPadding,
                      12,
                      metrics.horizontalPadding,
                      MediaQuery.paddingOf(context).bottom + 28,
                    ),
                    children: [
                      _EditHeader(isSaving: controller.isSaving),
                      SizedBox(height: metrics.sectionSpacing),
                      _EditSection(
                        title: 'personalInformation'.tr,
                        icon: Icons.person_outline_rounded,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final useRow =
                                constraints.maxWidth >= 560 &&
                                !metrics.largeText;
                            final firstName = EditProfileField(
                              controller: controller.firstNameController,
                              label: 'firstName'.tr,
                              icon: Icons.person_outline_rounded,
                              validator: controller.validateName,
                              textInputAction: TextInputAction.next,
                            );
                            final lastName = EditProfileField(
                              controller: controller.lastNameController,
                              label: 'lastName'.tr,
                              icon: Icons.person_outline_rounded,
                              validator: controller.validateName,
                              textInputAction: TextInputAction.next,
                            );
                            if (!useRow) {
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  firstName,
                                  const SizedBox(height: 14),
                                  lastName,
                                ],
                              );
                            }
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: firstName),
                                const SizedBox(width: 14),
                                Expanded(child: lastName),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 14),
                      EditProfileField(
                        controller: controller.ageController,
                        label: 'age'.tr,
                        icon: Icons.cake_outlined,
                        validator: controller.validateAge,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 14),
                      EditProfileField(
                        controller: controller.noteController,
                        label: 'biography'.tr,
                        icon: Icons.notes_rounded,
                        validator: controller.validateNote,
                        maxLines: 4,
                        textInputAction: TextInputAction.newline,
                      ),
                      SizedBox(height: metrics.sectionSpacing),
                      _EditSection(
                        title: 'professionalInformation'.tr,
                        icon: Icons.medical_services_outlined,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            EditProfileField(
                              controller: controller.specializationController,
                              label: 'specialization'.tr,
                              icon: Icons.medical_services_outlined,
                              validator: controller.validateSpecialization,
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 14),
                            EditProfileField(
                              controller: controller.experienceYearsController,
                              label: 'experienceYears'.tr,
                              icon: Icons.workspace_premium_outlined,
                              validator: controller.validateExperience,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => controller.save(),
                            ),
                          ],
                        ),
                      ),
                      if (controller.failure != null) ...[
                        const SizedBox(height: 16),
                        _FailureCard(message: controller.failure!.message),
                      ],
                      SizedBox(height: metrics.sectionSpacing),
                      _SaveButton(
                        isSaving: controller.isSaving,
                        onPressed: controller.save,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EditHeader extends StatelessWidget {
  const _EditHeader({required this.isSaving});
  final bool isSaving;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Appcolor.secondary, Appcolor.accent],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: Appcolor.accent.withValues(alpha: .24),
          blurRadius: 24,
          offset: const Offset(0, 12),
        ),
      ],
    ),
    child: Row(
      children: [
        Material(
          color: Colors.white.withValues(alpha: .1),
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: isSaving ? null : Get.back,
            child: const Padding(
              padding: EdgeInsets.all(10),
              child: Icon(Icons.arrow_back_rounded, color: Appcolor.white),
            ),
          ),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'editProfile'.tr,
                style: const TextStyle(
                  color: Appcolor.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'editProfileSubtitle'.tr,
                style: const TextStyle(color: Appcolor.textLight, fontSize: 12),
              ),
            ],
          ),
        ),
        const Icon(
          Icons.edit_note_rounded,
          color: Appcolor.textLight,
          size: 30,
        ),
      ],
    ),
  );
}

class _EditSection extends StatelessWidget {
  const _EditSection({
    required this.title,
    required this.icon,
    required this.child,
  });
  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
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
      ),
      const SizedBox(height: 13),
      child,
    ],
  );
}

class EditProfileField extends StatelessWidget {
  const EditProfileField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    required this.validator,
    this.keyboardType,
    this.inputFormatters,
    this.textInputAction,
    this.maxLines = 1,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final FormFieldValidator<String> validator;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;
  final int maxLines;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    validator: validator,
    keyboardType: keyboardType,
    inputFormatters: inputFormatters,
    textInputAction: textInputAction,
    maxLines: maxLines,
    onFieldSubmitted: onSubmitted,
    style: TextStyle(color: DoctorProfileColors.text(context)),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Appcolor.textLight),
      prefixIcon: Icon(icon, color: Appcolor.accent),
      filled: true,
      fillColor: DoctorProfileColors.surface(context),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: DoctorProfileColors.border(context)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: DoctorProfileColors.border(context)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Appcolor.accent, width: 1.5),
      ),
      errorMaxLines: 2,
    ),
  );
}

class _FailureCard extends StatelessWidget {
  const _FailureCard({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Appcolor.error.withValues(alpha: .1),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Appcolor.error.withValues(alpha: .3)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.error_outline_rounded, color: Appcolor.error),
        const SizedBox(width: 10),
        Expanded(child: Text(message)),
      ],
    ),
  );
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.isSaving, required this.onPressed});
  final bool isSaving;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      gradient: const LinearGradient(colors: Appcolor.gradientColors),
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
          color: Appcolor.accent.withValues(alpha: .3),
          blurRadius: 18,
          offset: const Offset(0, 9),
        ),
      ],
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: isSaving ? null : onPressed,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 56),
          child: Center(
            child: isSaving
                ? const SizedBox.square(
                    dimension: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Appcolor.white,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.save_outlined, color: Appcolor.white),
                      const SizedBox(width: 9),
                      Flexible(
                        child: Text(
                          'saveChanges'.tr,
                          style: const TextStyle(
                            color: Appcolor.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    ),
  );
}
