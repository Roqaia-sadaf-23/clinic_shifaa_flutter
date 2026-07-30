import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../Controller/Doctor/CreatePrescriptionController.dart';
import '../../../core/constant/Appcolor.dart';
import 'DoctorEditProfilePage.dart';
import 'DoctorHomePage.dart';

class CreatePrescriptionPage extends StatelessWidget {
  const CreatePrescriptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CreatePrescriptionController>(
      builder: (controller) => Scaffold(
        backgroundColor: DoctorHomeColors.background(context),
        appBar: AppBar(title: Text('createPrescription'.tr)),
        body: controller.hasValidArguments
            ? _PrescriptionForm(controller: controller)
            : _InvalidFormState(
                messageKey:
                    controller.argumentErrorKey ?? 'medicalRecordNotFound',
              ),
      ),
    );
  }
}

class _PrescriptionForm extends StatelessWidget {
  const _PrescriptionForm({required this.controller});

  final CreatePrescriptionController controller;

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
              controller: controller.medicationNameController,
              label: 'medicationName'.tr,
              icon: Icons.medication_outlined,
              validator: controller.validateMedicationName,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 14),
            EditProfileField(
              controller: controller.dosageController,
              label: 'dosage'.tr,
              icon: Icons.science_outlined,
              validator: controller.validateDosage,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 14),
            EditProfileField(
              controller: controller.frequencyController,
              label: 'frequency'.tr,
              icon: Icons.schedule_rounded,
              validator: controller.validateFrequency,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 14),
            EditProfileField(
              controller: controller.specialInstructionsController,
              label: 'specialInstructions'.tr,
              icon: Icons.notes_rounded,
              validator: controller.validateSpecialInstructions,
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
              label: Text('createPrescription'.tr),
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
