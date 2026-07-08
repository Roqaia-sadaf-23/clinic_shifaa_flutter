// ignore_for_file: file_names

import 'dart:io';

import 'package:clinic_shifaa/View/Widget/Custome/buildButton.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:clinic_shifaa/View/Widget/Custome/buildDropdownField.dart';
import '../../../../Controller/Auth/RegisterPage/RegisterPage_controler.dart';
import '../../../../core/constant/Appcolor.dart';
import '../../../Widget/Custome/buildCard.dart';
import '../../../Widget/Custome/buildField.dart';
import '../../../Widget/Custome/genderOption.dart';

class RegisterScreen extends StatelessWidget {
  RegisterScreen({super.key});

  final RegisterController controller = Get.put(RegisterController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RegisterController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: Appcolor.cardBg,
          body: FadeTransition(
            opacity: controller.fadeAnimation,
            child: Stack(
              children: [
                Positioned(
                  top: -80,
                  right: -80,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Appcolor.accent.withOpacity(0.3),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -100,
                  left: -60,
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Appcolor.gold.withOpacity(0.2),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  child: Column(
                    children: [
                      _buildHeader(controller),
                      _buildStepIndicator(controller),
                      Expanded(
                        child: Form(
                          key: controller.formKey,
                          child: SlideTransition(
                            position: controller.slideAnimation,
                            child: _buildCurrentStep(controller),
                          ),
                        ),
                      ),
                      _buildNavigationButtons(controller),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(RegisterController controller) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Column(
        children: [
          GestureDetector(
            onTap: controller.pickImage,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Appcolor.accent, Appcolor.gold],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Appcolor.accent.withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: controller.profileImage != null
                  ? ClipOval(
                      child: Image.file(
                        File(controller.profileImage!.path),
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_a_photo_rounded,
                          color: Appcolor.white,
                          size: 28,
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Upload',
                          style: TextStyle(
                            color: Appcolor.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 16),
          ShaderMask(
            shaderCallback: (bounds) {
              return const LinearGradient(
                colors: [Appcolor.white, Appcolor.textLight],
              ).createShader(bounds);
            },
            child: const Text(
              'Create Account',
              style: TextStyle(
                color: Appcolor.white,
                fontSize: 26,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Fill in your details to get started',
            style: TextStyle(color: Appcolor.textLight, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(RegisterController controller) {
    final steps = ['Personal', 'Account', 'Details'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        children: List.generate(steps.length, (i) {
          final isActive = i == controller.currentStep;
          final isDone = i < controller.currentStep;

          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 4,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          gradient: isActive || isDone
                              ? const LinearGradient(
                                  colors: [Appcolor.gold, Appcolor.accent],
                                )
                              : null,
                          color: isActive || isDone ? null : Appcolor.inputBg,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        steps[i],
                        style: TextStyle(
                          color: isActive ? Appcolor.white : Appcolor.textLight,
                          fontSize: 11,
                          fontWeight: isActive
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                if (i < steps.length - 1) const SizedBox(width: 8),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCurrentStep(RegisterController controller) {
    switch (controller.currentStep) {
      case 0:
        return _buildPersonalStep(controller);
      case 1:
        return _buildAccountStep(controller);
      case 2:
        return _buildDetailsStep(controller);
      default:
        return const SizedBox();
    }
  }

  Widget _buildPersonalStep(RegisterController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: buildField(
                  controller: controller.firstNameCtrl,
                  label: 'First Name',
                  icon: Icons.person_outline_rounded,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: buildField(
                  controller: controller.lastNameCtrl,
                  label: 'Last Name',
                  icon: Icons.person_outline_rounded,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
              ),
            ],
          ),
          buildField(
            controller: controller.phoneCtrl,
            label: 'Phone Number',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (v) => v!.isEmpty ? 'Required' : null,
          ),
          buildField(
            controller: controller.ageCtrl,
            label: 'Age',
            icon: Icons.cake_outlined,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          buildField(
            controller: controller.addressCtrl,
            label: 'Address',
            icon: Icons.location_on_outlined,
            maxLines: 2,
          ),
          buildGenderSelector(controller),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget buildGenderSelector(RegisterController controller) {
    return buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.wc_rounded, color: Appcolor.accent, size: 18),
              SizedBox(width: 8),
              Text(
                'Gender',
                style: TextStyle(
                  color: Appcolor.textLight,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              genderOption(controller, 0, 'Male', Icons.male_rounded),
              const SizedBox(width: 12),
              genderOption(controller, 1, 'Female', Icons.female_rounded),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccountStep(RegisterController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          buildField(
            controller: controller.userNameCtrl,
            label: 'Username',
            icon: Icons.alternate_email_rounded,
            validator: (v) => v!.isEmpty ? 'Required' : null,
          ),
          buildField(
            controller: controller.emailCtrl,
            label: 'Email Address',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v!.isEmpty) return 'Required';
              if (!v.contains('@')) return 'Invalid email';
              return null;
            },
          ),
          _buildPasswordField(controller),
          buildDropdownField(
            label: 'Role',
            icon: Icons.badge_outlined,
            value: controller.selectedRole?.roleName,
            items: controller.roles.map((role) => role.roleName).toList(),
            onChanged: (v) {
              if (v == null) return;

              final role = controller.roles.firstWhere(
                (role) => role.roleName == v,
              );

              controller.changeRole(role);
            },
          ),

          _buildActiveToggle(controller),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildPasswordField(RegisterController controller) {
    return buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.lock_outline_rounded,
                color: Appcolor.accent,
                size: 18,
              ),
              SizedBox(width: 8),
              Text(
                'Password',
                style: TextStyle(
                  color: Appcolor.textLight,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller.passwordCtrl,
            obscureText: controller.obscurePassword,
            style: const TextStyle(color: Appcolor.white, fontSize: 14),
            validator: (v) {
              if (v!.isEmpty) return 'Required';
              if (v.length < 6) return 'Min 6 characters';
              return null;
            },
            decoration: InputDecoration(
              hintText: '••••••••',
              hintStyle: TextStyle(color: Appcolor.textLight.withOpacity(0.5)),
              border: InputBorder.none,
              isDense: true,
              suffixIcon: IconButton(
                icon: Icon(
                  controller.obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Appcolor.textLight,
                  size: 18,
                ),
                onPressed: controller.togglePassword,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveToggle(RegisterController controller) {
    return buildCard(
      child: Row(
        children: [
          const Icon(
            Icons.toggle_on_outlined,
            color: Appcolor.accent,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Active Status',
                  style: TextStyle(
                    color: Appcolor.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Account is ${controller.isActive ? "active" : "inactive"}',
                  style: const TextStyle(
                    color: Appcolor.textLight,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: controller.isActive,
            onChanged: controller.changeActive,
            activeColor: Appcolor.gold,
            activeTrackColor: Appcolor.accent.withOpacity(0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsStep(RegisterController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          buildField(
            controller: controller.nationalityNoCtrl,
            label: 'Nationality / National ID',
            icon: Icons.credit_card_outlined,
          ),
          buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.flag_outlined,
                      color: Appcolor.accent,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Country of Nationality',
                      style: TextStyle(
                        color: Appcolor.textLight,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                buildDropdownField(
                  label: 'Country',
                  icon: Icons.flag_outlined,
                  value: controller.selectedCountry?.CountryName,
                  items: controller.countries
                      .map((country) => country.CountryName)
                      .toList(),
                  onChanged: (v) {
                    if (v == null) return;

                    final country = controller.countries.firstWhere(
                      (country) => country.CountryName == v,
                    );

                    controller.changeCountry(country);
                  },
                ),
                /* DropdownButton<RoleModel>(
                  value: controller.selectedRole,
                  isExpanded: true,
                  dropdownColor: Appcolor.secondary,
                  underline: const SizedBox(),
                  iconEnabledColor: Appcolor.textLight,
                  style: const TextStyle(color: Appcolor.white, fontSize: 14),
                  items: controller.roles.map((role) {
                    return DropdownMenuItem<RoleModel>(
                      value: role,
                      child: Text(role.roleName),
                    );
                  }).toList(),
                  onChanged: (role) {
                    if (role != null) {
                      controller.selectedRole = role;
                      controller.roleId = role.Id;
                      controller.update();
                    }
                  },
                ), */
              ],
            ),
          ),

          buildField(
            controller: controller.noteCtrl,
            label: 'Note / Bio',
            icon: Icons.note_alt_outlined,
            maxLines: 4,
          ),
          const SizedBox(height: 20),
          _buildSummaryCard(controller),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(RegisterController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Appcolor.accent.withOpacity(0.4), width: 1),
        gradient: LinearGradient(
          colors: [
            Appcolor.accent.withOpacity(0.15),
            Appcolor.gold.withOpacity(0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.check_circle_outline, color: Appcolor.gold, size: 18),
              SizedBox(width: 8),
              Text(
                'Summary',
                style: TextStyle(
                  color: Appcolor.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _summaryRow(
            'Name',
            '${controller.firstNameCtrl.text} ${controller.lastNameCtrl.text}',
          ),
          _summaryRow('Email', controller.emailCtrl.text),
          _summaryRow('Username', controller.userNameCtrl.text),
          _summaryRow('Gender', controller.gender == 0 ? 'Male' : 'Female'),
          _summaryRow(
            'Country',
            controller.selectedCountry?.CountryName ?? '—',
          ),
          _summaryRow(
            'Status',
            controller.isActive ? '✅ Active' : '❌ Inactive',
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String key, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              key,
              style: const TextStyle(color: Appcolor.textLight, fontSize: 11),
            ),
          ),
          const Text(
            '• ',
            style: TextStyle(
              color: Appcolor.accent,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
              style: const TextStyle(
                color: Appcolor.white,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(RegisterController controller) {
    final isLast = controller.currentStep == 2;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Row(
        children: [
          if (controller.currentStep > 0)
            Expanded(
              child: buildButton(
                label: 'Back',
                icon: Icons.arrow_back_rounded,
                onPressed: controller.prevStep,
                outline: true,
              ),
            ),
          if (controller.currentStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: buildButton(
              label: isLast ? 'Register' : 'Continue',
              icon: isLast ? Icons.check_rounded : Icons.arrow_forward_rounded,

              onPressed: isLast ? controller.submit : controller.nextStep,
            ),
          ),
        ],
      ),
    );
  }
}
