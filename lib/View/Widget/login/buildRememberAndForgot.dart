import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/route_manager.dart';
import '../../../../Controller/Auth/LoginPage/LoginController.dart';
import '../../../../core/constant/Appcolor.dart';

class buildRememberAndForgot extends GetView<LoginController> {
  const buildRememberAndForgot({Key? key}) : super(key: key);

  // -------------------- تذكرني ونسيت كلمة المرور --------------------

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Obx(
          () => Row(
            textDirection: TextDirection.rtl,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: controller.rememberMe.value,
                  onChanged: controller.toggleRememberMe,
                  activeColor: Appcolor.gradientColors[0],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () =>
                    controller.toggleRememberMe(!controller.rememberMe.value),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'تذكرني',
                    style: TextStyle(
                      color: Appcolor.subTextColor,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: () {},
          child: ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: Appcolor.gradientColors,
            ).createShader(bounds),
            child: const Text(
              'نسيت كلمة المرور؟',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
