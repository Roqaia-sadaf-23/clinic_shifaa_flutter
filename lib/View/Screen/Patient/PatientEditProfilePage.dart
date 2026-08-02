import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../Controller/Patient/HomeController.dart';
import '../../../core/constant/Appcolor.dart';
import '../../Widget/Custome/AppProfileImage.dart';
import '../Doctor/DoctorHomePage.dart';

class PatientEditProfilePage extends StatelessWidget {
  const PatientEditProfilePage({super.key});

  @override
  Widget build(BuildContext context) => GetBuilder<PatientHomeControllerImp>(
    builder: (controller) => PopScope(
      canPop: !controller.isPatientProfileEditBusy,
      child: Scaffold(
        backgroundColor: DoctorHomeColors.background(context),
        body: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Form(
                key: controller.patientEditFormKey,
                child: ListView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.fromLTRB(
                    20,
                    12,
                    20,
                    MediaQuery.paddingOf(context).bottom + 28,
                  ),
                  children: [
                    _EditHeader(controller: controller),
                    const SizedBox(height: 24),
                    _ProfileImageEditor(controller: controller),
                    const SizedBox(height: 26),
                    _Section(
                      title: 'personalInformation'.tr,
                      icon: Icons.person_outline_rounded,
                      child: Column(
                        children: [
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final firstName = _EditField(
                                controller:
                                    controller.patientFirstNameController,
                                label: 'firstName'.tr,
                                icon: Icons.person_outline_rounded,
                                validator: controller.validatePatientName,
                                textInputAction: TextInputAction.next,
                              );
                              final lastName = _EditField(
                                controller:
                                    controller.patientLastNameController,
                                label: 'lastName'.tr,
                                icon: Icons.person_outline_rounded,
                                validator: controller.validatePatientName,
                                textInputAction: TextInputAction.next,
                              );
                              if (constraints.maxWidth < 560) {
                                return Column(
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
                          const SizedBox(height: 14),
                          _EditField(
                            controller: controller.patientPhoneController,
                            label: 'phoneNumber'.tr,
                            icon: Icons.phone_outlined,
                            validator: controller.validatePatientOptionalText,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 14),
                          _EditField(
                            controller: controller.patientAddressController,
                            label: 'address'.tr,
                            icon: Icons.location_on_outlined,
                            validator: controller.validatePatientOptionalText,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 14),
                          _EditField(
                            controller: controller.patientNoteController,
                            label: 'biography'.tr,
                            icon: Icons.notes_rounded,
                            validator: controller.validatePatientOptionalText,
                            maxLines: 4,
                            textInputAction: TextInputAction.newline,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _Section(
                      title: 'healthInformation'.tr,
                      icon: Icons.favorite_outline_rounded,
                      child: Column(
                        children: [
                          _EditField(
                            controller: controller.patientAgeController,
                            label: 'age'.tr,
                            icon: Icons.cake_outlined,
                            validator: controller.validatePatientAge,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            textInputAction: TextInputAction.done,
                          ),
                          const SizedBox(height: 14),
                          _GenderSelector(controller: controller),
                          const SizedBox(height: 14),
                          DropdownButtonFormField<String>(
                            initialValue: controller.selectedPatientBloodType,
                            decoration: _fieldDecoration(
                              context,
                              'bloodType'.tr,
                              Icons.bloodtype_outlined,
                            ),
                            items: controller.editableBloodTypes
                                .map(
                                  (value) => DropdownMenuItem(
                                    value: value,
                                    child: Text(value),
                                  ),
                                )
                                .toList(growable: false),
                            onChanged: controller.isPatientProfileEditBusy
                                ? null
                                : controller.selectPatientBloodType,
                            validator: (value) =>
                                value == null || value.trim().isEmpty
                                ? 'fieldRequired'.tr
                                : null,
                          ),
                        ],
                      ),
                    ),
                    if (controller.profileEditFailure != null) ...[
                      const SizedBox(height: 18),
                      _FailureCard(
                        message: controller.profileEditFailure!.message,
                      ),
                    ],
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      key: const Key('patient-profile-save-button'),
                      onPressed: controller.isPatientProfileEditBusy
                          ? null
                          : controller.savePatientProfile,
                      style: FilledButton.styleFrom(
                        backgroundColor: Appcolor.accent,
                        foregroundColor: Appcolor.white,
                        minimumSize: const Size.fromHeight(56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      icon: controller.isSavingPatientProfile
                          ? const SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Appcolor.white,
                              ),
                            )
                          : const Icon(Icons.save_outlined),
                      label: Text(
                        'saveChanges'.tr,
                        style: const TextStyle(
                          fontSize: 17,
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
      ),
    ),
  );
}

class _EditHeader extends StatelessWidget {
  const _EditHeader({required this.controller});

  final PatientHomeControllerImp controller;

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
          child: IconButton(
            onPressed: controller.isPatientProfileEditBusy ? null : Get.back,
            icon: const Icon(Icons.arrow_back_rounded, color: Appcolor.white),
          ),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
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
                'patientEditProfileSubtitle'.tr,
                style: const TextStyle(color: Appcolor.textLight, fontSize: 12),
              ),
            ],
          ),
        ),
        const Icon(
          Icons.manage_accounts_outlined,
          color: Appcolor.textLight,
          size: 29,
        ),
      ],
    ),
  );
}

class _ProfileImageEditor extends StatelessWidget {
  const _ProfileImageEditor({required this.controller});

  final PatientHomeControllerImp controller;

  @override
  Widget build(BuildContext context) {
    final localPath = controller.selectedPatientImagePath;
    final fallback = const ColoredBox(
      color: Appcolor.secondary,
      child: Icon(Icons.person_rounded, color: Appcolor.white, size: 55),
    );
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Appcolor.gold, width: 2),
          ),
          child: ClipOval(
            child: localPath == null
                ? AppProfileImage(
                    imagePath: controller.patient?.imagePath,
                    size: 112,
                    fallback: fallback,
                  )
                : Image.file(
                    File(localPath),
                    width: 112,
                    height: 112,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) =>
                        SizedBox.square(dimension: 112, child: fallback),
                  ),
          ),
        ),
        const SizedBox(height: 10),
        TextButton.icon(
          key: const Key('patient-profile-image-picker'),
          onPressed: controller.isPatientProfileEditBusy
              ? null
              : controller.pickPatientProfileImage,
          icon: controller.isPickingPatientImage
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.photo_camera_outlined),
          label: Text('changePhoto'.tr),
        ),
      ],
    );
  }
}

