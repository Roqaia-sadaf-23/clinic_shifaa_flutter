import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Controller/Intro/IntroController.dart';
import '../../core/constant/Appimagesassent.dart';

class IntroScreen extends GetView<IntroController> {
  const IntroScreen({super.key});

  static const _primary = Color(0xff0057FF);
  static const _selectedBackground = Color(0xffEAF3FF);

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xffF8F9FD),
    body: SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: GetBuilder<IntroController>(
                builder: (current) => Column(
                  children: [
                    const SizedBox(height: 40),
                    Text(
                      'introTitle'.tr,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff0B1B4D),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'introSubtitle'.tr,
                      style: const TextStyle(fontSize: 18, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 35),
                    Container(
                      height: 280,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: _selectedBackground,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Center(
                        child: Image.asset(
                          Appimagesassent.personicon,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 35),
                    Text(
                      'chooseAccountType'.tr,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 25),
                    Row(
                      children: [
                        Expanded(
                          child: _AccountTypeCard(
                            accountType: IntroController.patientRole,
                            icon: Icons.person,
                            selected:
                                current.selectedAccountType ==
                                IntroController.patientRole,
                            onTap: current.selectAccountType,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: _AccountTypeCard(
                            accountType: IntroController.doctorRole,
                            icon: Icons.medical_services,
                            selected:
                                current.selectedAccountType ==
                                IntroController.doctorRole,
                            onTap: current.selectAccountType,
                          ),
                        ),
                      ],
                    ),
                    if (current.showSelectionValidation) ...[
                      const SizedBox(height: 12),
                      Text(
                        'accountTypeRequired'.tr,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    const Spacer(),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        onPressed: current.isSaving
                            ? null
                            : current.continueToAuthentication,
                        child: current.isSaving
                            ? const SizedBox.square(
                                dimension: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'next'.tr,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 25),
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

class _AccountTypeCard extends StatelessWidget {
  const _AccountTypeCard({
    required this.accountType,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String accountType;
  final IconData icon;
  final bool selected;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    label: accountType.toLowerCase().tr,
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTap(accountType),
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 150,
          decoration: BoxDecoration(
            color: selected ? IntroScreen._selectedBackground : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? IntroScreen._primary : Colors.transparent,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12.withValues(alpha: 0.05),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 50, color: IntroScreen._primary),
                    const SizedBox(height: 15),
                    Text(
                      accountType.toLowerCase().tr,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected)
                const PositionedDirectional(
                  top: 10,
                  end: 10,
                  child: Icon(
                    Icons.check_circle,
                    color: IntroScreen._primary,
                    size: 24,
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}
