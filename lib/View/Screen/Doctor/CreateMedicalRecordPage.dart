import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../Controller/Doctor/CreateMedicalRecordController.dart';
import '../../../core/constant/Appcolor.dart';
import '../Doctor/DoctorEditProfilePage.dart';
import '../Doctor/DoctorHomePage.dart';

class CreateMedicalRecordPage extends StatelessWidget {
  const CreateMedicalRecordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CreateMedicalRecordController>(
      builder: (controller) => Scaffold(
        backgroundColor: DoctorHomeColors.background(context),
        appBar: AppBar(title: Text('createMedicalRecord'.tr)),
        body: controller.hasValidArguments
            ? _MedicalRecordForm(controller: controller)
            : _InvalidFormState(
                messageKey: controller.argumentErrorKey ?? 'invalidAppointment',
              ),
      ),
    );
  }
}

class _MedicalRecordForm extends StatelessWidget {
  const _MedicalRecordForm({required this.controller});

  final CreateMedicalRecordController controller;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Form(
        key: controller.formKey,
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(
            16,
            20,
            16,
            MediaQuery.viewInsetsOf(context).bottom +
                MediaQuery.paddingOf(context).bottom +
                28,
          ),
          children: [
            EditProfileField(
              controller: controller.diagnosisController,
              label: 'diagnosis'.tr,
              icon: Icons.medical_information_outlined,
              validator: controller.validateDiagnosis,
              textInputAction: TextInputAction.next,
              maxLines: 3,
            ),
            const SizedBox(height: 14),
            EditProfileField(
              controller: controller.visitDescriptionController,
              label: 'visitDescription'.tr,
              icon: Icons.description_outlined,
              validator: controller.validateVisitDescription,
              textInputAction: TextInputAction.newline,
              maxLines: 4,
            ),
            const SizedBox(height: 14),
            EditProfileField(
              controller: controller.notesController,
              label: 'notes'.tr,
              icon: Icons.notes_rounded,
              validator: controller.validateNotes,
              textInputAction: TextInputAction.newline,
              maxLines: 4,
            ),
            if (controller.failureMessage != null) ...[
              const SizedBox(height: 16),
              _FailureCard(message: controller.failureMessage!),
            ],
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: controller.isSubmitting ? null : controller.submit,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(54),
                backgroundColor: Appcolor.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: controller.isSubmitting
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: Appcolor.white,
                      ),
                    )
                  : const Icon(Icons.add_rounded),
              label: Text('createMedicalRecord'.tr),
            ),
          ],
        ),
      ),
    );
  }
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

class _InvalidFormState extends StatelessWidget {
  const _InvalidFormState({required this.messageKey});

  final String messageKey;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 54,
            color: Appcolor.error,
          ),
          const SizedBox(height: 14),
          Text(
            messageKey.tr,
            textAlign: TextAlign.center,
            style: TextStyle(color: DoctorHomeColors.text(context)),
          ),
        ],
      ),
    ),
  );
}