class _GenderSelector extends StatelessWidget {
  const _GenderSelector({required this.controller});

  final PatientHomeControllerImp controller;

  @override
  Widget build(BuildContext context) => InputDecorator(
    decoration: _fieldDecoration(context, 'gender'.tr, Icons.wc_outlined),
    child: Row(
      children: [
        Expanded(
          child: ChoiceChip(
            label: Text('male'.tr),
            selected: controller.selectedPatientGender == 0,
            onSelected: controller.isPatientProfileEditBusy
                ? null
                : (_) => controller.selectPatientGender(0),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ChoiceChip(
            label: Text('female'.tr),
            selected: controller.selectedPatientGender == 1,
            onSelected: controller.isPatientProfileEditBusy
                ? null
                : (_) => controller.selectPatientGender(1),
          ),
        ),
      ],
    ),
  );
}

class _Section extends StatelessWidget {
  const _Section({
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
                color: DoctorHomeColors.text(context),
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

class _EditField extends StatelessWidget {
  const _EditField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.validator,
    this.keyboardType,
    this.inputFormatters,
    this.textInputAction,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final FormFieldValidator<String> validator;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;
  final int maxLines;

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    validator: validator,
    keyboardType: keyboardType,
    inputFormatters: inputFormatters,
    textInputAction: textInputAction,
    maxLines: maxLines,
    style: TextStyle(color: DoctorHomeColors.text(context)),
    decoration: _fieldDecoration(context, label, icon),
  );
}

InputDecoration _fieldDecoration(
  BuildContext context,
  String label,
  IconData icon,
) => InputDecoration(
  labelText: label,
  labelStyle: const TextStyle(color: Appcolor.textLight),
  prefixIcon: Icon(icon, color: Appcolor.accent),
  filled: true,
  fillColor: DoctorHomeColors.surface(context),
  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(18),
    borderSide: BorderSide(color: DoctorHomeColors.border(context)),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(18),
    borderSide: BorderSide(color: DoctorHomeColors.border(context)),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(18),
    borderSide: const BorderSide(color: Appcolor.accent, width: 1.5),
  ),
  errorMaxLines: 2,
);

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
