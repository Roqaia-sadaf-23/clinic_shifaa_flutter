import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../Controller/CompleteProfile/CompleteProfile_controller.dart';
import '../../../core/constant/Appcolor.dart';
import '../../Widget/Custome/buildButton.dart';
import '../../Widget/Custome/buildCard.dart';
import '../../Widget/Custome/buildDropdownField.dart';
import '../../Widget/Custome/buildField.dart';

class CompleteProfileScreen extends GetView<CompleteProfileController> {
  const CompleteProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CompleteProfileController>(
      builder: (controller) => Scaffold(
        backgroundColor: Appcolor.cardBg,
        body: FadeTransition(
          opacity: controller.fadeAnimation,
          child: Stack(
            children: [
              const _BackgroundGlow(
                top: -80,
                right: -80,
                color: Appcolor.accent,
              ),
              const _BackgroundGlow(
                bottom: -100,
                left: -60,
                color: Appcolor.gold,
              ),
              SafeArea(
                child: Column(
                  children: [
                    _Header(step: controller.currentStep),
                    Expanded(
                      child: Form(
                        key: controller.formKey,
                        child: SlideTransition(
                          position: controller.slideAnimation,
                          child: _CurrentStep(controller: controller),
                        ),
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
}

class _BackgroundGlow extends StatelessWidget {
  const _BackgroundGlow({
    this.top,
    this.right,
    this.bottom,
    this.left,
    required this.color,
  });

  final double? top;
  final double? right;
  final double? bottom;
  final double? left;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      right: right,
      bottom: bottom,
      left: left,
      child: Container(
        width: 280,
        height: 280,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withOpacity(0.28), Colors.transparent],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.step});

  final CompleteProfileStep step;

  @override
  Widget build(BuildContext context) {
    final isSelection = step == CompleteProfileStep.accountType;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 20),
      child: Column(
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(colors: Appcolor.gradientColors),
              boxShadow: [
                BoxShadow(
                  color: Appcolor.gradientColors.first.withOpacity(0.4),
                  blurRadius: 24,
                ),
              ],
            ),
            child: Icon(
              isSelection
                  ? Icons.person_add_alt_1_rounded
                  : Icons.assignment_ind_outlined,
              color: Appcolor.white,
              size: 34,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Complete Profile',
            style: TextStyle(
              color: Appcolor.white,
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isSelection
                ? 'Choose the account type that best describes you.'
                : 'Add the final details to personalize your account.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Appcolor.textLight, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _CurrentStep extends StatelessWidget {
  const _CurrentStep({required this.controller});

  final CompleteProfileController controller;

  @override
  Widget build(BuildContext context) {
    switch (controller.currentStep) {
      case CompleteProfileStep.accountType:
        return _AccountTypeSelection(controller: controller);
      case CompleteProfileStep.doctorForm:
        return _DoctorForm(controller: controller);
      case CompleteProfileStep.patientForm:
        return _PatientForm(controller: controller);
    }
  }
}

class _AccountTypeSelection extends StatelessWidget {
  const _AccountTypeSelection({required this.controller});

  final CompleteProfileController controller;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        children: [
          _AccountTypeCard(
            icon: Icons.medical_services_outlined,
            title: 'Doctor',
            description: 'Manage your specialty and professional details.',
            onTap: controller.selectDoctor,
          ),
          const SizedBox(height: 16),
          _AccountTypeCard(
            icon: Icons.favorite_border_rounded,
            title: 'Patient',
            description: 'Add your essential health information securely.',
            onTap: controller.selectPatient,
          ),
        ],
      ),
    );
  }
}

class _AccountTypeCard extends StatefulWidget {
  const _AccountTypeCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  State<_AccountTypeCard> createState() => _AccountTypeCardState();
}

class _AccountTypeCardState extends State<_AccountTypeCard> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => isPressed = true),
      onTapCancel: () => setState(() => isPressed = false),
      onTapUp: (_) => setState(() => isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 180),
        scale: isPressed ? 0.98 : 1,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [Appcolor.accent, Appcolor.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: Appcolor.white.withOpacity(0.08)),
            boxShadow: [
              BoxShadow(
                color: Appcolor.accent.withOpacity(0.26),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: Appcolor.gradientColors),
                ),
                child: Icon(widget.icon, color: Appcolor.white, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        color: Appcolor.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      widget.description,
                      style: const TextStyle(
                        color: Appcolor.textLight,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_rounded,
                color: Appcolor.white,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DoctorForm extends StatelessWidget {
  const _DoctorForm({required this.controller});

  final CompleteProfileController controller;

  @override
  Widget build(BuildContext context) {
    return _FormLayout(
      controller: controller,
      title: 'Doctor details',
      children: [
        buildDropdownField(
          label: 'Specialty',
          icon: Icons.medical_services_outlined,
          value: controller.selectedSpecialty?.name,
          items: controller.specialties
              .map((specialty) => specialty.name)
              .toList(),
          onChanged: controller.selectSpecialty,
        ),
        _HireDateField(controller: controller),
        buildField(
          controller: controller.experienceYearsController,
          label: 'Experience Years',
          icon: Icons.workspace_premium_outlined,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (value) {
            if (value == null || value.isEmpty) return 'Required';
            if (int.tryParse(value) == null) return 'Enter a valid number';
            return null;
          },
        ),
      ],
      onContinue: () {
        if (controller.canContinueDoctor()) {
          Get.snackbar('Profile complete', 'Doctor details are ready to save.');
        }
      },
    );
  }
}

class _PatientForm extends StatelessWidget {
  const _PatientForm({required this.controller});

  final CompleteProfileController controller;

  @override
  Widget build(BuildContext context) {
    return _FormLayout(
      controller: controller,
      title: 'Patient details',
      children: [
        buildDropdownField(
          label: 'Blood Type',
          icon: Icons.bloodtype_outlined,
          value: controller.selectedBloodType,
          items: CompleteProfileController.bloodTypes,
          onChanged: controller.selectBloodType,
        ),
      ],
      onContinue: () {
        if (controller.canContinuePatient()) {
          Get.snackbar(
            'Profile complete',
            'Patient details are ready to save.',
          );
        }
      },
    );
  }
}

class _FormLayout extends StatelessWidget {
  const _FormLayout({
    required this.controller,
    required this.title,
    required this.children,
    required this.onContinue,
  });

  final CompleteProfileController controller;
  final String title;
  final List<Widget> children;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Appcolor.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
          const SizedBox(height: 10),
          buildButton(
            label: 'Continue',
            icon: Icons.arrow_forward_rounded,
            onPressed: onContinue,
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: controller.backToAccountType,
              child: const Text(
                'Change account type',
                style: TextStyle(color: Appcolor.textLight),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HireDateField extends StatelessWidget {
  const _HireDateField({required this.controller});

  final CompleteProfileController controller;

  @override
  Widget build(BuildContext context) {
    final hireDate = controller.hireDate;
    final label = hireDate == null
        ? 'Select hire date'
        : '${hireDate.day.toString().padLeft(2, '0')}/${hireDate.month.toString().padLeft(2, '0')}/${hireDate.year}';
    return GestureDetector(
      onTap: () => controller.selectHireDate(context),
      child: buildCard(
        child: Row(
          children: [
            const Icon(
              Icons.calendar_month_outlined,
              color: Appcolor.accent,
              size: 18,
            ),
            const SizedBox(width: 8),
            const Text(
              'Hire Date',
              style: TextStyle(
                color: Appcolor.textLight,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Text(
              label,
              style: TextStyle(
                color: hireDate == null ? Appcolor.textLight : Appcolor.white,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
